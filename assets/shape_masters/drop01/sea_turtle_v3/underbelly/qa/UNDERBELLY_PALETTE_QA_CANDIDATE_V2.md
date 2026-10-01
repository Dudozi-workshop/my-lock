# Sea Turtle v3 · Underbelly Palette QA Candidate v2

- Status: **QA Candidate / user visual approval pending**
- Material source: **Underbelly Material Profile v2**
- Geometry source: **Underbelly FINAL_v4_cleanup**
- Palette source: app **ShapeTone/baseColorForTone**
- Registered palettes: Pink `#FF8FD1` / Blue `#79BFFF` / Yellow `#FFDA72`
- ImageGen: **not used**
- Geometry / Alpha / Material Ownership changed: **0**

## Material decomposition prerequisite
- Source visible support: **136,758 px**
- Outline: **8,647 px**
- Shadow: **17,774 px**
- Highlight v2: **8,827 px**
- Base / Albedo v2: **101,510 px**
- Pairwise overlap: **0 px**
- Coverage gap: **0 px**
- Recomposite changed pixels: **0**
- Max channel diff: **0**

## Palette QA
All palette outputs preserve source alpha exactly and remap RGB into the selected palette family while retaining source luminance structure.

- Pink
  - target hue within ±10°: **100%**
  - source→output luminance correlation: **0.999391**
  - alpha mismatch: **0 px**
  - transparent RGB residue: **0 px**
- Blue
  - target hue within ±10°: **100%**
  - source→output luminance correlation: **0.999402**
  - alpha mismatch: **0 px**
  - transparent RGB residue: **0 px**
- Yellow
  - target hue within ±10°: **100%**
  - source→output luminance correlation: **0.999415**
  - alpha mismatch: **0 px**
  - transparent RGB residue: **0 px**

Pairwise palette alpha mismatch: **0 px**.

## Offline runtime-size assets
- 96 px outputs generated for Pink / Blue / Yellow.
- 58 px outputs generated for Pink / Blue / Yellow.
- These are deterministic downsampled QA assets; they do not replace the 2048 canonical production source.

## Surface / Material Compatibility
- Palette remap changes RGB only.
- Geometry, alpha, ownership masks and layer partition remain fixed.
- Compatible in principle with the existing Hybrid Material Compositor contract.
- Actual Flutter shader/runtime integration and whole-turtle seam/material compatibility remain **PENDING** until the Underbelly runtime asset is registered and built with the other locked Parts.

## Drive
- Material v2 package: https://drive.google.com/file/d/1asZ_-PD9FLf0_CgSEwjwy1u8uoyotoHU/view?usp=drivesdk
- Palette QA v2 package: https://drive.google.com/file/d/1QMqQJK1iFGVrp6b9lJg1JJ8XcPhY29Fw/view?usp=drivesdk

## Promotion rule
Do not promote Palette QA / Runtime to Final until user visual approval plus whole-turtle runtime integration/build QA pass.
