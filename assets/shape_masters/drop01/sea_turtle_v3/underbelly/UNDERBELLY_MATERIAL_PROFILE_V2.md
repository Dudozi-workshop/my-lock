# Sea Turtle v3 · Underbelly Material Profile v2

- Status: **Active material direction**
- Geometry: **Underbelly FINAL_v4_cleanup** — locked
- Outline: **Outline Final v1** — locked
- Pattern / Detail: **separate Production layer omitted**
- Shadow: **v1 lineage retained / broad structural shading only**
- Active material sequence: **Outline → Shadow → Highlight → Base / Albedo → Material Recomposition QA → Palette QA → Surface / Material Compatibility QA → Runtime QA**
- ImageGen: **prohibited**

## Decision — 2026-10-01
User approved simplifying Underbelly using the same material direction as body_with_rear.

Rationale:
- dense Pattern / Detail ownership can read too strongly at runtime scale;
- Underbelly should prioritize broad form, belly plane, and soft volume rather than decorative micro-detail;
- structural cues should be carried by broad Shadow / Highlight regions;
- existing Pattern / Detail v1 pixels return to Base / Albedo unless intentionally re-owned by approved Shadow or Highlight regions.

## Lineage
- Pattern / Detail Final v1: **Superseded / Inactive material lineage**.
- Preserve files and manifests for history; do not delete or promote as active runtime material.
- Previous Highlight Ownership Overlay Candidate v1: **Superseded / do not promote**.

## Locked scope
No changes to Geometry, silhouette, alpha, Outline, body_with_rear, shell_main, front_flipper_near, or front_flipper_far.

## Current state — Material Decomposition v2 complete
- Highlight Ownership v2: approved by user continuation instruction and deterministically materialized.
- Highlight Mask / Asset / Removed Remainder: complete.
- Base / Albedo v2: derived as exact remainder after locked Outline + locked Shadow + Highlight v2.
- Material Recomposition QA: PASS.
- Source visible support: 136,758 px.
- Coverage gap: 0 px.
- Pairwise ownership overlap: 0 px.
- Recomposite changed pixels: 0.
- Recomposite max channel diff: 0.
- Package: https://drive.google.com/file/d/1asZ_-PD9FLf0_CgSEwjwy1u8uoyotoHU/view?usp=drivesdk

## Next Gate
**Palette QA**. Geometry and all material ownership remain locked during palette evaluation.
