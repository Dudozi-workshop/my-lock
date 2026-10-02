# Sea Turtle v3 · Whole-turtle QA Handoff — 2026-10-02

## Status
This handoff closes the part-level work completed in the preceding chat.
Do not reopen completed Part production unless Whole-turtle QA identifies a seam-specific issue.

## Authoritative / locked sources
- Authoritative Master: **Q3 Canonical Master**
- Canonical Canvas: **2048×2048 RGBA**
- `shell_main`: **Final / Locked**
- `body_with_rear`: Geometry **FINAL_v2**, Outline **FINAL_v3**, FULL REMAP v2 Runtime QA **user-approved**
- `underbelly`: Geometry **FINAL_v4_cleanup**, material direction completed through Palette/Runtime in parallel lineage; keep locked
- `front_flipper_near`: **Final / Locked / Active**, Runtime revalidation v2 and Final Closeout v2 complete
- `front_flipper_far`: Geometry **FINAL_v4**, Material/Palette/Runtime **FINAL_v1 / Locked / Active**

## front_flipper_far final facts
- Material source pixels: **63,029**
- Outline: **8,838**
- Pattern/Detail: **22,765**
- Shadow: **6,286**
- Highlight: **2,519**
- Base/Albedo: **22,621**
- Gap: **0**
- Overlap: **0**
- Outside source: **0**
- Recomposite changed: **0**
- ImageGen: **not used**
- Palette: Pink `#FF8FD1`, Blue `#79BFFF`, Yellow `#FFDA72`
- Runtime QA route: `https://my-lock-preview.rlatkd5959.workers.dev/?qa=front-flipper-far`
- Web Build / Cloudflare Deploy / Android CI: **PASS**
- Final Drive package: `sea_turtle_v3_front_flipper_far_FINAL_v1.zip`

## body_with_rear final part-level status
- Runtime QA route: `https://my-lock-preview.rlatkd5959.workers.dev/?qa=sea-turtle-body-with-rear`
- Runtime build/deploy: **PASS**
- User visual QA: **PASS**
- Whole-turtle compatibility: **pending**

## Next Gate — Whole-turtle seam / material compatibility QA
Use only the current Final / Locked / Active Parts.
Do **not** modify geometry or individual material ownership during initial QA.

Inspect:
1. complete static F0 recomposition;
2. seam visibility at all Part attachments;
3. double-outline / stacked-line artifacts;
4. root attachment continuity for Near/Far front flippers;
5. body ↔ underbelly ↔ shell color/material continuity;
6. Pink / Blue / Yellow whole-shape palette consistency;
7. light/dark background readability;
8. smallest intended runtime-size legibility;
9. residual/halo/alpha-edge artifacts;
10. render order and occlusion correctness.

If a seam issue is found, isolate it to the owning Part and propose the smallest seam-specific correction. Do not globally regenerate or reinterpret completed Parts.

## Runtime / animation scope
Current closeout concerns **Static F0**.
Shape-specific animation remains outside this gate unless separately approved.
