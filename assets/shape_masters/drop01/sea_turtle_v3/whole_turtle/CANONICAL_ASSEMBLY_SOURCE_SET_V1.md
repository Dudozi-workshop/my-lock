# Sea Turtle v3 · Canonical Assembly Source Set v1

- Status: **QA Candidate**
- Canvas: **2048×2048 RGBA**
- Assembly: **all Parts at (0,0)**
- Scale / bbox placement / crop reconstruction: **none**
- Runtime 512/58 assets: **not used**
- ImageGen: **not used**

## Active source set
| Part | Production Asset | SHA256 |
|---|---|---|
| Far Flipper | `front_flipper_far_f0_asset_FINAL_v4_2048.png` | `3e054e0d...` |
| Body + Rear | `body_with_rear_geometry_FINAL_v2_2048.png` | `4c1cca81...` |
| Shell | `sea_turtle_v3_shell_asset_v1_2048.png` | `ed7a6b6b...` |
| Underbelly | `underbelly_asset_FINAL_2048.png` | `93811e85...` |
| Near Flipper | `front_flipper_outer_asset_v3_2048.png` | `4c7a83fe...` |

Render order: Far → Body/Rear → Shell → Underbelly → Near.

## Assembly QA
- Whole alpha bbox: `[420, 688, 1640, 1460]`
- Union visible pixels: **546,384**
- Multi-Part overlap support: **55,220 px**
- Maximum overlap depth: **3 Parts**
- All 5 source files: **2048×2048 RGBA PASS**
- Coordinate compensation: **0**
- Per-Part scale change: **0**

## First seam findings
- Head ↔ Underbelly: bright dotted / anti-aliased seam visible.
- Near Flipper root ↔ Body/Underbelly/Shell: bright seam and strong dark attachment line visible.
- Shell ↔ Underbelly: continuous, but some internal seam visibility is strong.
- Far Flipper root: no major disconnect observed.
- Rear / Shell / Body: no major gap observed.

No Geometry / Material / Ownership change is authorized by this QA result.  
Next Gate is attachment-by-attachment seam visibility / ownership decision after visual review.
