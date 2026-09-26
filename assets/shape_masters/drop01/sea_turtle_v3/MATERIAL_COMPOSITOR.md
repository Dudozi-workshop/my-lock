# Sea Turtle v3 Material Compositor Policy

Updated: 2026-09-26

## Decision
Sea Turtle v3 does **not** use bake-only rendering for every visual property.
The production direction is a **hybrid material compositor**:

- Geometry, base illustration quality, structural shading, structural highlight, detail and outline can be baked or pre-derived.
- User-selectable or time-varying material color/effects remain runtime-controllable.
- Aurora Sea is the reference stress-test because its shell color must move over time without detaching visually from the turtle.

## Composition model
Runtime conceptual order:

1. Region-local Albedo / dynamic material color
2. Region Mask clipping
3. Baked/derived Shadow
4. Baked/derived Highlight
5. Structural Detail
6. Outline
7. Final region composite
8. Final turtle composite
9. Whole-object Motion Set / FloatingEngine transform

The screen should render the final composed turtle, not visually independent floating layers.

## Region-local coordinates
Dynamic effects such as Aurora Sea must use **shape-local / shell-local coordinates**, not screen-space coordinates.
This prevents the material from visually sliding when the whole turtle moves, rotates or floats.

## Shell ownership
Shell material decomposition target:
- mask
- albedo/base color input
- shadow
- highlight
- detail
- outline

Basic palettes replace/tint the albedo input.
Aurora Sea replaces the shell albedo with a time-varying material while reusing shell shadow/highlight/detail/outline to preserve volume and style.

## Belly / hidden-underlap rule
Belly is a continuous base surface independent of the front flipper pose.
The static body must contain a completed hidden underlap behind moving flippers.
A visible-only belly mask is invalid because moving/removing a flipper would reveal a hole.

## Moving-part ownership
Front Flipper Near/Far own their own:
- alpha
- outline
- shadow
- highlight

Static overlays must not retain F0 visual residue for moving parts.

## QA / QC gates
Every derived layer follows:
**Generate → QC → QA → Register**

### QC
- mask outside Master Alpha = 0 unless explicitly documented
- isolated noise/component check
- hole check
- ownership overlap/gap check
- rebuild diff
- PNG integrity

### QA
- layer boundary visual review
- ownership map
- overlap map
- gap map
- hidden-underlap reveal test
- moving-part reveal/rotation test
- canonical rebuild visual comparison
- runtime-size reduction review

No Static Master Lock while a gate fails.

## Production sequence
1. Canonical Master
2. Master Alpha
3. Semantic regions + hidden underlap
4. Moving-part geometry split
5. Geometry QA/QC
6. Material decomposition
7. Basic material recomposition QA
8. Aurora Sea dynamic-material PoC
9. Runtime compositor
10. Static Master Lock
11. Shape Animation production
