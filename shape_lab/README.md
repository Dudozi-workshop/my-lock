# MY LOCK Crayon Soft Shape Lab

This lab renders Crayon Soft candidates with the same production
`LockTokenPainter` and `ShapeSpecRenderer` used by the app.

## Round 1

- C01: current PREVIEW 008 baseline
- C02-C08: parameter-only Crayon Soft variants
- Candidate cards use exact 58 x 58 logical rendering.
- The 4x panel scales the exact 58 px result instead of re-rendering it.

The lab does not create separate PNG/SVG mockups. A selected candidate can be
promoted by copying its parameter set into
`assets/shape_specs/crayon_soft/style.json`.
