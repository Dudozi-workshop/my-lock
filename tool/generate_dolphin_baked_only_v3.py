#!/usr/bin/env python3
"""Generate MY LOCK baked-only dolphin color assets from the current master.

The source master is the existing Tripo-derived baked WebP embedded in
lib/lock_engine/dolphin_tripo_baked_data.dart. All tone variants preserve the
same silhouette, highlights, belly accent and camera angle.
"""

from __future__ import annotations

import base64
import colorsys
import re
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "lib" / "lock_engine" / "dolphin_tripo_baked_data.dart"
OUTPUT = ROOT / "assets" / "shapes" / "dolphin_baked_v3"

TONES = {
    "pink": "#FF8CCB",
    "blue": "#7DD3FF",
    "yellow": "#FFD76B",
    "purple": "#C7A6FF",
    "mint": "#7EF0D2",
    "black": "#39445A",
    "white": "#EEF7FF",
}


def _master() -> Image.Image:
    text = SOURCE.read_text(encoding="utf-8")
    match = re.search(
        r"kDolphinTripoBakedWebpBase64\s*=\s*r'''(.*?)'''",
        text,
        flags=re.S,
    )
    if match is None:
        raise RuntimeError("Unable to locate baked Tripo master data")

    raw = base64.b64decode(match.group(1))
    from io import BytesIO

    return Image.open(BytesIO(raw)).convert("RGBA")


def _recolor(master: Image.Image, hex_color: str, tone: str) -> Image.Image:
    tr = int(hex_color[1:3], 16) / 255.0
    tg = int(hex_color[3:5], 16) / 255.0
    tb = int(hex_color[5:7], 16) / 255.0
    target_h, target_s, _ = colorsys.rgb_to_hsv(tr, tg, tb)

    output = Image.new("RGBA", master.size)
    src = master.load()
    dst = output.load()

    for y in range(master.height):
        for x in range(master.width):
            r, g, b, a = src[x, y]
            if a == 0:
                dst[x, y] = (0, 0, 0, 0)
                continue

            rf, gf, bf = r / 255.0, g / 255.0, b / 255.0
            _, saturation, value = colorsys.rgb_to_hsv(rf, gf, bf)

            # The master has a pale-blue body and near-white belly/highlights.
            # Recolor only the material region so those white accents stay put.
            blue_score = max(0.0, (bf - rf) * 1.8 + (bf - gf) * 0.6)
            material = max(saturation, blue_score)
            weight = max(0.0, min(1.0, (material - 0.055) / 0.22))
            if value > 0.90 and saturation < 0.16:
                weight *= 0.60

            if tone == "black":
                target_value = min(0.78, 0.18 + 0.46 * (value ** 1.6))
                rr, gg, bb = colorsys.hsv_to_rgb(
                    target_h,
                    0.35 + 0.25 * weight,
                    target_value,
                )
            elif tone == "white":
                target_value = min(1.0, 0.76 + 0.24 * value)
                rr, gg, bb = colorsys.hsv_to_rgb(
                    target_h,
                    0.06 + 0.05 * weight,
                    target_value,
                )
            else:
                target_saturation = min(
                    0.78,
                    max(saturation * 0.90, target_s * 0.58),
                )
                rr, gg, bb = colorsys.hsv_to_rgb(
                    target_h,
                    target_saturation,
                    value,
                )

            nr = rf * (1.0 - weight) + rr * weight
            ng = gf * (1.0 - weight) + gg * weight
            nb = bf * (1.0 - weight) + bb * weight
            dst[x, y] = (
                round(nr * 255),
                round(ng * 255),
                round(nb * 255),
                a,
            )

    return output


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    master = _master()

    for tone, color in TONES.items():
        image = _recolor(master, color, tone)
        image.save(
            OUTPUT / f"dolphin_{tone}.webp",
            "WEBP",
            quality=90,
            method=6,
        )

    print(f"Generated {len(TONES)} baked-only dolphin assets in {OUTPUT}")


if __name__ == "__main__":
    main()
