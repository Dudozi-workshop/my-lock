#!/usr/bin/env python3
import base64
import json
import struct
import sys
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC_ROOT = ROOT / "assets" / "shape_specs" / "soft_basic"
CIRCLE_SPEC = SPEC_ROOT / "circle.json"
PNG_SIG = b"\x89PNG\r\n\x1a\n"


def read_b64_png(path: Path) -> bytes:
    raw = path.read_text(encoding="utf-8").strip()
    try:
        data = base64.b64decode(raw, validate=True)
    except Exception as exc:
        raise AssertionError(f"{path}: invalid base64: {exc}") from exc
    return data


def parse_png(path: Path, data: bytes):
    if not data.startswith(PNG_SIG):
        raise AssertionError(f"{path}: invalid PNG signature")
    pos = 8
    saw_ihdr = False
    saw_iend = False
    width = height = bit_depth = color_type = None
    while pos < len(data):
        if pos + 12 > len(data):
            raise AssertionError(f"{path}: truncated PNG chunk header")
        length = struct.unpack(">I", data[pos:pos+4])[0]
        chunk_type = data[pos+4:pos+8]
        end = pos + 12 + length
        if end > len(data):
            raise AssertionError(
                f"{path}: truncated PNG chunk {chunk_type!r}; "
                f"declared={length}, remaining={len(data)-pos-12}"
            )
        chunk_data = data[pos+8:pos+8+length]
        stored_crc = struct.unpack(">I", data[pos+8+length:end])[0]
        calc_crc = zlib.crc32(chunk_type + chunk_data) & 0xFFFFFFFF
        if stored_crc != calc_crc:
            raise AssertionError(f"{path}: CRC mismatch in {chunk_type.decode('ascii', 'replace')}")
        if chunk_type == b"IHDR":
            if length != 13:
                raise AssertionError(f"{path}: invalid IHDR length {length}")
            width, height, bit_depth, color_type = struct.unpack(">IIBB", chunk_data[:10])
            saw_ihdr = True
        elif chunk_type == b"IEND":
            saw_iend = True
            if length != 0:
                raise AssertionError(f"{path}: invalid IEND length")
            if end != len(data):
                raise AssertionError(f"{path}: trailing bytes after IEND")
            break
        pos = end

    if not saw_ihdr or not saw_iend:
        raise AssertionError(f"{path}: incomplete PNG (IHDR/IEND missing)")
    if (width, height) != (128, 128):
        raise AssertionError(f"{path}: expected 128x128, got {width}x{height}")
    if bit_depth != 8 or color_type != 6:
        raise AssertionError(
            f"{path}: expected 8-bit RGBA PNG (color type 6), "
            f"got bit_depth={bit_depth}, color_type={color_type}"
        )


def main():
    spec = json.loads(CIRCLE_SPEC.read_text(encoding="utf-8"))
    errors = []
    checked = []
    for layer in spec["layers"]:
        geom = layer["geometry"]
        if geom.get("kind") != "mask":
            continue
        rel = Path(geom["asset"])
        path = ROOT / rel
        try:
            data = read_b64_png(path)
            parse_png(path, data)
            checked.append(str(rel))
        except Exception as exc:
            errors.append(str(exc))

    if errors:
        print("Shape mask validation FAILED:", file=sys.stderr)
        for err in errors:
            print(f" - {err}", file=sys.stderr)
        return 1

    print(f"Shape mask validation OK: {len(checked)} assets")
    for item in checked:
        print(f" - {item}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
