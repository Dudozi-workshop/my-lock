# MY LOCK Style Lab

The standalone Labs build is the comparison surface for production-rendered
Shape/Style experiments.

## Style separation

- Soft Basic: locked reference only in this Crayon round.
- Crayon Soft: active experimental style.
- Each style keeps its own candidate set; candidates are never mixed across
  styles.

## Crayon Soft Round 2

Round 1 selected C08 as the direction. Round 2 compares only C08 derivatives:

- C08-A: baseline C08
- C08-B: lower underpaint coverage
- C08-C: wider spacing / more visible paper gaps
- C08-D: strongest broken-stroke, childlike incomplete fill

All candidates use the production `LockTokenPainter` and
`ShapeSpecRenderer`. No screenshot or separately drawn PNG/SVG is used.

New coverage parameters default to the PREVIEW 008 behavior, so Soft Basic and
the current app Crayon preset are unchanged until a candidate is explicitly
promoted.

## Round 6 · Thick Crayon Brush

The active comparison deliberately moves away from fine pencil-like texture.

- E01: ~3 px edge / ~2 px fill
- E02: ~3 px edge / ~3 px fill
- E03: ~4 px edge / ~2.5 px fill
- E04: ~4 px edge / ~3 px fill
- E05: E04 + repeated contour passes
- E06: E04 + uneven child-like fill strokes
- E07: E05 + visible paper gaps
- E08: balanced reference-target candidate

All candidates are rendered by the production ShapeSpecRenderer at 58 logical
pixels. The contour and fill share the same palette hue; no white or
independent outline color is introduced.
