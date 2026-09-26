#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "assets/shape_masters/drop01/sea_turtle_v2"

EXPECTED = {
    "sea_turtle_master_v2_512.png": "42b1bdcc353f478e8e384c49223264ca98ea696982218495b53ffdb36d4a69b4",
    "masks/master_alpha.png": "8cfa7a7025df4a3d899fc770d626c1f5ba80c95ce5d4003320feb4faf2f1c6b7",
    "masks/outline_mask.png": "6b5f90c34329731d87cd56b760fce31829a8fce67fe2e8665f87cd57c5292d0a",
    "masks/shell_detail_mask.png": "c7dd1b9834b7c503801a1c839c014808e46cf7471a56c65ae628dc3a9859ee1e",
    "masks/shell_mask.png": "17180bb5271209c72ea1ced2c34d186837651b0c13de389d24acc511e7ed01ca",
    "masks/underbelly_mask.png": "76e378788f4317fbb14f0f09be47b41dea28ed289eb89fa1afe5b65401abfe77",
    "overlays/highlight_overlay.png": "22dae382d327367f81cd192c481ca8cd1a1f7c055f55d4202d395cae4b3081fe",
    "overlays/shadow_overlay.png": "6f67d70bf372007411197d83dec0101b8a632a1409aa686820f18d82fe769208",
}

ALIASES = {
    "sea_turtle_master_v2_512.png": "master/sea_turtle_master_v2_512.png",
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("pack", type=Path, help="Extracted sea_turtle_pack_v2 directory")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    pack = args.pack.resolve()
    if not pack.is_dir():
        raise SystemExit(f"pack not found: {pack}")

    copies: list[tuple[Path, Path]] = []
    for source_rel, expected_sha in EXPECTED.items():
        source = pack / source_rel
        if not source.is_file():
            raise SystemExit(f"missing source: {source_rel}")
        actual = digest(source)
        if actual != expected_sha:
            raise SystemExit(
                f"SHA mismatch: {source_rel}\n"
                f" expected {expected_sha}\n actual   {actual}"
            )
        target_rel = ALIASES.get(source_rel, source_rel)
        target = TARGET / target_rel
        copies.append((source, target))

    if args.dry_run:
        print("[sea-turtle-import] PASS dry-run")
        for source, target in copies:
            print(f"- {source.relative_to(pack)} -> {target.relative_to(ROOT)}")
        return

    for source, target in copies:
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)

    print("[sea-turtle-import] PASS")
    print(f"- imported {len(copies)} source PNGs")
    print(f"- target: {TARGET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
