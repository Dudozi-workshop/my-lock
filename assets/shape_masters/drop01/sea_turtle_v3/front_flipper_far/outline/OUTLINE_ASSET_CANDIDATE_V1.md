# Sea Turtle v3 · Front Flipper Far F0 · Outline Asset Candidate v1

- Status: **QA Candidate / User Approval Pending**
- Source Geometry: **front_flipper_far FINAL_v4**
- Source Mask: **Outline Mask v1 · Final / Locked / Active**
- Canvas: **2048×2048 RGBA**
- ImageGen: **not used**
- Method: deterministic extraction of existing FINAL_v4 RGBA pixels only.
- Locked and unchanged: `body_with_rear` / `shell_main` / `underbelly` / `front_flipper_near` / `front_flipper_far` Geometry.

## QA
- Outline pixels: **8,838 px**
- bbox: **[470, 945, 712, 1362]**
- 8-neighbor connected components: **2** (8,824 + 14 px)
- Asset ↔ Mask mismatch: **0 px**
- Source RGBA mismatch: **0 px**
- Asset outside mask: **0 px**
- Asset ↔ Remainder overlap: **0 px**
- Remainder inside mask: **0 px**
- Transparent RGB residue: **0 px**
- Recomposite changed pixels: **0**
- Recomposite max channel diff: **0**
- PNG integrity: **PASS**

## Next gate after approval
Promote Outline Asset v1 to **Final / Locked / Active**, then begin **Pattern / Detail Ownership Overlay** excluding the locked Outline v1 region.
