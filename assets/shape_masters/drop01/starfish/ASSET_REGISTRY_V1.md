# Starfish Asset Registry v1

- Asset ID: `starfish`
- Drop: `drop01`
- Status: **FINAL / LOCKED / ACTIVE**
- Appearance Master: `starfish_appearance_master_final_v1_2048.png`
- Production Asset: **v1 FINAL / LOCKED / ACTIVE**
- Canvas: **2048×2048 RGBA**
- Background: **Transparent**
- Selected direction: **Option 01**
- Silhouette / proportion: Locked
- Eyes / mouth: None
- Canonical SHA-256: `e782ae23622e549ecc75b6cfb067438398dd0aa21b88fcf6dc34a4b50c8dcceb`
- Appearance Drive file ID: `10-w4EO6igWWpuPMOgmehUfiCWv0CafiZ`
- Production Drive folder ID: `1zuSSHGXL7YRbEz3vdRb7in8U0axMiDZo`
- Production package Drive file ID: `1kGQqkwoA5gu0i94ZNdQ-VUAQ6a9G-okN`
- Production approval date: 2026-10-05

## Production ownership
- Main Palette Region: all visible Starfish body pixels.
- Fixed non-color semantic region: none.
- Removed Remainder: fully transparent.
- Geometry and alpha remain locked to the approved Appearance Master.

## Runtime
- Runtime Master: `assets/raster_shapes/starfish_runtime_master_final_v1_256.webp`
- Palette Base: `assets/raster_shapes/starfish_palette_base_final_v1_256.webp`
- Fixed Finish: `assets/raster_shapes/starfish_fixed_finish_final_v1_256.webp`
- Runtime model: Palette Base + Fixed Finish 2-layer optical factorization.
- Color changes apply to Palette Base; authored luminance/shading/highlight is preserved by Fixed Finish.

## QA
- Semantic recomposite changed pixels: **0**
- Max channel diff: **0**
- Runtime edge alpha pixels: **0**
- Reference luminance max error: **0.00137255**
- ImageGen used for production split: **NO**
- Geometry changed: **NO**

## Motion handoff
- Static Production Asset is locked.
- Starfish motion uses the same Whole Shape; no arm-part split and no new Key Pose raster set.
- Next track: very light whole-shape sway / float micro-idle only.
