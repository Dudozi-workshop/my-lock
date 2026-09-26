#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "assets/shape_masters/drop01/sea_turtle_v2/spec.json"
RUNTIME = ROOT / "assets/sea_turtle_runtime_v2"
SHAPE_LAB = ROOT / "shape_lab/main.dart"

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

FORBIDDEN_SHAPE_LOCAL_MOTION = (
    "6-Key Swim Motion Lab",
    "_SeaTurtleMotionPreset",
    "_SeaTurtleMotionCard",
    "_SeaTurtlePoseAsset",
    "_SeaTurtleFramePartClipper",
    "_SeaTurtleFrameBaseClipper",
    "_motionElapsedSeconds",
    "_motionPlaying",
    "3-Frame Swim PoC",
    "Flipper animation",
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
        fail("Sea Turtle master version must remain v2 until explicitly promoted")
    if spec.get("geometryPolicy") != "source_locked_no_redraw":
        fail("geometry policy changed")
    if spec.get("motion", {}).get("enabled") is not False:
        fail("shape-local motion must stay disabled")

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
    residues = [token for token in FORBIDDEN_SHAPE_LOCAL_MOTION if token in lab]
    if residues:
        fail("shape-local motion residue found: " + ", ".join(residues))

    required_runtime_text = (
        "Shape 자체 Motion 없음",
        "FloatingEngine",
        "_SeaTurtleStaticAsset",
    )
    missing = [token for token in required_runtime_text if token not in lab]
    if missing:
        fail("static runtime ownership marker missing: " + ", ".join(missing))

    print("[sea-turtle-master] PASS")
    print("- Geometry: source_locked_no_redraw")
    print("- Region tokens: main / underbelly / deep / detail / outline")
    print("- Shape-local motion: disabled")
    print("- Derived runtime QA PNGs: byte size + SHA-256 verified")


if __name__ == "__main__":
    main()
