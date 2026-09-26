# Sea Turtle v3 Build Notes

## Input
- Geometry reference: Sea Turtle S02 Long Flipper v2 / 512 px
- Existing semantic inputs: master alpha, shell, underbelly, shell detail, outline, neutral shadow/highlight

## Canonical draft procedure
1. Clip the legacy planning-sheet white background with the locked master alpha.
2. Upscale to 2048 × 2048 with geometry-preserving Lanczos.
3. Apply only restrained RGB refinement; alpha remains derived from the locked alpha source.
4. Zero RGB under fully transparent pixels for deterministic binary/pixel QA.
5. Split the neutral F0 pose into static body / far front flipper / near front flipper.
6. Move the part boundary slightly into the body so old-position flipper outline/highlight cannot remain on the static layer.
7. Split outline/shadow/highlight maps by the same F0 ownership boundary.
8. Rebuild F0 and compare against the Canonical draft.

## Current result
- F0 rebuild maximum channel difference: 0
- F0 rebuild changed channel count: 0
- All generated PNG chunk CRC checks: PASS
- Hidden body underlap is intentionally deferred until animation mockup defines the required pose envelope.

## Promotion rule
This is a Canonical **draft**, not Geometry Lock. Promote only after visual inspection of:
- silhouette preservation
- shell/belly boundary quality
- Near/Far split boundary
- static-layer residue
- 2048 editing quality
