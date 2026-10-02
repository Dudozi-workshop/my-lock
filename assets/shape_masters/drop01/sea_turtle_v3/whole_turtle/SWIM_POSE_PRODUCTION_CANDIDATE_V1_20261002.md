# Sea Turtle v3 · Swim Pose Production Candidate v1 — 2026-10-02

## Status
- **QA Candidate / user approval pending / not locked**
- Motion direction approved: both Near and Far front flippers move.
- Static scope remains locked: Body / Shell / Underbelly / Rear.
- ImageGen: **not used**
- Canonical canvas: **2048×2048 RGBA**
- Loop: `S0 → S1 → S2 → S1 → S0`

## Active candidate sources
- Near S1: shoulder-participation candidate v3
- Near S2: shoulder-participation candidate v3
- Far S1: shoulder-participation candidate v2
- Far S2: shoulder-participation candidate v2

Far remains visually subordinate to Near while participating from the root/shoulder.

## Part QA
| Part | Pose | Visible px | bbox | Recomposite changed | Max diff | Transparent RGB residue |
|---|---|---:|---|---:|---:|---:|
| Near | S1 | 108,154 | [809,909,1348,1384] | 0 | 0 | 0 |
| Near | S2 | 102,921 | [809,909,1376,1320] | 0 | 0 | 0 |
| Far | S1 | 58,206 | [458,945,710,1320] | 0 | 0 | 0 |
| Far | S2 | 54,220 | [449,945,708,1285] | 0 | 0 | 0 |

Common QA:
- mask values: 0 / 255
- asset↔mask support mismatch: 0
- asset↔remainder overlap: 0
- PNG integrity: PASS
- geometry source kept per pose candidate
- no whole-shape regeneration

## Candidate package
Local review package:
- `sea_turtle_v3_swim_pose_production_candidate_v1.zip`
- Includes per-pose Asset / Mask / Removed Remainder / Recomposite QA / Recomposite Diff / Manifest.

## Gate note
The zero-diff recomposite proves technical extraction consistency only. It does **not** yet approve root seam behavior or whole-shape attachment appearance.

## Next gate
**Whole-shape seam / residual QA for S1 and S2**, especially:
1. Near root ↔ Body / Underbelly / Shell
2. Far root ↔ static body
3. double-outline / exposed hidden-underlap
4. S0↔S1 and S1↔S2 visual continuity
5. runtime-size loop playback

User approval after this gate is required before LOCK.
