# Sea Turtle v3 · Underbelly Final v4

- Status: **Final / Locked**
- Approval date: **2026-09-30**
- Authoritative Master: **Q3 Canonical Master**
- Source base: approved front-flippers-removed Hidden Underlap Rebuild Base v3
- Canvas: **2048×2048 RGBA**
- Role: lower jaw + lower neck + chest/abdomen + front-flipper hidden underlap
- ImageGen: **not used**
- Method: deterministic source-pixel ownership cleanup only
- Google Drive Final Pack: https://drive.google.com/file/d/1l0wKDBUL5v9xQ3rNWJzUDP9_n9VJXkZT/view?usp=drivesdk

## Final cleanup
Repeat QA found one isolated ownership pixel at `x=1363, y=1207` in the previous FINAL.
Candidate v4 removed only this pixel from Underbelly ownership and returned the original RGBA `[121,128,117,99]` pixel to Removed Remainder.
All other Underbelly pixels and every other Sea Turtle Part remained locked.

## Final QA
- Asset visible pixels: **136,758**
- Mask visible pixels: **136,758**
- Asset↔Mask support mismatch: **0**
- Connected components: **1**
- Isolated noise: **0**
- Enclosed holes: **0**
- Asset↔Remainder overlap: **0**
- Transparent RGB residue: **0**
- Recomposite changed pixels: **0**
- Recomposite max channel diff: **0**
- PNG integrity: **PASS**

## Version discipline
The prior FINAL is withdrawn from active use because repeat QA found the isolated 1 px residual.
The user approved candidate v4 on 2026-09-30; v4 is therefore the sole active **Underbelly Final / Locked** geometry source.
Drive contains older same-part packages that predate repeat QA; they are not active production sources. The active binary package is explicitly named `sea_turtle_v3_underbelly_FINAL_v4.zip`.

## Next production gate
Use this locked Underbelly source for Material Decomposition:
`Outline → Pattern / Detail → Shadow → Highlight → Base / Albedo → Material Recomposition QA → Palette QA → Surface/Material Compatibility QA`.

During Underbelly material work, `body_with_rear`, `shell_main`, `front_flipper_near`, and `front_flipper_far` remain locked.


## Material decomposition progress — 2026-10-01
- **Outline v1: Locked**
- Approved lineage: raw edge overlay v1 → clean-contour overlay v2 → deterministic mask/asset/remainder/recomposite.
- Outline ownership pixels: **17,245**
- Outside Underbelly: **0 px**
- Asset↔Mask mismatch: **0 px**
- Asset↔Remainder overlap: **0 px**
- Source gap: **0 px**
- Transparent RGB residue: **0 px**
- Recomposite changed pixels: **0**
- Max channel diff: **0**
- ImageGen: **not used**
- Runtime seam policy: Source Material Outline is locked, but attachment/internal-seam visibility remains pending whole-shape seam QA under the shared Outline Attachment / Runtime Seam Rule.
- Drive package: https://drive.google.com/file/d/1_3pHbLU5oBp_-2tBfaw6nP5xRdxo8ECZ/view?usp=drivesdk
- Outline spec: `UNDERBELLY_OUTLINE_V1.md`
- Outline manifest: `underbelly_outline_manifest_v1.json`
- **Next gate:** Underbelly Pattern / Detail Ownership Overlay.
