# Candy Soft · approved direction / runtime review candidate

User accepted the vivid pink circle, sunny yellow rounded triangle and blue
rounded square on 2026-10-03 KST. Preserve plump volume, smooth same-hue shading
and a broad upper-left highlight. Earlier pastel B is superseded.

The original generated 2172×724 RGBA atlas is preserved byte-for-byte. Three
metadata files describe independent 724×724 source slots, anchors, alpha bounds,
padding and the shared source hash. Rendering uses drawImageRect; source pixels
are neither repainted nor cleaned during this review gate.

Compile with `--dart-define=CANDY_SOFT_CANDIDATE=true` and open
`?qa=candy-soft`. This uses the actual ShapeChoiceCard, LockTokenPainter,
ShapeSpecRenderer, FloatingPreview and RasterShapeBootstrap. The same enabled
painter is shared with Android lockMain. Default builds leave the candidate off.

Only circle/pink, triangle/yellow and square/blue have approved source colors.
Other tones fall back to the existing vector renderer; Crayon always retains its
existing renderer. Never recolor password identity to match an authored swatch.
No vector geometry, Turtle master, locked part or existing ShapeSpec is edited.

## QA and remaining gate

- PNG dimensions and source-slot edge alpha are verified by Flutter decode tests.
- Candidate test checks rotation, transparency and unsupported-tone/Crayon fallback.
- CI builds actual Web and Android entry points; build success is not visual QA.
- Generated alpha contains faint peripheral pixels. Edge cleanup, optical mass,
  and rotation/POP appearance still require review; zero canvas-edge alpha alone
  does not establish production-quality transparency.
- This is an atlas review source, **not** a finished 256px runtime master.
- Next: visual component review → deterministic independent padded 256px assets
  → preserved finish/palette control → all shape×tone QA → production promotion.
- Local Flutter verification was blocked by automatic approval review after an
  unexpected cloud instance-metadata request. No local retry was attempted.
- Material category removal and shape-plus-style product packaging remain discussion
  topics. This change does not alter catalog economics or user password settings.

Status: Candidate / Not Final / Not Locked / no production deployment.
