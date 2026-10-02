# Sea Turtle v3 · Runtime v3 Handoff — 2026-10-02

## Current locked scope
- Q3 Canonical Whole Assembly: locked.
- Individual Part Geometry / Material / Ownership: locked.
- No ImageGen.
- Runtime changes must remain downstream Derived Asset work only.

## Current runtime state
Runtime v1/v2 proved the shared RasterShapeRegistry / RasterShapeBootstrap / LockTokenPainter path, but the 58 px texture should not remain the long-term production source.

Runtime v2 added transparent safety padding because the original 58 px alpha reached both left and right canvas edges and could expose a rectangular crop boundary during rotation.

Runtime v2 is **Intermediate**, not Final.

## Runtime v3 decisions
1. **256 px padded Runtime Master**
   - Derive from the approved 2048 Whole Canonical Assembly.
   - Use lossless WebP.
   - Keep sufficient transparent safety padding.
   - 58 px becomes display/readability QA only.

2. **Metadata-driven raster placement**
   Minimum metadata:
   - shape_id
   - runtime_canvas
   - content_bbox
   - anchor
   - display_scale
   - safety_padding_ratio
   - source hash

   Renderer should read metadata instead of accumulating ShapeKind-specific magic scale constants.

3. **2-layer raster renderer**
   - Palette Base: Base / Albedo; palette-changing region.
   - Fixed Finish: Outline / Shadow / Highlight / Detail; preserved independently from palette changes.
   - Goal: palette changes without flattening material detail.

4. **Aurora Sea animated palette**
   - Applied only to Palette Base.
   - Alpha-clipped to the Shape.
   - Fixed Finish remains visually stable.
   - Low-intensity moving Blue / Pink / Yellow / Purple field.
   - Must preserve shading/detail readability.

5. **Production-component QA**
   Validate:
   - 256 Runtime Master
   - 58 px actual display
   - Light / Dark
   - Pink / Blue / Yellow
   - Aurora Sea animation
   - rotation
   - floating motion
   - repeated spawn
   - pop animation
   - no alpha leakage
   - no rectangular crop boundary
   - Customize ShapeChoiceCard
   - FloatingPreview
   - Android lockMain / LockMode

## Non-goals
- Do not modify 2048 Canonical Assembly.
- Do not modify locked Part Geometry / Material / Ownership.
- Do not use 58 px as the canonical or production master.
- Do not solve runtime framing by changing locked source geometry.

## Next gate
Implement **Runtime v3** and only promote it after production-component QA and user visual approval.
