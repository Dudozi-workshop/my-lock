# Sea Turtle v3 · Underbelly Palette QA Candidate v2

- Status: **Final / Locked / Active — Underbelly standalone Part**
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
- Flutter Runtime QA integration: **PASS** (`?qa=sea-turtle-underbelly`).
- MY LOCK Web Build: **PASS** on main containing the Underbelly runtime route/source.
- User visual runtime confirmation: **approved 2026-10-02**.
- Underbelly standalone Part is complete. Whole-turtle seam/material compatibility remains the next assembly-level Gate; it does not reopen Underbelly Geometry/Ownership unless an explicit ownership rollback is approved.

## Drive
- Material v2 package: https://drive.google.com/file/d/1asZ_-PD9FLf0_CgSEwjwy1u8uoyotoHU/view?usp=drivesdk
- Palette QA v2 package: https://drive.google.com/file/d/1QMqQJK1iFGVrp6b9lJg1JJ8XcPhY29Fw/view?usp=drivesdk

## Finalization — 2026-10-02
- Underbelly standalone production work: **COMPLETE / LOCKED**.
- Runtime QA source: `lib/features/qa/sea_turtle_underbelly_runtime_qa_screen.dart`.
- Runtime QA route: `?qa=sea-turtle-underbelly`.
- Deployed QA endpoint: `https://my-lock-preview.rlatkd5959.workers.dev/?qa=sea-turtle-underbelly`.
- No duplicate production binary upload was created during finalization; existing Drive Material v2 / Palette QA v2 packages remain authoritative.
- Next Gate: **Whole-turtle Seam / Material QA**.
