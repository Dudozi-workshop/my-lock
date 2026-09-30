# Sea Turtle v3 · body_with_rear Outline FINAL v3

- Status: **Final / Locked / Active**
- Authoritative Master: **Q3 Canonical Master**
- Geometry Source: **body_with_rear Geometry FINAL_v2**
- Canvas: **2048×2048 RGBA**
- ImageGen: **not used**
- Method: deterministic extraction from the user-approved Outline Ownership Overlay v3.
- Locked and unchanged: shell_main / underbelly / front_flipper_near / front_flipper_far
- Drive package: https://drive.google.com/file/d/1w5iU5uNXJD2OS_mSfXP9P1VrVl_Qy3_j/view?usp=drivesdk

## Approval
User approved the residual-corrected Outline Ownership Overlay v3 on 2026-10-01: “좋다.ㄱㄱ”

## QA
- Outline selected pixels: **13,492 px**
- Source alpha outside: **0 px**
- Asset alpha vs mask presence diff: **0 px**
- Transparent RGB residue — asset/remainder/mask: **0 / 0 / 0 px**
- Recomposite changed pixels: **0**
- Recomposite max channel diff: **0**
- Connected components: **19**
- Isolated 1 px components: **6**
- Conservative dark exterior numeric candidates after extraction: **28 px / 16 tiny components / max 5 px**.
- Visual residual audit: no coherent leftover Outline segment; these tiny candidates are retained with the non-Outline surface rather than auto-reassigned.

## Production Files
- body_with_rear_outline_mask_FINAL_v3_2048.png
- body_with_rear_outline_asset_FINAL_v3_2048.png
- body_with_rear_outline_removed_remainder_FINAL_v3_2048.png
- body_with_rear_outline_ownership_qa_FINAL_v3_2048.png
- body_with_rear_outline_recomposite_FINAL_v3_2048.png
- body_with_rear_outline_recomposite_diff_FINAL_v3_2048.png
- body_with_rear_outline_manifest_FINAL_v3.json

## Next Gate
**Pattern / Detail Ownership Overlay**. Geometry FINAL_v2 and Outline FINAL_v3 remain locked.
