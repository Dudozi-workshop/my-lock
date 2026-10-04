#!/usr/bin/env python3
import hashlib
import json
import struct
import sys
from pathlib import Path


def webp_size(data: bytes) -> tuple[int, int]:
    if len(data) < 30 or data[:4] != b"RIFF" or data[8:12] != b"WEBP":
        raise ValueError("invalid RIFF/WEBP signature")
    declared = struct.unpack_from("<I", data, 4)[0] + 8
    if declared != len(data):
        raise ValueError(f"RIFF size mismatch: header={declared} actual={len(data)}")

    chunk = data[12:16]
    if chunk == b"VP8 ":
        if data[23:26] != b"\x9d\x01\x2a":
            raise ValueError("invalid VP8 frame signature")
        width = struct.unpack_from("<H", data, 26)[0] & 0x3FFF
        height = struct.unpack_from("<H", data, 28)[0] & 0x3FFF
        return width, height
    if chunk == b"VP8L":
        bits = int.from_bytes(data[21:25], "little")
        return (bits & 0x3FFF) + 1, ((bits >> 14) & 0x3FFF) + 1
    if chunk == b"VP8X":
        width = 1 + int.from_bytes(data[24:27], "little")
        height = 1 + int.from_bytes(data[27:30], "little")
        return width, height
    raise ValueError(f"unsupported WEBP chunk {chunk!r}")


def main() -> int:
    registry_path = Path("assets/backgrounds/drop01/ASSET_REGISTRY.json")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    failures: list[str] = []

    for item in registry["active_backgrounds"]:
        runtime = item.get("runtime_ref")
        integrity = item.get("expected_integrity")
        if not item.get("active_for_lab") or not runtime or not integrity:
            continue

        path = Path(runtime["path"])
        if not path.is_file():
            failures.append(f"{item['asset_id']}: missing runtime file {path}")
            continue

        data = path.read_bytes()
        actual_hash = hashlib.sha256(data).hexdigest()
        if len(data) != integrity["byte_size"]:
            failures.append(
                f"{item['asset_id']}: byte_size expected={integrity['byte_size']} actual={len(data)}"
            )
        if actual_hash != integrity["sha256"]:
            failures.append(
                f"{item['asset_id']}: sha256 expected={integrity['sha256']} actual={actual_hash}"
            )

        try:
            width, height = webp_size(data)
        except Exception as exc:
            failures.append(f"{item['asset_id']}: decode/header validation failed: {exc}")
            continue

        if (width, height) != (integrity["width"], integrity["height"]):
            failures.append(
                f"{item['asset_id']}: dimensions expected={integrity['width']}x{integrity['height']} actual={width}x{height}"
            )

    if failures:
        print("BACKGROUND ASSET INTEGRITY: FAIL")
        for failure in failures:
            print(" -", failure)
        return 1

    print("BACKGROUND ASSET INTEGRITY: PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
