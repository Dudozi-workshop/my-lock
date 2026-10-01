# Sea Turtle v3 · body_with_rear Material Profile v1

- Status: **Active material direction**
- Geometry: **body_with_rear Geometry FINAL_v2** — locked
- Outline: **Outline FINAL_v3** — locked
- Pattern / Detail: **separate Production layer omitted**
- Active material sequence: **Shadow → Highlight → Base / Albedo → Material Recomposition QA → Palette QA → Surface / Material Compatibility QA → Runtime QA**
- ImageGen: **prohibited**

## Decision — 2026-10-01
User approved simplifying body_with_rear away from a dense Pattern / Detail layer.

Rationale:
- body_with_rear prioritizes body volume, neck/rear-flipper depth and small-size readability over decorative surface pattern ownership;
- dense pattern ownership produced unnecessary micro-detail at runtime scale;
- structural cues should be carried by broad Shadow / Highlight regions;
- existing source pattern pixels remain part of the source/base unless they are intentionally owned by an approved Shadow or Highlight region.

## Candidate history
- Pattern / Detail Ownership Overlay candidates v1–v3: **not active / not approved / do not promote**.
- They are retained only as exploration history.

## Locked scope
No geometry, silhouette, alpha, Outline, shell_main, underbelly, front_flipper_near or front_flipper_far changes are authorized by this decision.

## Current Gate
**Shadow Ownership Overlay**.
