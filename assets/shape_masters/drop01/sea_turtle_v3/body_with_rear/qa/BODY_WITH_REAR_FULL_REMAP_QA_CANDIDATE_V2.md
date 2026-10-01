# Sea Turtle v3 · body_with_rear FULL REMAP QA Candidate v2

- Status: **QA Candidate / not Production locked**
- Geometry Source: **body_with_rear Geometry FINAL_v2**
- Outline Ownership: **Outline FINAL_v3**
- ImageGen: **not used**
- Palette Source: current app **ShapeTone/baseColorForTone**
- Registered palettes: Pink `#FF8FD1` / Blue `#79BFFF` / Yellow `#FFDA72`
- Drive package: https://drive.google.com/file/d/173fvc7ad42YK46O6vWO7x_GWR1-tttNk/view?usp=drivesdk

## Material QC
- Canonical canvas: 2048×2048 RGBA — PASS
- Source visible pixels: **91,756**
- Geometry/alpha mismatch vs Geometry FINAL_v2: **0 px** for all 3 palettes — PASS
- Outside source alpha: **0 px** — PASS
- Transparent RGB residue: **0 px** — PASS
- Pairwise palette alpha mismatch: **0 px** — PASS
- Outline ownership geometry unchanged: **13,492 px** mask retained — PASS

## Palette QA
- Original green-family residual: **0 px** in Pink / Blue / Yellow outputs — PASS
- Target hue concentration within ±10°: **100%** for all registered palettes — PASS
- Source→output luminance correlation:
  - Pink: **0.968521**
  - Blue: **0.967151**
  - Yellow: **0.959622**
- Interpretation: original hue/chroma is discarded; source form/brightness structure is preserved and recolored into the selected MY LOCK palette family.

## Offline Runtime-size QA
- 58 px inspection: PASS for silhouette and major volume separation on light/dark backgrounds.
- 96 px inspection: PASS for form readability and retained tonal detail.
- QA artifact: `body_with_rear_runtime_QA_candidate_v2.png`

## Remaining gates
- Whole-turtle seam/material compatibility: **PENDING**. Underbelly runtime seam role is explicitly pending whole-shape QA and other Parts are being developed in parallel.
- Actual Flutter runtime integration/build/deployment: **PENDING**. Current renderer has ShapeTone base colors and generic layered-mask support, but no active `sea_turtle_v3 body_with_rear` raster-remap runtime registration was found.
- User visual approval: **REQUIRED** before promotion.

## Promotion rule
Do not promote this draft to Final/Locked until whole-turtle compatibility, actual runtime implementation/build verification, and user visual approval pass.
