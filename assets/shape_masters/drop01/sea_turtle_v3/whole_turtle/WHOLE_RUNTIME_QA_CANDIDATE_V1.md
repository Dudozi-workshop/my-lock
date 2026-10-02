# Sea Turtle v3 · Whole Runtime Derived Export Candidate v1

## Status
**Final / Locked Runtime Derived Asset**

## Source
- Approved Whole Canonical Assembly v1
- 2048×2048 RGBA
- Final / Locked Part source set unchanged
- ImageGen: not used
- Geometry / Material changes: none

## Runtime normalization
The Canonical 2048 Assembly remains the Production Source.

Runtime output is a downstream Derived Asset and uses a deterministic square normalization crop:
- Whole alpha bbox: `[420, 688, 1640, 1460]`
- Square runtime crop: `[420, 464, 1640, 1684]`
- Side: **1220 px**
- Rule: use max(alpha bbox width, height), center around alpha bbox, clamp to 2048 canvas.
- No Part is individually moved or scaled.
- This crop never replaces the 2048 Canonical Source.

## Exports
- `sea_turtle_v3_whole_runtime512_v1.png`
  - SHA256 `9bae107babb3219a879fb0e867364a1bfa323bfca8b09b4791f7c61df6e61b84`
- `sea_turtle_v3_whole_runtime58_v1.png`
  - SHA256 `dd225477d2e615f326da8f9cdd44fa8ac4e589e5e1631527e71dc4c3410e87d0`

Interpolation: Lanczos.

## 58 px QA
- Light background: PASS
- Dark background: PASS
- Whole silhouette: PASS
- Shell / body / front-rear flipper separation: PASS
- Obvious alpha halo: PASS
- Obvious disconnected Part: PASS

User visual approval completed on 2026-10-02. Runtime Derived Asset v1 is locked; downstream app integration is tracked separately.
