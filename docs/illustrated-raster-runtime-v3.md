# Illustrated Raster Runtime v3 — Sea Turtle Candidate, 2026-10-02

Status: **QA Candidate. User visual approval pending. Not Final / Locked.**

## Source and framing
- Q3 Whole Assembly remains locked: SHA256 `73f3e583d99d1e9405f54a44862c8c55dda49c464eccd5b73e529b8fab309e4c`.
- All five locked canonical Part hashes were checked before assembly. The (0,0) assembly reproduces the recorded Whole PNG hash with Pillow optimize=True.
- Deterministic whole-only framing: canonical square crop `[420,464,1640,1684]` → Lanczos 192px content → 256px padded RGBA lossless WebP.
- Content bbox `[32,65,224,191]`; anchor `[128,128]`; minimum safety padding 32px (12.5% per side); source alpha never touches the canvas edge.
- 58px is display/readability QA only. Legacy v1/v2 58px assets are preserved as history and no longer loaded by production.
- `assets/raster_shapes/sea_turtle_v3_runtime_v3.json` owns framing. Renderer derives canvas placement from bbox, anchor and display_scale; no ShapeKind-specific visualScale.

## Two optical runtime layers
1. Palette Base: optical albedo/support, recolored using srcIn for Pink/Blue/Yellow or the animated Aurora field.
2. Fixed Finish: fixed achromatic optical density retaining the authored luminance pattern, outline, shading, highlights and details.

This is **runtime optical factorization**, not a new semantic Material ownership decomposition. The locked canonical Base/Albedo, Outline, Shadow, Highlight and Detail masks/assets are untouched. The finish is deterministically derived from approved Whole luminance with reference albedo 0.70. Dark samples become black optical density; bright samples become white optical density. Reference reconstruction maximum luminance error is 0.001372 (less than one 8-bit step). It does not claim byte-identical RGB reconstruction or semantic-mask equivalence.

The base uses opaque support; the true master alpha is applied **once after both layers**, preventing compounded edge alpha and rectangular palette fill. No whole-raster BlendMode.color recolor. Opacity/rotation/POP are applied to the composed token.

## Aurora Sea
- Same ShapeTone identity, settings serialization, registry and renderer path as static palettes.
- Blue/Pink/Yellow/Purple 2D gradient, 8-second smooth periodic phase, saturation multiplier 0.55, lightness 0.73.
- RasterShapeBootstrap drives one monotonic palette clock per Flutter engine. Static LockTokenPainter cards repaint from the same clock; FloatingPreview uses the same phase.
- The field is composited using drawPaint + srcIn directly on Palette Base (no separate rotated gradient rectangle/saveLayer, which failed the crop-border regression). Field moves in local texture coordinates; Fixed Finish never receives the palette shader.
- Shape alpha clips all palette output. No background animation, frame/image regeneration or canonical modifications.
- Existing vector geometries/styles and free defaults remain unchanged. Animated Aurora support in this gate is implemented for Sea Turtle; vector tokens retain their existing static renderer.

## Production verification
- Shared path: Main App / Customize / Shop / FloatingPreview / LockTokenPainter / Android LockActivity `lockMain` → RasterShapeBootstrap → ShapeSpecRegistry → metadata-driven 2-layer raster renderer.
- Route: `?qa=sea-turtle-runtime-v3` (also replaces existing app-integration QA route).
- Actual ShapeChoiceCard, actual LockTokenPainter, actual FloatingPreview (6/9/12 objects, respawn and tap POP), and actual LockModeScreen with isolated in-memory QA settings. QA never overwrites the user's password.
- Automated pixel tests: 256px master padding, metadata 58px framing, static-palette time invariance, Aurora color variation + 8s loop, alpha invariance, rotation and maximum 1.42 POP scale.
- Android APK compilation confirms entry-point integration; physical Android LockActivity behavior requires separate device QA. Never label this as physical-device PASS solely from CI.

## Promotion
Build/deploy/pixel tests and user visual approval are distinct gates. Keep Candidate status until the user explicitly approves. No geometry/material/ownership/master modification is authorized.
