# MY LOCK — Sea Turtle Master v2

Drop 01 / S02 Sea Turtle / Long Flipper.

## Source-of-truth policy
- Geometry is source-locked. Do not redraw the silhouette after Geometry Lock.
- Runtime appearance is generated from semantic Region Masks + Palette Tokens + neutral overlays.
- The three files under `assets/sea_turtle_runtime_v2/` are baked runtime QA references, not the master source.
- Runtime colors must come from the app `ShapeTone` palette only. Current allowed tones are Pink, Blue and Yellow; do not introduce Sea-Turtle-only custom colors.
- Runtime size is dynamic from FloatingEngine. 58 px is not the design target; 64/72/80/96 px are downscale QA checkpoints.
- Outline color is a palette token, not a fixed teal.
- Underbelly is semantic and excludes the far flipper.
- Shell detail is restricted to the shell interior.

## Layer order
1. master_alpha → main
2. underbelly → underbelly
3. shell → deep
4. shell_detail → detail @ 0.48
5. shadow overlay
6. highlight overlay
7. outline → outline @ 0.72

## Shape Animation vs Motion Set
Sea Turtle is a high-grade Shape and may own **Shape Animation**.

- **Shape Animation**: shape-local articulation only. For Sea Turtle, this is the Long Flipper front-flipper swim motion.
- **Motion Set / FloatingEngine**: whole-shape position, collision, rotation, speed and movement area.
- These two systems are independent and may be composed at runtime.
- Do not call Sea Turtle's flipper articulation a Motion. The product term is **Shape Animation**.
- Tap/selection interaction remains a separate interaction layer unless explicitly designed later.

Current Shape Lab QA variants:
1. Long Sweep
2. Natural Swim
3. Soft Flow

## Binary integrity
Binary master/mask/overlay sources are archived separately and tracked by SHA-256 in `SHA256SUMS.txt`.
Before promotion, verify PNG signature/chunk CRC and compare SHA-256 against the archive.


## Verified import
Use `tool/import_sea_turtle_master.py` with the extracted `sea_turtle_pack_v2` directory.
The importer verifies every source PNG against the locked SHA-256 manifest before copying anything.

The CI validator follows an all-or-nothing rule:
- no source PNGs committed yet: metadata/runtime QA validation continues;
- all source PNGs present: every size and SHA-256 must match;
- partial source pack: CI fails.

This prevents a mixed or partially replaced Sea Turtle master from becoming the source of truth.
