# Starfish Production + Micro-Idle Closeout — 2026-10-05

## Status
- Appearance Master v1: FINAL / LOCKED / ACTIVE
- Production Asset v1: FINAL / LOCKED / ACTIVE
- Whole Shape micro-idle v1: FINAL / LOCKED / ACTIVE
- User closeout approval: 2026-10-05

## Canonical source
- `assets/shape_masters/drop01/starfish/master/starfish_appearance_master_final_v1_2048.png`
- SHA-256: `e782ae23622e549ecc75b6cfb067438398dd0aa21b88fcf6dc34a4b50c8dcceb`
- Geometry / Color / Shading / canonical binary unchanged by motion closeout.

## Production asset
- Palette Region Mask / Palette Region Asset / Removed Remainder
- Runtime Master 256 / Palette Base 256 / Fixed Finish 256 / Production Manifest
- Recomposite QA: changed pixels 0 / max channel diff 0
- ImageGen: false / Geometry changed: false

## Motion lock
- Mode: `whole_shape_micro_idle`
- Period: 3.6 s
- Sway: +/-2.4 deg
- Vertical float: 0.016R
- Horizontal drift: 0.006R
- Breathing: +/-1.2%, opposing axis
- Stable per-instance phase offset
- No part split / no Key Pose raster set
- Downstream runtime transform only; canonical source is immutable.

## Integrated LABS
- Existing Integrated LABS only; no separate public Starfish site.
- Shape Lab: static production shape + APP EXACT motion preview.
- Runtime QA: same production renderer/config.
- Palette Lab: palette/signature color applies to Shape only, not preview background.

## Persistence
- Drive production folder: https://drive.google.com/drive/folders/1zuSSHGXL7YRbEz3vdRb7in8U0axMiDZo
- Drive production package: https://drive.google.com/file/d/1kGQqkwoA5gu0i94ZNdQ-VUAQ6a9G-okN/view
- Notion: Drop 01 — 작은 바닷속 · Asset Master / Starfish Production + Micro-Idle Closeout — 2026-10-05

## Troubleshooting
A Dart closing-brace syntax error occurred while inserting the Shape Lab motion panel. It was corrected and subsequent Integrated LABS CI passed. Prevention: every Lab section insertion must pass Flutter Analyze before deployment.

## Next lineage
Any Visual DNA v2 appearance change starts as a separate Candidate lineage and does not overwrite this locked source.
