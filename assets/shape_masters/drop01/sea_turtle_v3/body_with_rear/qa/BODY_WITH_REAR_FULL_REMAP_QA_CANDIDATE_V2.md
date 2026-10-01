# Sea Turtle v3 · body_with_rear FULL REMAP QA Candidate v2

- Status: **Runtime QA v2 Visual Approved / Whole-turtle QA Pending**
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

## Flutter Runtime QA Candidate
- Runtime source: **single neutral 512×512 lossless WebP**
- Runtime color source: **ShapeTone/baseColorForTone**
- Runtime recolor: `ColorFilter.mode(selectedTone, BlendMode.color)`
- Purpose: one Shape runtime source + selected app color; do not ship separate Pink/Blue/Yellow body assets.
- QA route: `?qa=sea-turtle-body-with-rear`
- Screen commit: `eff95a44f64e497e297f066dd4fbf546805677a0`
- Route commit: `2b5a219aad0970f7472fd1084ae935b48c974176`
- Flutter Web build/deploy: **PASS** via GitHub Actions run `36868740853` (Build web / artifact upload / Cloudflare Worker deploy all success).

## Remaining gates
- Actual Flutter build/deployment verification: **PASS**
- Runtime visual approval using the deployed QA route: **PASS / user approved 2026-10-01**
- Whole-turtle seam/material compatibility: **PENDING until all Parts are materially ready**
- User visual approval: **PASS / 2026-10-01**.

## Promotion rule
Runtime build/deploy and part-level visual approval are complete. Do not promote to final whole-shape closeout until whole-turtle compatibility passes after all Parts are materially ready.
