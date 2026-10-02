# Whole-shape Canonical Assembly QA Standard v1

Status: Active System Rule  
Effective: 2026-10-02

## Purpose
This standard defines how complex illustrated raster Shapes are assembled and validated at whole-shape level after all Parts reach Final / Locked / Active.

## Canonical rule
- Whole-shape seam/material QA must not use Runtime assets as assembly sources.
- Every Part must use its Final / Locked / Active 2048x2048 RGBA full-canvas Production Asset.
- Every Part keeps the Authoritative Master coordinate system.
- Assembly is performed at (0,0) with no bbox reconstruction, crop enlargement, per-Part scaling, or positional correction.
- Render order / occlusion order is the only assembly-level variable allowed before an explicit rollback.

## Required assembly flow
1. Resolve current Final / Locked / Active 2048 Part assets from the Source of Truth.
2. Verify each file is 2048x2048 RGBA full-canvas and belongs to the current active lineage.
3. Verify no Runtime, Review Crop, QA Preview, or legacy asset is mixed into the source set.
4. Composite every Part at (0,0) using the approved render order.
5. Inspect the 2048 whole-shape composition for:
   - seam / gap
   - double outline / excessive seam thickness
   - attachment continuity
   - residual pixels
   - render order / occlusion
   - palette and material continuity
   - silhouette continuity
6. Only after 2048 Whole Assembly QA passes, create Runtime Derived assets.
7. Validate Runtime exports and final 58 px Light / Dark readability.

## Invalid assembly conditions
The Whole Production QA result is invalid if any of the following occurs:
- a 512 / 58 px Runtime asset is used as a canonical Part source;
- a crop is enlarged and repositioned with bbox math to reconstruct a canonical Part;
- Parts of different LOD/resolution are mixed;
- one or more active Parts are missing;
- per-Part scale or coordinate compensation is introduced;
- a Review/QA image is used as a Production source.

Such outputs are Reference-only and must not be promoted to Final / Locked.

## Runtime relationship
Runtime QA is downstream of Canonical Assembly QA:
2048 Canonical Parts -> 2048 Whole Assembly -> Whole Seam/Material QA -> Runtime Export -> 58 px QA.

Runtime optimization never becomes the upstream source for Whole Canonical Assembly.

## Sea Turtle v3 failure case
The first Whole-turtle QA Candidate v1 mixed 512 neutral runtime layers and a tight 58 px Near Flipper crop. This caused:
- incomplete whole-shape assembly;
- visible resolution/LOD mismatch between Underbelly and Flipper;
- an artificial bbox placement requirement for Near Flipper.

The candidate is withdrawn and retained only as a failure/reference example. Individual Part Finals remain valid and locked.
