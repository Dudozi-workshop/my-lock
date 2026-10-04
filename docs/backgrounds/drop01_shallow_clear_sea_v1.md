# Drop 01 · 투명한 얕은 바다 · Planning Visual Master v1

Status: Selected Planning Visual / Clean Background Base v1 Candidate / Not Final / Not Locked
Date: 2026-10-04

## User-approved direction
- World/style alignment: Drop 01 · 작은 바닷속 Shape Master visual language.
- Composition: large open central play field.
- Static density: environmental detail concentrated at lower-left; center remains open.
- Palette: pastel aqua/blue water, lavender-blue rocks, coral pink, mint, cream sand.
- Depth: shallow, bright, calm underwater space.
- Shape assets are not baked into the background.

## Static Background Base ownership
Keep in the base:
- water depth gradient
- distant seabed / atmospheric depth
- sand geometry and perspective
- lower-left rock cluster
- coral / seaweed placement and density
- distant reef silhouettes
- painterly pastel texture

Do not bake as final static detail:
- animated surface refraction
- volumetric light-beam motion
- rising bubbles
- dynamic floor caustic
- optional ambient particles

## Effect decomposition
1. Surface Refraction
2. Volumetric Light
3. Floor Caustic
4. Ambient Particle / Bubble
5. Runtime Shape recomposition
6. Optional foreground atmosphere

Priority: Surface Refraction > Floor Caustic > Volumetric Light > Ambient Particle > Bubble.

## Gate state
- Planning Visual Master v1: user approved.
- Clean Background Base v1: selected candidate.
- Next active gate: Surface Refraction.
- Production promotion requires separate runtime reconstruction, QA, user approval, then lock.

## Scope lock
The approved composition, object density, central negative space, palette family and world/style direction are frozen for the next effect gate. Surface Refraction work must not regenerate or redesign the static environment outside that effect scope.
