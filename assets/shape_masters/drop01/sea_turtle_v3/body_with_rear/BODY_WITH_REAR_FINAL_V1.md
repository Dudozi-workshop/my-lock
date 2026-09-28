# Sea Turtle v3 · body_with_rear Final v1

- Status: **Final / Locked**
- Authoritative Master: **Q3 canonical master**
- Canvas: **2048×2048 RGBA**
- Role: Fixed Layer — upper head / neck-body + Rear Near/Far, underbelly excluded
- ImageGen: **not used**
- Method: deterministic source-pixel ownership extraction + outline-residual cleanup
- Locked and unchanged: shell_main / underbelly / front_flipper_near / front_flipper_far

## Final QA
- Recomposite changed pixels: **0**
- Recomposite max channel diff: **0**
- Asset outside Master alpha: **0 px**
- Asset alpha vs canonical mask diff: **0 px**
- Transparent RGB residue — asset: **0 px**
- Transparent RGB residue — removed remainder: **0 px**
- Asset bbox: **[420, 688, 1640, 1315]**
- Runtime review: **58×58** full-object recomposite review generated

## Production Files
- body_with_rear_asset_v1_2048.png
- body_with_rear_mask_v1_2048.png
- body_with_rear_removed_remainder_v1_2048.png
- body_with_rear_ownership_qa_v1_2048.png
- body_with_rear_recomposite_qa_v1_2048.png
- body_with_rear_recomposite_diff_v1_2048.png
- body_with_rear_runtime_58_review_v1.png
- body_with_rear_manifest_v1.json

## Drive
Final package:
https://drive.google.com/file/d/1x0rZJUKY_QchP7PALFHTP47c5z6sG25v/view?usp=drivesdk

## Approval
User approved the v7 outline cleanup on 2026-09-29: “좋아. 이렇게 가자”
