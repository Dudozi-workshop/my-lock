#!/usr/bin/env python3
"""Generate MY LOCK Asset Book data from Production manifests.

The Asset Book is a viewer, never a source of truth. This script only reads
repository manifests and emits public-safe metadata. Private Drive URLs and IDs
are intentionally excluded from the generated web payload.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SHAPE_ROOT = ROOT / "assets/shape_masters/drop01/sea_turtle_v3"
BOOK_DIR = ROOT / "web/asset-book"
OUTPUT = BOOK_DIR / "data.js"
MASTER_POINTER = SHAPE_ROOT / "asset_book/MASTER_POINTER.json"

BLOCKED_STATUS = {
    "candidate",
    "pending",
    "superseded",
    "inactive",
    "legacy",
    "withdrawn",
    "rejected",
    "hold",
}

PART_ORDER = [
    "shell_main",
    "body_with_rear",
    "underbelly",
    "front_flipper_near",
    "front_flipper_far",
]

PART_LABELS = {
    "shell_main": "Shell",
    "body_with_rear": "Body + Rear",
    "underbelly": "Underbelly",
    "front_flipper_near": "Front Flipper · Near",
    "front_flipper_far": "Front Flipper · Far",
}

PART_ROLES = {
    "shell_main": "Fixed shell layer",
    "body_with_rear": "Upper head / neck-body + rear flippers",
    "underbelly": "Lower jaw / neck / chest / abdomen",
    "front_flipper_near": "Moving part · F0 geometry",
    "front_flipper_far": "Moving part · F0 geometry",
}

MATERIAL_ORDER = {
    "geometry": 0,
    "outline": 1,
    "pattern_detail": 2,
    "shadow": 3,
    "highlight": 4,
    "base_albedo": 5,
    "palette": 6,
    "runtime": 7,
}


def read_json(path: Path) -> dict[str, Any] | None:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None
    return data if isinstance(data, dict) else None


def normalize(value: Any) -> str:
    if value is None:
        return ""
    return re.sub(r"[^a-z0-9]+", "_", str(value).lower()).strip("_")


def status_of(doc: dict[str, Any]) -> str:
    for key in ("status", "final_status", "state"):
        if key in doc:
            return str(doc[key])
    return ""


def is_active_final(doc: dict[str, Any]) -> bool:
    status = normalize(status_of(doc))
    if not status:
        return False
    if any(token in status for token in BLOCKED_STATUS):
        return False
    return "final" in status and "locked" in status


def infer_part(path: Path, doc: dict[str, Any]) -> str | None:
    explicit = normalize(
        doc.get("part_id")
        or doc.get("part")
        or doc.get("asset")
        or doc.get("display_name")
    )
    rel = "/" + path.relative_to(SHAPE_ROOT).as_posix().lower() + "/"
    haystack = explicit + " " + rel
    if "front_flipper_near" in haystack or "front flipper near" in haystack:
        return "front_flipper_near"
    if "front_flipper_far" in haystack or "front flipper far" in haystack:
        return "front_flipper_far"
    if "body_with_rear" in haystack or "body with rear" in haystack:
        return "body_with_rear"
    if "underbelly" in haystack or "belly" in haystack:
        return "underbelly"
    if "/shell/" in rel or "sea_turtle_v3_shell" in haystack:
        return "shell_main"
    return None


def infer_layer(path: Path, doc: dict[str, Any]) -> str:
    explicit = normalize(
        doc.get("material_layer")
        or doc.get("layer_id")
        or doc.get("layer")
        or doc.get("stage")
    )
    rel = path.relative_to(SHAPE_ROOT).as_posix().lower()
    value = explicit + " " + rel
    if "outline" in value:
        return "outline"
    if "pattern_detail" in value or "pattern/detail" in value or "pattern" in value:
        return "pattern_detail"
    if "shadow" in value:
        return "shadow"
    if "highlight" in value:
        return "highlight"
    if "base_albedo" in value or "albedo" in value:
        return "base_albedo"
    if "palette" in value:
        return "palette"
    if "runtime" in value:
        return "runtime"
    return "geometry"


def version_of(doc: dict[str, Any]) -> str:
    for key in ("geometry_version", "version", "baseline", "variant"):
        value = doc.get(key)
        if value not in (None, ""):
            return str(value)
    return "Final"


def approval_of(doc: dict[str, Any]) -> str | None:
    for key in (
        "approved_date",
        "approval_date",
        "closeout_verified_date",
        "selected_date",
    ):
        value = doc.get(key)
        if value:
            return str(value)
    return None


def canvas_of(doc: dict[str, Any]) -> str | None:
    canvas = doc.get("canvas") or doc.get("canonical_canvas")
    if isinstance(canvas, dict):
        w, h = canvas.get("width"), canvas.get("height")
        mode = canvas.get("mode")
        if w and h:
            return f"{w} × {h}" + (f" · {mode}" if mode else "")
    if isinstance(canvas, list) and len(canvas) >= 2:
        return f"{canvas[0]} × {canvas[1]}"
    return None


def qa_summary(doc: dict[str, Any]) -> list[dict[str, str]]:
    qa = doc.get("qa")
    if not isinstance(qa, dict):
        return []

    wanted = [
        ("recomposite_changed_pixels", "Recomposite diff"),
        ("recomposite_changed_pixels_vs_reference", "Recomposite diff"),
        ("recomposite_max_channel_diff", "Max channel diff"),
        ("asset_remainder_overlap_pixels", "Asset overlap"),
        ("asset_pixels_outside_reference_alpha", "Outside alpha"),
        ("asset_mask_support_mismatch_pixels", "Mask mismatch"),
        ("connected_component_count", "Components"),
        ("connected_components", "Components"),
        ("isolated_noise_pixels", "Isolated noise"),
        ("enclosed_hole_count", "Holes"),
        ("png_integrity", "PNG"),
        ("user_visual_approval", "Visual approval"),
    ]

    result: list[dict[str, str]] = []
    used_labels: set[str] = set()
    for key, label in wanted:
        if key not in qa or label in used_labels:
            continue
        value = qa[key]
        if isinstance(value, bool):
            value = "PASS" if value else "NO"
        result.append({"label": label, "value": str(value)})
        used_labels.add(label)
        if len(result) >= 5:
            break
    return result


def primary_score(record: dict[str, Any]) -> tuple[int, int]:
    path = record["manifest"].lower()
    layer = record["layer"]
    score = 0
    if layer == "geometry":
        score += 100
    if "/runtime/" in "/" + path:
        score -= 20
    if any(segment in path for segment in ("/outline/", "/shadow/", "/highlight/", "/pattern_detail/")):
        score -= 10
    if "manifest_final" in path:
        score += 20
    if record["status_normalized"].endswith("_active"):
        score += 10
    return score, -len(path)


def public_record(path: Path, doc: dict[str, Any], part: str) -> dict[str, Any]:
    status = status_of(doc)
    master = doc.get("authoritative_master")
    if not master and isinstance(doc.get("source"), dict):
        master = doc["source"].get("canonical_master")

    return {
        "part": part,
        "layer": infer_layer(path, doc),
        "version": version_of(doc),
        "status": status,
        "status_normalized": normalize(status),
        "approval": approval_of(doc),
        "canvas": canvas_of(doc),
        "authoritative_master": master,
        "manifest": path.relative_to(ROOT).as_posix(),
        "qa": qa_summary(doc),
    }


def build() -> dict[str, Any]:
    manifests: list[dict[str, Any]] = []
    reference_mentions: set[str] = set()

    for path in sorted(SHAPE_ROOT.rglob("*.json")):
        if "asset_book" in path.parts:
            continue
        doc = read_json(path)
        if not doc:
            continue

        raw = json.dumps(doc, ensure_ascii=False).lower()
        for part in PART_ORDER:
            if part in raw:
                reference_mentions.add(part)

        if not is_active_final(doc):
            continue
        part = infer_part(path, doc)
        if not part:
            continue
        manifests.append(public_record(path, doc, part))

    pointer = read_json(MASTER_POINTER) or {}
    active_master_names = {
        normalize(record.get("authoritative_master"))
        for record in manifests
        if record.get("authoritative_master")
    }
    pointer_master = normalize(pointer.get("authoritative_master"))
    master_current = bool(pointer_master and pointer_master in active_master_names)

    parts: list[dict[str, Any]] = []
    for part_id in PART_ORDER:
        records = [r for r in manifests if r["part"] == part_id]
        records.sort(key=primary_score, reverse=True)
        primary = records[0] if records else None
        layers = sorted(
            {r["layer"] for r in records},
            key=lambda name: (MATERIAL_ORDER.get(name, 99), name),
        )

        if primary:
            state = "Final / Locked"
            version = primary["version"]
        elif part_id in reference_mentions:
            state = "Locked reference"
            version = "Manifest normalization pending"
        else:
            state = "Not registered"
            version = "—"

        parts.append(
            {
                "id": part_id,
                "label": PART_LABELS[part_id],
                "role": PART_ROLES[part_id],
                "state": state,
                "version": version,
                "primary": primary,
                "layers": layers,
                "active_manifests": records,
            }
        )

    return {
        "schema": 1,
        "viewer": {
            "name": "MY LOCK Asset Book",
            "source_of_truth": False,
            "sync_rule": "Generated at web build from repository Production manifests.",
            "privacy_rule": "Private Drive URLs and file IDs are excluded from the public payload.",
        },
        "shape": {
            "id": "sea_turtle_v3",
            "name": "Sea Turtle v3",
            "drop": "Drop 01 · 작은 바닷속",
            "selection": "02 Long Flipper",
            "authoritative_master": pointer.get("authoritative_master", "Q3 Canonical Master"),
            "canonical_filename": pointer.get("canonical_filename"),
            "canvas": "2048 × 2048 · RGBA",
            "master_pointer_current": master_current,
        },
        "parts": parts,
        "stats": {
            "active_manifest_count": len(manifests),
            "final_part_count": sum(1 for p in parts if p["primary"]),
            "locked_reference_count": sum(1 for p in parts if p["state"] == "Locked reference"),
        },
    }


def main() -> None:
    BOOK_DIR.mkdir(parents=True, exist_ok=True)
    payload = build()
    encoded = json.dumps(payload, ensure_ascii=False, indent=2)
    OUTPUT.write_text(
        "window.MYLOCK_ASSET_BOOK_DATA = " + encoded + ";\n",
        encoding="utf-8",
    )
    print(
        "Asset Book data generated: "
        f"{payload['stats']['active_manifest_count']} active manifests, "
        f"{payload['stats']['final_part_count']} primary parts"
    )


if __name__ == "__main__":
    main()
