# MY LOCK — Sea Turtle Canonical Master v3

Drop 01 / S02 Sea Turtle / Long Flipper.

## Current authoritative decision
On 2026-09-26, the newly approved eye-free Sea Turtle artwork was adopted as the **Sea Turtle v3 Master Shape Reference v1**.

This reference now defines:
- adult Sea Turtle silhouette and proportions
- S02 Long Flipper direction
- head / neck / shell / belly / flipper relationship
- no-eye face direction
- premium 2D illustration finish

The reference image is stored at:
- `reference/sea_turtle_master_shape_reference_v1.png`

## Important distinction
The locked reference is **not yet the production Canonical PNG** because the approved image still contains a background / external glow and is not the final 2048 × 2048 transparent source.

Production must therefore rebuild:
- `source/sea_turtle_master_v3_2048.png`

from the approved reference while preserving the locked silhouette and proportions.

## Production rules
- Do not use `assets/sea_turtle_runtime_v2/*` as a production source.
- v2 is historical geometry/runtime reference only.
- Do not treat a simple 512 px upscale as the final v3 Canonical source.
- Remove background and external glow.
- Preserve the approved no-eye face.
- Preserve Long Flipper silhouette and optical balance.
- Clean alpha edge / transparent RGB residue.
- Complete Canonical before semantic and moving-part production assets are promoted.

## Planned derivation order
1. Locked Master Shape Reference
2. 2048 transparent Canonical Master
3. Master Alpha
4. Shell / Belly / Shell Detail semantic masks, including hidden underlap
5. Static Body / Front Far F0 / Front Near F0
6. Geometry QA/QC: ownership / overlap / gap / reveal checks
7. Material decomposition: Albedo / Shadow / Highlight / Detail / Outline
8. Basic material recomposition QA
9. Aurora Sea dynamic-material PoC
10. Runtime ShapeMaterialCompositor
11. Static Master Lock
12. runtime_v3 export
13. Shape Animation

See `MATERIAL_COMPOSITOR.md` for the hybrid bake/runtime policy.

## Animation policy
Shape Animation remains deferred until Static Master Lock. Whole-object movement belongs to Motion Set / FloatingEngine. Internal front-flipper articulation belongs to Shape Animation.
