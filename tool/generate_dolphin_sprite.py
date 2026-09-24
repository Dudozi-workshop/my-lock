from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "shapes" / "dolphin"
OUT = ROOT / "assets" / "shapes" / "dolphin_sprite"
OUT.mkdir(parents=True, exist_ok=True)

SIZE = 512


def load_mask(name: str) -> Image.Image:
    image = Image.open(SRC / name).convert("RGBA").resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    alpha = image.getchannel("A")
    return alpha


BODY = load_mask("dolphin_body.png")
MOUTH = load_mask("dolphin_mouth_accent.png")
BELLY = load_mask("dolphin_belly_accent.png")


def solid(color: tuple[int, int, int, int]) -> Image.Image:
    return Image.new("RGBA", (SIZE, SIZE), color)


def ellipse_mask(box: tuple[int, int, int, int], blur: float) -> Image.Image:
    m = Image.new("L", (SIZE, SIZE), 0)
    d = ImageDraw.Draw(m)
    d.ellipse(box, fill=255)
    if blur > 0:
        m = m.filter(ImageFilter.GaussianBlur(blur))
    return m


def directional_mask(top: int, bottom: int) -> Image.Image:
    ramp = Image.new("L", (1, SIZE))
    px = ramp.load()
    for y in range(SIZE):
        if y <= top:
            v = 0
        elif y >= bottom:
            v = 255
        else:
            v = int((y - top) / max(1, bottom - top) * 255)
        px[0, y] = v
    return ramp.resize((SIZE, SIZE), Image.Resampling.BILINEAR)


def masked_layer(color, mask: Image.Image) -> Image.Image:
    layer = solid(color)
    layer.putalpha(mask)
    return layer


def compose_sprite(
    base: tuple[int, int, int],
    highlight: tuple[int, int, int],
    shadow: tuple[int, int, int],
    rim: tuple[int, int, int],
    accent: tuple[int, int, int],
) -> Image.Image:
    out = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

    # Soft baked glow outside the silhouette.
    expanded = BODY.filter(ImageFilter.GaussianBlur(13))
    glow_alpha = expanded.point(lambda p: int(p * 0.24))
    out = Image.alpha_composite(out, masked_layer((*rim, 255), glow_alpha))

    # Base body.
    out = Image.alpha_composite(out, masked_layer((*base, 255), BODY))

    # Broad top-left light.
    top_light = ellipse_mask((90, 74, 372, 286), 24)
    top_light = ImageChops.multiply(top_light, BODY).point(lambda p: int(p * 0.56))
    out = Image.alpha_composite(out, masked_layer((*highlight, 255), top_light))

    # Lower/rear form shadow.
    lower = directional_mask(230, 480)
    rear = Image.new("L", (SIZE, SIZE), 0)
    rd = ImageDraw.Draw(rear)
    rd.rectangle((250, 0, SIZE, SIZE), fill=220)
    rear = rear.filter(ImageFilter.GaussianBlur(70))
    form_shadow = ImageChops.lighter(lower, rear)
    form_shadow = ImageChops.multiply(form_shadow, BODY).point(lambda p: int(p * 0.36))
    out = Image.alpha_composite(out, masked_layer((*shadow, 255), form_shadow))

    # Local AO around fin roots/tail neck.
    ao = Image.new("L", (SIZE, SIZE), 0)
    ad = ImageDraw.Draw(ao)
    ad.ellipse((252, 278, 345, 316), fill=110)
    ad.ellipse((308, 302, 377, 334), fill=94)
    ad.ellipse((380, 270, 430, 318), fill=88)
    ao = ao.filter(ImageFilter.GaussianBlur(14))
    ao = ImageChops.multiply(ao, BODY)
    out = Image.alpha_composite(out, masked_layer((*shadow, 255), ao))

    # Accent regions are baked into the art asset.
    belly_fill = masked_layer((*accent, 230), BELLY.point(lambda p: int(p * 0.88)))
    mouth_fill = masked_layer((*highlight, 245), MOUTH.point(lambda p: int(p * 0.94)))
    out = Image.alpha_composite(out, belly_fill)
    out = Image.alpha_composite(out, mouth_fill)

    # Inner rim.
    eroded = BODY.filter(ImageFilter.MinFilter(9))
    inner_rim = ImageChops.subtract(BODY, eroded).filter(ImageFilter.GaussianBlur(1.2))
    inner_rim = inner_rim.point(lambda p: int(p * 0.52))
    out = Image.alpha_composite(out, masked_layer((*highlight, 255), inner_rim))

    # Large low-frequency speculars; these survive downsampling to lock size.
    spec = ellipse_mask((166, 112, 332, 174), 8)
    spec = ImageChops.multiply(spec, BODY).point(lambda p: int(p * 0.68))
    out = Image.alpha_composite(out, masked_layer((255, 255, 255, 255), spec))

    spec2 = ellipse_mask((315, 160, 375, 187), 5)
    spec2 = ImageChops.multiply(spec2, BODY).point(lambda p: int(p * 0.26))
    out = Image.alpha_composite(out, masked_layer((255, 255, 255, 255), spec2))

    return out


def split_body_tail(sprite: Image.Image) -> tuple[Image.Image, Image.Image]:
    # Split around the tail neck with a complementary 28 px feather.
    body_gate = Image.new("L", (SIZE, SIZE), 255)
    tail_gate = Image.new("L", (SIZE, SIZE), 0)
    bp = body_gate.load()
    tp = tail_gate.load()
    start, end = 350, 378
    for x in range(SIZE):
        if x < start:
            b, t = 255, 0
        elif x > end:
            b, t = 0, 255
        else:
            t = int((x - start) / (end - start) * 255)
            b = 255 - t
        for y in range(SIZE):
            bp[x, y] = b
            tp[x, y] = t

    alpha = sprite.getchannel("A")
    body_alpha = ImageChops.multiply(alpha, body_gate)
    tail_alpha = ImageChops.multiply(alpha, tail_gate)

    body = sprite.copy()
    body.putalpha(body_alpha)
    tail = sprite.copy()
    tail.putalpha(tail_alpha)
    return body, tail


PALETTES = {
    "blue": {
        "base": (45, 150, 246),
        "highlight": (205, 244, 255),
        "shadow": (25, 70, 178),
        "rim": (102, 226, 255),
        "accent": (154, 220, 255),
    },
    "pink": {
        "base": (246, 112, 177),
        "highlight": (255, 225, 242),
        "shadow": (173, 54, 118),
        "rim": (255, 176, 220),
        "accent": (255, 194, 226),
    },
}

for name, p in PALETTES.items():
    full = compose_sprite(**p)
    body, tail = split_body_tail(full)
    full.save(OUT / f"dolphin_{name}_glossy.webp", "WEBP", lossless=True, method=6)
    body.save(OUT / f"dolphin_{name}_glossy_body.webp", "WEBP", lossless=True, method=6)
    tail.save(OUT / f"dolphin_{name}_glossy_tail.webp", "WEBP", lossless=True, method=6)

# Small contact sheet for CI artifact inspection.
preview = Image.new("RGBA", (SIZE * 2, SIZE), (11, 23, 43, 255))
preview.alpha_composite(Image.open(OUT / "dolphin_blue_glossy.webp").convert("RGBA"), (0, 0))
preview.alpha_composite(Image.open(OUT / "dolphin_pink_glossy.webp").convert("RGBA"), (SIZE, 0))
preview.save(OUT / "dolphin_sprite_poc_preview.png")
print(f"Generated sprite assets in {OUT}")
