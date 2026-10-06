# Starfish Asset Registry v2

- Asset ID: `starfish`
- Drop: `drop01`
- Status: **QA CANDIDATE / PRODUCTION LOCK HOLD**
- Visual direction: Soft Pastel Storybook character
- Current Appearance source SHA-256: `2a10f97517071245b5b240e273faa302fef8a433a19aae3624d9dfe8cb03c76c`
- Canvas: **2048x2048 RGBA**
- Ownership: **Full Body = Single Part**
- Geometry / authored pixels: locked for QA; no redraw in this gate.

## Semantic color ownership
- Recolor domain: body / contour / spots / cheeks / authored shading.
- Fixed non-color domain: **eyes + mouth only**.
- Part ownership and color ownership are separate systems.
- Palette swapping must not alter alpha, geometry, or the fixed face region.

## Runtime Candidate v2
- Runtime canvas: **256x256**
- Content: **192x192**
- Nominal padding: **32 px**
- Runtime Master: `starfish_runtime_master_candidate_v2_256.webp`
- Palette Base: `starfish_palette_base_candidate_v2_256.webp`
- Fixed Finish: `starfish_fixed_finish_candidate_v2_256.webp`
- Runtime Manifest: `starfish_runtime_candidate_v2_manifest.json`
- Runtime model: **Palette Base + fixed optical finish**, with fixed-color face embedded in Fixed Finish.
- True shape alpha is applied exactly once after both optical layers.

## Palette QA
Static Drop 01 colors tested using the active palette contract:
- Deep Ocean Blue `#4F8EDB`
- Aqua Mint `#7CCFC4`
- Coral Pink `#F7A7B5`
- Sand Beige `#EFD59A`
- Lavender `#B9A7E8`
- Peach Orange `#F7B385`

QA results:
- Palette alpha mismatch: **0 px**
- Fixed face core maximum RGB variation across palettes: **1 level**
- Runtime canvas-edge alpha pixels: **0**
- Transparent RGB residue: **0**
- Lossless WebP decode equality: **PASS**
- Body reference luminance max error: **0.00269724**
- Geometry changed: **NO**
- ImageGen used for production split: **NO**

## Small-size QA
- Authored source checked at 160 / 120 / 100 / 80 / 58 px.
- Runtime Candidate checked at 58 px across all six Drop 01 static palettes.
- Eyes remain readable at 58 px.
- Mouth remains present but is the first facial detail to weaken at 58 px; treat as **WATCH**, not failure.
- Spot pattern remains subordinate to silhouette and does not become dominant noise.
- Final optical mass / occupancy calibration against Sea Turtle / Dolphin / Jellyfish remains intentionally **DEFERRED**.

## Storage
- Google Drive: `MY LOCK Assets / Drop 01 - 작은 바닷속 / 04 Starfish / runtime`
- QA package: `MYLOCK_Starfish_Runtime_ColorDetail_QA_Candidate_v2_20261006.zip`
- QA package SHA-256: `62bbe0a0904e75243fb1eb324e18f73b1eb59f6e3b02319ce81f6b2d63ab4ae6`

## Gate
Current gate is **Runtime Color + Detail QA**.

Do not promote this v2 appearance/runtime set to FINAL / LOCKED / ACTIVE until:
1. User reviews the runtime color/detail QA.
2. Cross-asset optical mass calibration is completed with actual approved reference binaries.
3. APP EXACT / Shape Lab runtime verification is completed.
