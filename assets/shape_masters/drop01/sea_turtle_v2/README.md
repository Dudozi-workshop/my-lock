# MY LOCK — Sea Turtle Master v2

Drop 01 / S02 Sea Turtle / Long Flipper.

## Source-of-truth policy
- Geometry is source-locked. Do not redraw the silhouette after Geometry Lock.
- Runtime appearance is generated from semantic Region Masks + Palette Tokens + neutral overlays.
- The three files under `assets/sea_turtle_runtime_v2/` are baked runtime QA references, not the master source.
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

## Motion ownership
Sea Turtle shape-local motion is disabled for the current production direction.
Movement, collision, rotation, speed and movement area belong to the existing Motion Set / FloatingEngine system.
Do not add shape-local idle, tap, flipper, frame, or custom swim motion unless the product decision is explicitly reopened.

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
