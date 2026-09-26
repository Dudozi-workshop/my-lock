#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "assets/shape_masters/drop01/sea_turtle_v2/spec.json"
V3_SPEC = ROOT / "assets/shape_masters/drop01/sea_turtle_v3/spec.json"
RUNTIME = ROOT / "assets/sea_turtle_runtime_v2"
SHAPE_LAB = ROOT / "shape_lab/main.dart"

SOURCE_ROOT = ROOT / "assets/shape_masters/drop01/sea_turtle_v2"

EXPECTED_SOURCE = {
    "master/sea_turtle_master_v2_512.png": {
        "size": 160609,
        "sha256": "42b1bdcc353f478e8e384c49223264ca98ea696982218495b53ffdb36d4a69b4",
    },
    "masks/master_alpha.png": {
        "size": 11784,
        "sha256": "8cfa7a7025df4a3d899fc770d626c1f5ba80c95ce5d4003320feb4faf2f1c6b7",
    },
    "masks/outline_mask.png": {
        "size": 6634,
        "sha256": "6b5f90c34329731d87cd56b760fce31829a8fce67fe2e8665f87cd57c5292d0a",
    },
    "masks/shell_detail_mask.png": {
        "size": 3883,
        "sha256": "c7dd1b9834b7c503801a1c839c014808e46cf7471a56c65ae628dc3a9859ee1e",
    },
    "masks/shell_mask.png": {
        "size": 5629,
        "sha256": "17180bb5271209c72ea1ced2c34d186837651b0c13de389d24acc511e7ed01ca",
    },
    "masks/underbelly_mask.png": {
        "size": 2600,
        "sha256": "76e378788f4317fbb14f0f09be47b41dea28ed289eb89fa1afe5b65401abfe77",
    },
    "overlays/highlight_overlay.png": {
        "size": 32647,
        "sha256": "22dae382d327367f81cd192c481ca8cd1a1f7c055f55d4202d395cae4b3081fe",
    },
    "overlays/shadow_overlay.png": {
        "size": 45449,
        "sha256": "6f67d70bf372007411197d83dec0101b8a632a1409aa686820f18d82fe769208",
    },
}

EXPECTED_RUNTIME = {
    "sea_turtle_blue.png": {
        "size": 7944,
        "sha256": "28277817d4c699ededf41d7156c4fd0a14e701b68dde5ac41415f95396afcc8d",
    },
    "sea_turtle_pink.png": {
        "size": 7913,
        "sha256": "0124894586549664328c7872974a44d9281b1d899c149a50754d29ea52e22d20",
    },
    "sea_turtle_yellow.png": {
        "size": 7948,
        "sha256": "780cefb061a917aa6df35780e195751f7c716359b02e7515a109c942edf8188b",
    },
}

FORBIDDEN_LEGACY_ANIMATION = (
    "6-Key Swim Motion Lab",
    "_SeaTurtleMotionPreset",
    "_SeaTurtleMotionCard",
    "_SeaTurtlePoseAsset",
    "_SeaTurtleFramePartClipper",
    "_SeaTurtleFrameBaseClipper",
    "_motionElapsedSeconds",
    "_motionPlaying",
    "3-Frame Swim PoC",
)


def fail(message: str) -> None:
    raise SystemExit(f"[sea-turtle-master] {message}")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    if not SPEC.is_file():
        fail(f"missing spec: {SPEC.relative_to(ROOT)}")

    spec = json.loads(SPEC.read_text(encoding="utf-8"))

    if spec.get("shapeId") != "d1_s02_sea_turtle":
        fail("unexpected shapeId")
    if spec.get("version") != 2:
        fail("v2 reference spec must remain version 2")
    if spec.get("geometryPolicy") != "source_locked_no_redraw":
        fail("geometry policy changed")
    shape_animation = spec.get("shapeAnimation", {})
    if shape_animation.get("enabled") is not True:
        fail("Shape Animation must stay enabled for the high-grade Sea Turtle")
    if shape_animation.get("terminology") != "Shape Animation":
        fail("shape-local articulation must be named Shape Animation")
    if "front_flippers" not in shape_animation.get("affects", []):
        fail("Sea Turtle Shape Animation must own front-flipper articulation")

    motion_owner = spec.get("motionSetOwnership", {})
    if motion_owner.get("owner") != "FloatingEngine":
        fail("Motion Set ownership must remain with FloatingEngine")
    if motion_owner.get("independentFromShapeAnimation") is not True:
        fail("Motion Set and Shape Animation must remain independent")

    palette_policy = spec.get("palettePolicy", {})
    if palette_policy.get("runtimePaletteSource") != "ShapeTone":
        fail("runtime palette source must remain ShapeTone")
    if set(palette_policy.get("allowedRuntimeTones", [])) != {"pink", "blue", "yellow"}:
        fail("Sea Turtle runtime tones must match the current app palette")
    if palette_policy.get("customPerShapeColors") is not False:
        fail("Sea Turtle-only custom colors are not allowed")

    layers = {layer["id"]: layer for layer in spec.get("layers", [])}
    expected_tokens = {
        "master_alpha": "main",
        "underbelly": "underbelly",
        "shell": "deep",
        "shell_detail": "detail",
        "outline": "outline",
    }
    for layer_id, token in expected_tokens.items():
        if layers.get(layer_id, {}).get("token") != token:
            fail(f"layer token mismatch: {layer_id}")

    source_present = []
    source_missing = []
    for relative, expected in EXPECTED_SOURCE.items():
        path = SOURCE_ROOT / relative
        if not path.is_file():
            source_missing.append(relative)
            continue
        source_present.append(relative)
        if path.stat().st_size != expected["size"]:
            fail(f"source size mismatch: {relative}")
        digest = sha256(path)
        if digest != expected["sha256"]:
            fail(f"source SHA-256 mismatch: {relative}")

    if source_present and source_missing:
        fail(
            "partial Sea Turtle source pack detected; missing: "
            + ", ".join(source_missing)
        )

    for name, expected in EXPECTED_RUNTIME.items():
        path = RUNTIME / name
        if not path.is_file():
            fail(f"missing derived runtime QA asset: {path.relative_to(ROOT)}")
        if path.stat().st_size != expected["size"]:
            fail(f"size mismatch: {name}")
        digest = sha256(path)
        if digest != expected["sha256"]:
            fail(f"SHA-256 mismatch: {name}")

    lab = SHAPE_LAB.read_text(encoding="utf-8")
    residues = [token for token in FORBIDDEN_LEGACY_ANIMATION if token in lab]
    if residues:
        fail("legacy Sea Turtle animation residue found: " + ", ".join(residues))

    # v3 Canonical preparation intentionally keeps the runtime at neutral F0.
    # Do not require the old Shape Animation comparison UI before Static Master Lock.
    required_runtime_text = (
        "v3 Canonical Draft 준비",
        "앞지느러미 Shape Animation 분리",
        "FloatingEngine",
        "_SeaTurtleStaticAsset",
    )
    missing = [token for token in required_runtime_text if token not in lab]
    if missing:
        fail("current Sea Turtle ownership marker missing: " + ", ".join(missing))

    if not V3_SPEC.is_file():
        fail(f"missing v3 draft spec: {V3_SPEC.relative_to(ROOT)}")
    v3 = json.loads(V3_SPEC.read_text(encoding="utf-8"))
    if v3.get("version") != 3:
        fail("Sea Turtle canonical draft spec must be version 3")
    if v3.get("status") != "canonical_2048_draft_f0_part_split":
        fail("unexpected v3 canonical draft status")
    canvas = v3.get("canvas", {})
    if canvas.get("width") != 2048 or canvas.get("height") != 2048 or canvas.get("transparent") is not True:
        fail("v3 canonical canvas must be 2048x2048 transparent")
    isolation = v3.get("movingPartIsolation", {})
    if isolation.get("policy") != "moving_part_owns_visual_maps":
        fail("v3 moving-part ownership policy changed")
    if set(isolation.get("maps", [])) != {"alpha", "outline", "shadow", "highlight"}:
        fail("v3 moving-part visual maps must be alpha/outline/shadow/highlight")
    animation = v3.get("animation", {})
    if animation.get("implemented") is not False:
        fail("v3 animation must remain unimplemented until Static Master Lock")
    qa = v3.get("qa", {})
    if qa.get("f0RebuildMaxChannelDiff") != 0 or qa.get("f0RebuildChangedChannelCount") != 0:
        fail("v3 F0 rebuild QA must remain exact")

    print("[sea-turtle-master] PASS")
    print("- Geometry: source_locked_no_redraw")
    print("- Region tokens: main / underbelly / deep / detail / outline")
    print("- Shape Animation: front-flipper ownership defined; implementation deferred until Static Master Lock")
    print("- Motion Set: whole-shape movement remains owned by FloatingEngine")
    print("- v3 Canonical Draft: 2048x2048 transparent / F0 exact rebuild QA locked")
    print("- Palette: ShapeTone Pink / Blue / Yellow only")
    if source_present:
        print("- Source pack: complete; byte size + SHA-256 verified")
    else:
        print("- Source pack: not yet committed; metadata/checksums locked")
    print("- Derived runtime QA PNGs: byte size + SHA-256 verified")


if __name__ == "__main__":
    main()
