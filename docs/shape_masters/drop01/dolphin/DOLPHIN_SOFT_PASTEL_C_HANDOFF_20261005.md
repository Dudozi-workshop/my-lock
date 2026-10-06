# Dolphin Soft Pastel Storybook — C Direction Handoff — 2026-10-05

## Status
- Character construction direction: **C · Slim / Graceful — SELECTED**
- Style system: **MY LOCK Visual Style Rule v1 · Soft Pastel Storybook**
- Style anchor: **Jellyfish Character Appearance Master v1**
- **Character Appearance Master v1 — USER APPROVED**
- **Production Canonical Candidate v1 / 2048 RGBA — QA CANDIDATE / NOT LOCKED**
- Existing Dolphin Planning Master v2 remains **FINAL / LOCKED / ACTIVE** and is not overwritten.

## Authoritative Existing Master
- File: `Dolphin_Planning_Master_Eyeless_v2_20261003.png`
- Drive file ID: `13LUKWfOCD6OcDAEFT7D_1HXnSEAe5DAW`
- Role: existing locked geometry / production lineage reference
- Eye elements: removed in the locked v2 lineage.

## Approved Soft Pastel Appearance Master
- File: `MYLOCK_Dolphin_Character_Appearance_Master_v1_20261005.png`
- Size: **1254×1254 RGBA**
- SHA-256: `8b34790f35a01b7234f2331eda57c65908cf84d2e168ab68749285be659c8f3a`
- Drive file ID: `1-Q5sGQ73QGGOlyiRLdjrm1UxJT2qUeKj`
- Status: **Appearance Master v1 / User Approved / Active in Soft Pastel appearance lineage**
- Visual direction: C · Slim / Graceful
- Characteristics:
  - slim elongated body
  - narrow posterior taper
  - gentle upward 3/4 hero pose
  - rounded fins and tail
  - pastel watercolor/wash texture
  - soft colored contour
  - shallow shading
  - minimal face subordinate to silhouette

## Production Canonical Candidate
- File: `MYLOCK_Dolphin_Production_Canonical_Candidate_v1_2048_20261005.png`
- Size: **2048×2048 RGBA**
- SHA-256: `ebd1e4a1e481299de701bb124176e4bf22bd551c5a15c0e8ff0a7ccff54336ee`
- Drive file ID: `1ljzHXELbRn_Yjse81iF6cFIVrcT5Oems`
- Source: approved Appearance Master v1
- Method: premultiplied-alpha Lanczos resize only; no ImageGen, redraw, or geometry reinterpretation
- Status: **QA Candidate / Not Final / Not Locked**
- Existing Planning Master v2 remains unchanged.

## Superseded / Reject History
- `MYLOCK_Dolphin_SoftPastel_C_Direction_Candidate_v1_20261005.png`: superseded; body mass too thick relative to intended C.
- First standalone post-C generation that drifted toward A/Calm: rejected / production unused.
- Production prevention rule: never revert to generic dolphin proportions after C direction is selected.

## Locked Scope
- Do not modify existing Dolphin Planning Master v2.
- Do not modify Sea Turtle, Jellyfish, Starfish, Motion, Color, Background, or Effects in this gate.
- General layer separation must not use ImageGen.
- Hidden-underlap reconstruction, if required later, needs explicit user approval first.

## Next Gate
Canonical Production Asset Rule now advances to:
1. **Ownership Overlay**
2. **User approval**
3. Mask
4. Asset
5. Removed Remainder
6. Recomposite / Residual QA
7. User approval
8. LOCK

Current stop point: **Ownership Overlay approval required before Mask generation.**


## Ownership Overlay Troubleshooting / Prevention — TS-012
### Reject history
- v2-v6 and v8-v9: **REJECTED / Production unused**.
- v7: **Working Reference only / Not Approved / Not Final**.

### Root cause
- Ownership Overlay was incorrectly treated as a part-geometry redraw step.
- User rough paint was copied or converted into polygon/spline boundaries instead of being used only as a semantic seed.
- Existing canonical alpha/colored contours were ignored and new artificial outer boundaries were introduced.
- Cleanup requests were misread as redraw requests, increasing drift instead of reducing it.

### Active prevention rule
1. Approved 2048 canonical pixels remain immutable.
2. User markup is **semantic seed only**.
3. Existing canonical alpha edge / colored contour / visible fold line is the authoritative outer boundary.
4. Do **not** redraw outer perimeter with polygon / bezier / spline.
5. For closed-contour parts, extract ownership from the existing contour directly.
6. For partially occluded parts, keep the existing visible silhouette and define only the minimum root cut.
7. Hidden Underlap reconstruction requires explicit user approval.
8. Dorsal remains Body Core unless independent motion is explicitly required.
9. Overlay presentation uses translucent fill only; new outline is prohibited except a minimal root-cut QA cue.
10. User approval of Ownership Overlay is required before Mask / Asset / Removed Remainder generation.
11. Scope-limited cleanup must keep non-target ownership bit-identical.

### Dolphin recovery point
- Roll back to v7's **4-part structure** only:
  - Body Core + Dorsal
  - Near Flipper
  - Far Flipper
  - Tail
- Next refinement:
  - Near Flipper = direct extraction of existing closed colored contour.
  - Far Flipper = existing visible silhouette + minimum root cut.
  - Tail / Body / Dorsal unchanged.
- No polygon/spline redraw.


## Ownership Overlay v10 — Approved
- File: `MYLOCK_Dolphin_Ownership_Overlay_v10_APPROVED_2048_20261005.png`
- Drive file ID: `1zJnlLWsARRAOFfjrX14lt9vhZZ3SmroK`
- Status: **User Approved / Ownership Overlay Approved / Not Mask / Not Final Locked**
- Structure: Body Core + Dorsal / Near Flipper / Far Flipper / Tail
- Near/Far Flipper boundaries refined from canonical pixels under TS-012. No polygon/spline redraw and no new outer outline.
- Tail / Body / Dorsal preserved from v7 reference.
- Next Gate: **Mask generation** from the approved ownership, then Asset → Removed Remainder → Recomposite / Residual QA → user approval → LOCK.


## Part Package Candidate v1 — Mask / Asset / Remainder / QA
- Package: `MYLOCK_Dolphin_PartPackage_Candidate_v1_2048_20261005.zip`
- Package SHA-256: `1ffc5b7acfb575c64090f8219b2410b32ff0e746b81aeadd28a86568d1fee340`
- Source Ownership: **v10 User Approved**
- Parts:
  - Body Core + Dorsal
  - Near Flipper
  - Far Flipper
  - Tail
- Method: direct extraction from approved ownership masks; no ImageGen, redraw, or hidden-underlap generation.
- Mask overlap: **0 px**
- Mask union vs Canonical alpha mismatch: **0 px**
- Per-part Asset + Removed Remainder recomposite: **all 0 px mismatch / PASS**
- Full 4-part recomposite vs Canonical: **0 px mismatch / max channel delta 0 / PASS**
- Residual QA: **0 changed visible pixels / PASS**
- Status: **Candidate / User Review Required / Not Locked**
- Drive publication is pending user approval of this package.
- Next Gate: user visual/package approval → register final package / LOCK.


## Ownership Masks v3 — Approved
- Package: `MYLOCK_Dolphin_Ownership_Masks_Candidate_v3_2048_20261005.zip`
- Status: **User Approved / Mask Gate Passed / Not Asset / Not Final Locked**
- Parts: Body Core / Near Flipper / Far Flipper / Tail
- QA:
  - overlap = 0 px
  - canonical union mismatch = 0 px
  - detached residual lines cleaned
  - canonical pixels unchanged
  - ImageGen unused
- Source Ownership: **Overlay v10 Approved**
- Next Gate: **Asset extraction** only. Removed Remainder / Recomposite remain deferred until Asset QA.


## Part Assets v1 — Approved
- Package: `MYLOCK_Dolphin_Part_Assets_Candidate_v1_2048_20261006.zip`
- Status: **User Approved / Asset Gate Passed / Not Final Locked**
- Parts: Body Core / Near Flipper / Far Flipper / Tail
- Method: direct extraction of Canonical RGBA through approved Mask v3.
- QA: part overlap 0 px; approved mask domain recombine mismatch 0 px; no new pixels; no ImageGen; no Hidden Underlap reconstruction.
- Next Gate: Removed Remainder.

## Removed Remainders v1 — QA Candidate
- Package: `MYLOCK_Dolphin_Removed_Remainders_Candidate_v1_2048_20261006.zip`
- Parts: Body Core / Near Flipper / Far Flipper / Tail
- Method: canonical copy with exactly the selected approved mask region cleared to RGBA 0.
- QA per part:
  - removed-region nonzero RGBA = 0 px
  - outside-region mismatch vs Canonical = 0 px
  - corresponding Asset inside-mask mismatch = 0 px
  - Asset outside-mask nonzero alpha = 0 px
- Status: **QA Candidate / User Review Required / Not Recomposite / Not Locked**
- Next Gate after approval: Recomposite / Residual QA.
