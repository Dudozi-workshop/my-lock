# MY LOCK Core Shape Masters · Basic v1

Status: MASTER / GEOMETRY LOCKED  
Approved: 2026-09-26  
ViewBox: 100 × 100

This directory stores the canonical geometry masters for the three free Core shapes.

## Policy

- These files define Shape geometry only.
- Crayon Soft texture, wax grain, rough edge, highlight, shade, shadow, and other Style-layer data are not part of the Shape Master.
- Soft Basic, Crayon Soft, and future styles should derive their silhouette and optical proportions from these masters.
- Runtime-optimized ShapeSpec files are Derived Assets and must not replace these masters.
- Master changes require a new version directory (v2, v3, ...). Do not overwrite v1.

## Masters

- circle_master_v1.json
- triangle_master_v1.json
- square_master_v1.json
- manifest.json

## Source provenance

The v1 geometry was promoted from the currently approved Crayon Soft Core shapes on 2026-09-26.

- Circle source: assets/shape_specs/crayon_soft/circle.json
- Triangle source: assets/shape_specs/crayon_soft/triangle.json
- Square source: assets/shape_specs/crayon_soft/square.json

Only the body geometry was promoted. Style-specific layers remain in their own Style domain.
