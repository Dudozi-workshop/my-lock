# MY LOCK — Sea Turtle Canonical Master v3 Draft

Drop 01 / S02 Sea Turtle / Long Flipper.

## Purpose
v3 upgrades the editing source from 512 px to a 2048 px transparent Canonical Master draft and establishes a clean F0 moving-part split before animation design.

## Preserved from v2
- S02 Long Flipper silhouette and proportions
- Shell / Belly semantic intent
- Palette-token architecture
- Runtime sizing policy
- Binary Integrity Gate

## Changed in v3
- Editing source: 512 px → 2048 px
- Front Flipper Near/Far: global-mask assumption → independent F0 moving parts
- Each moving flipper owns alpha / outline / shadow / highlight
- Static overlays must exclude moving-part pixels
- Shape Animation is allowed only for front-flipper articulation in the first implementation
- Whole-object movement remains owned by Motion Set / FloatingEngine
- Animation implementation is deferred until whole-turtle 3–4 key-pose image mockups are approved

## Static split contract
The neutral F0 master is split into:
1. static_body
2. front_flipper_far_f0
3. front_flipper_near_f0

The three parts must rebuild the Canonical Master with zero visible/pixel difference before Static Master Lock.

## Current QA
- 2048 × 2048 transparent Canonical draft generated
- Near/Far F0 independent-part split generated
- Static layer excludes old-position flipper outline/highlight pixels
- F0 rebuild max channel diff: 0
- F0 rebuild changed channel count: 0
- Generated PNG CRC validation: PASS

## Binary source policy
The high-resolution PNG pack is promoted only through the Binary Integrity Gate. Repository metadata, spec, build procedure, and manifests may land before the source PNG pack. Do not substitute runtime QA PNGs for the Canonical Master.

## Next
Static v3 visual approval → Static Master Lock → whole-turtle animation mockup → 3–4 key-pose approval → Near Flipper pose assets → Far Flipper pose assets → loop QA.
