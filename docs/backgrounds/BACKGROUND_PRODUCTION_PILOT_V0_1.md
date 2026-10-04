# MY LOCK Background Production Pilot v0.1

Status: Pilot / Provisional / Not Canonical
Date: 2026-10-04
Pilot asset: Drop 01 · 투명한 얕은 바다

## Purpose
Use one real background from planning through runtime QA, then remove redundant steps and promote only proven gates into the canonical MY LOCK background production standard.

## Pilot principle
Do not design the system in the abstract.
Run the asset through the pipeline first, record friction/failures, then revise the process.

## Current source hierarchy
1. Planning Visual Master
   - Approved visual target.
   - Defines world/style, composition, density, palette family, depth and final mood.
   - Not a production runtime asset by itself.
2. Clean Background Base
   - Static environment candidate.
   - Contains only elements that are intended to remain static.
3. Effect Layers
   - Surface Refraction
   - Floor Caustic
   - Volumetric Light
   - Ambient Particle
   - Bubble
4. Runtime Composite
   - Base + approved effects.
5. Shape Recomposite QA
   - Locked production shapes are added only after background/effect approval.
6. Production Master / Runtime Asset
   - Created only after QA and explicit user approval.

## Pilot gates

### P0 · Planning Visual
Goal: approve the look before implementation.
Check:
- Drop visual language
- composition
- central play field
- environment density
- palette family
- depth/mood
Output:
- Planning Visual Master
Approval required: yes

### P1 · Clean Base
Goal: isolate the static environment.
Keep:
- water depth field
- seabed
- static rocks/coral/seaweed
- distant reef silhouettes
Remove from production base:
- animated refraction
- animated light shafts
- bubbles
- moving caustics
- ambient particles
Output:
- Clean Background Base Candidate
Approval required: yes

### P2 · Surface Refraction
Goal: reproduce the approved upper-surface feel in runtime.
Compare 2-3 materially different candidates, not micro-variants.
Controls:
- intensity
- coverage
- speed
- deformation scale
QA:
- no repetitive sine-line appearance
- no overbright wash
- no central play-field interference
- matches Planning Visual impression
Output:
- Surface Refraction Candidate
Approval required: yes

### P3 · Floor Caustic
Goal: make the seabed feel alive without tiled repetition.
Controls:
- intensity
- scale
- drift speed
- breakup/organic distortion
QA:
- avoids regular grid/tile reading
- remains subordinate to shapes
Output:
- Floor Caustic Candidate
Approval required: yes

### P4 · Volumetric Light
Goal: add depth and water-volume perception.
Controls:
- beam count
- width
- opacity
- drift
- breathing
QA:
- beams do not look like fixed spotlights
- central visibility preserved
Output:
- Volumetric Light Candidate
Approval required: yes

### P5 · Ambient
Goal: minimal environmental life.
Subpasses:
- micro particles
- bubbles
QA:
- edges favored over center
- low density
- non-synchronous movement
- optional performance tier
Output:
- Ambient Candidate
Approval required: yes

### P6 · Runtime Composite
Goal: verify the background as a complete scene without shapes.
Tools:
- Base only / All effects toggle
- per-layer enable/disable
- play/freeze
- intensity controls
- reference vs runtime side-by-side
QA:
- matches Planning Visual at a glance
- no layer dominates
- no effect collision
Output:
- Background Runtime Candidate
Approval required: yes

### P7 · Shape Recomposite QA
Goal: confirm background supports actual gameplay.
Use only already locked/approved shapes.
QA:
- 6 / 9 / 12 shapes
- shape+color identity
- visual occlusion
- play-field readability
- touch visibility
- motion readability
Do not recolor or relight locked shape assets to fit the background.
Output:
- Recomposite QA
Approval required: yes

### P8 · Production Closeout
Requirements:
- user approval
- runtime/performance QA
- final assets/renderer metadata
- manifest
- registry state
- source/reference history retained
Output:
- Background Production Master
- Runtime Asset
- Manifest
- QA record
State:
- Final / Locked / Active

## LABS layout for pilot
Background Lab should contain:
- Planning Master Reference
- Runtime Composite Preview
- layer toggles
- Play / Freeze
- candidate selector for active gate
- minimal gate-specific controls
- Base Only / All Effects comparison
- Shape QA toggle only after P6

Do not expose every internal parameter. Only controls needed to make a production decision belong in LABS.

## Pilot review log
After each gate, record:
- what was useful
- what was redundant
- what caused confusion
- what should be automated
- what should remain user approval
- what QA caught real defects
- performance impact

## Promotion rule
This document is provisional.
After the first background completes P0-P8, revise the workflow once.
Only the revised version may be promoted into the canonical MY LOCK production guide.
