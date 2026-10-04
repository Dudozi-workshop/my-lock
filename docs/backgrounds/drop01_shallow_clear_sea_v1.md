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
- Composition direction: **A Open Water**.
- **Base Only v2: user approved** as the static Background Base visual direction.
- 01 배경 이미지 state: **Approved Base / not complete Background Final / not Locked**.
- Approved Base binary is durably stored in Drive as `shallow_clear_base_only_v2_approved_candidate.png`.
- Next active Production Step: **02 레이어 효과** in LABS Background.
- First effect target: Surface Refraction.
- Production promotion requires LABS effect work → Composite QA → user approval → Final/LOCK.

## Scope lock
The approved composition, object density, central negative space, palette family and world/style direction are frozen for the next effect gate. Surface Refraction work must not regenerate or redesign the static environment outside that effect scope.

## LABS-first continuation rule
- After Base approval, effect production and comparison continue in Background LABS rather than through ad-hoc chat mockups.
- Reporting-only QA images are not production artifacts and should not be generated as a substitute for LABS QA.
- If a required effect comparison, ratio QA, ON/OFF, Freeze/Play, or composite inspection control is missing, improve LABS first and then continue the active Production Step.
- Effect layers remain independent from the approved Base: Surface Refraction / Floor Caustic / Volumetric Light / Ambient Particle / Bubble.
