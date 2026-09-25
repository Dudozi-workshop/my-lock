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
