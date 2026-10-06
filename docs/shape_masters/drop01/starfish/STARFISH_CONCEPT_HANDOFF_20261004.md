# MY LOCK · Drop 01 Starfish Concept Handoff · 2026-10-04

## Status
- Concept Direction: **Selected**
- Selected direction: **Starfish Option 01**
- Appearance Master: **Not created**
- Final / Locked / Active: **NO**
- Production registration: **NO**

## Locked direction for next chat
1. Use **Option 01 only** as the design basis.
2. Preserve:
   - chubby, stable five-arm proportion
   - rounded organic silhouette
   - no eyes / no mouth
   - immediate starfish readability at small size
3. Refine only the illustration style:
   - reduce strong glossy / jelly-like highlight
   - remove roughly 70-80% of decorative dot pattern
   - remove or strongly weaken the bright center-star motif; keep only structural accent if needed
   - prioritize large color masses
   - use shallow, soft shading
   - use a clear illustrated contour blended into local color
4. Do not reopen Options 02-06 unless the user explicitly asks.

## MY LOCK style requirement
Target: Visual DNA v1
- Soft Illustrated 2D / 2.5D
- rounded organic shape language
- large color masses first
- shallow shading for form only
- no black hard outline
- calm, warm, slightly dreamy tone
- avoid plastic / glass / neon identity

## Candidate generation rule
- Do not create a candidate set that differs only by color.
- Round 1 candidates must differ materially in silhouette / proportion / pose / structure / detail density / style interpretation.
- Once the user selects one direction, subsequent rounds refine that selected direction only.

## Workflow decision
- Basic Shape illustration concepting happens **in chat**.
- LABS is **not** the primary drawing/concept tool.
- LABS is used after selection for 58px readability, Color, Runtime, background composition and other downstream QA.

## Cross-Asset QA rule
- Existing approved assets are reference-locked.
- Do **not** regenerate Sea Turtle / Dolphin / Jellyfish with ImageGen.
- Use the actual latest approved Final/Locked/Active or approved Master binaries unchanged.
- Only resize/reposition them for comparison; no pixel/style/lighting edits.
- Candidate Starfish may be generated/edited; reference assets may not.

## Reject history from this chat
Reject / Production unused:
- comparison boards where ImageGen redrew Sea Turtle / Dolphin / Jellyfish
- boards that reintroduced Starfish Options 02-06 after Option 01 had been selected
- generated sheets that labeled Starfish as FINAL before user approval
- any generated reference asset substitutes

These are not valid masters or QA references.

## Next Gate
1. Run MY LOCK Preflight.
2. Re-confirm latest Shape Guide + Drop 01 Asset Master.
3. Create **Option 01-only** Starfish style-calibrated Candidate.
4. Retrieve the actual current approved reference binaries for Sea Turtle / Dolphin / Jellyfish.
5. Build a comparison board by compositing those untouched references next to the Starfish candidate, without ImageGen touching the references.
6. Evaluate: Silhouette / Color Mass / Shading / Detail Density / Edge / Emotional Tone / World Fit.
7. Ask for user visual approval.
8. Only after approval consider Appearance Master promotion and Production asset workflow.

## Important
No Starfish Production binary is approved yet. Do not upload or register a Starfish Final/Locked asset until explicit user approval.

## 2026-10-06 · Appearance Master 승인 / Canonical Gate 진입
- User-approved source: `MYLOCK_Starfish_Character_Appearance_Master_v1_20261006.png`
- Source size: **1254×1254 RGBA**
- SHA-256: `8fecfec9afb0cfd6a4b89d522eb5c5052a46b40a39aae44c07f5fcba946f4fa2`
- Status: **User Approved / Active Appearance Master / Not Production Locked**
- The approved source is preserved byte-for-byte. No redraw or ImageGen refinement after approval.
- Production Canonical Candidate: `MYLOCK_Starfish_Production_Canonical_Candidate_v1_2048_20261006.png`
- Canonical SHA-256: `8b6c052bcef729d366c7cd8d1fe74e2db54e3184437ba854df8cb0061e5ef739`
- Canonical method: premultiplied-alpha Lanczos resize to 2048×2048 only. No crop, geometry reinterpretation, or optical-size adjustment.
- Ownership model: **Full Body = Single Part**
- Ownership Overlay Candidate: `MYLOCK_Starfish_Ownership_Overlay_Candidate_v1_2048_20261006.png`
- Overlay SHA-256: `0dba9d837ae96ee6039c6f70a3aa04cc3f76f0dd3088793a59c006c0b93dfadd`
- Overlay is **planning overlay only / not a mask**.
- Cross-asset 58×58 optical mass / occupancy calibration is intentionally deferred until post-production QA.
- **Current Gate:** Ownership Overlay user approval → Mask. Do not proceed to Mask / Asset / Removed Remainder before approval.

## 2026-10-06 · Single-Part Package Candidate v1 / QA
- Source Ownership: **Full Body = Single Part / user approved**
- Mask: `MYLOCK_Starfish_Ownership_Mask_Candidate_v1_2048_20261006.png`
- Asset: `MYLOCK_Starfish_FullBody_Asset_Candidate_v1_2048_20261006.png`
- Removed Remainder: `MYLOCK_Starfish_Removed_Remainder_Candidate_v1_2048_20261006.png`
- Recomposite QA: `MYLOCK_Starfish_Recomposite_QA_v1_2048_20261006.png`
- Clean Canonical Candidate v2: `MYLOCK_Starfish_Production_Canonical_Clean_Candidate_v2_2048_20261006.png`
- Package: `MYLOCK_Starfish_PartPackage_Candidate_v1_2048_20261006.zip`
- Package SHA-256: `a380390cb1e1a5c0ce030a490e3c32b566836746b3579858bc35c9c5ed073ddb`
- QA: source recomposite changed pixels **0** / max channel delta **0** / owned pixel max delta **0** / asset connected components **1** / canvas-edge touch **0**.
- Residual cleanup: source canonical v1 contained **1,874 visible pixels in 299 detached components** outside the main connected starfish body. These were isolated as Removed Remainder and excluded from Clean Canonical Candidate v2. Main owned body pixels are unchanged.
- Status: **QA Candidate / User Review Required / Not Locked**
- Cross-asset 58x58 optical mass calibration remains deferred until Starfish production lock review.
- Next Gate: user review of Mask / Asset / Remainder / QA package -> approval -> LOCK candidate.

## 2026-10-06 · Production LOCK
- User approved the QA package and advanced Starfish to LOCK.
- Production Master: `MYLOCK_Starfish_Production_Master_FINAL_LOCKED_2048_20261006.png`
- Production Master SHA-256: `2a10f97517071245b5b240e273faa302fef8a433a19aae3624d9dfe8cb03c76c`
- Full Body Asset: `MYLOCK_Starfish_FullBody_Asset_FINAL_LOCKED_2048_20261006.png`
- Asset SHA-256: `2a10f97517071245b5b240e273faa302fef8a433a19aae3624d9dfe8cb03c76c`
- Ownership Mask: `MYLOCK_Starfish_Ownership_Mask_FINAL_LOCKED_2048_20261006.png`
- Mask SHA-256: `8d954ebfcacc2ab82072d0e26188b73915cc7d95e382d4f45eb7da6d8dad4c6f`
- Removed Remainder: `MYLOCK_Starfish_Removed_Remainder_FINAL_LOCKED_2048_20261006.png`
- Remainder SHA-256: `e3f878e434edee5b0e676dfc60b3329aea41db871cb1856b60d14f1a27ebb3b6`
- Manifest: `MYLOCK_Starfish_Production_Manifest_FINAL_LOCKED_20261006.json`
- Package: `MYLOCK_Starfish_Production_Package_FINAL_LOCKED_20261006.zip`
- Package SHA-256: `671356515f0c781d1887a889cb5761489bc03c9aaeaa5abd61a1f0b71b99bd59`
- QA basis: source recomposite changed pixels 0 / max channel delta 0 / owned body delta 0 / asset connected components 1 / canvas-edge touch 0.
- Ownership model remains **Full Body = Single Part**.
- Status: **FINAL / LOCKED / ACTIVE PRODUCTION MASTER**
- Important: 58×58 cross-asset optical mass / occupancy calibration is **not part of this pixel lock** and remains a downstream runtime sizing step. The locked master pixels must not be redrawn for that calibration.

- Drive archive: https://drive.google.com/file/d/1AvUsUxgx9oLErc7CrgTqIIBn7W0oGYXj/view?usp=drivesdk

## 2026-10-06 · LOCK rollback / Runtime QA HOLD
- The earlier same-day promotion of the new face-bearing Starfish candidate to FINAL / LOCKED was premature.
- Superseding state for the **new 2026-10-06 face-bearing appearance lineage**: **QA CANDIDATE / PRODUCTION LOCK HOLD**.
- Reason: MY LOCK Shape Production requires small-size detail QA, palette/color substitution QA, runtime rendering verification, and cross-asset optical-mass calibration before production lock.
- Existing historical `ASSET_REGISTRY_V1.md` / `Starfish_Production_FINAL_LOCKED_v1.zip` belong to the earlier **eyeless** Starfish production lineage and are not the authoritative production source for this new face-bearing candidate.
- New runtime QA registry: `assets/shape_masters/drop01/starfish/ASSET_REGISTRY_V2.md`.
- Current new-candidate runtime model: Full Body single-part ownership + separate semantic color ownership. Eyes/mouth remain fixed non-color detail; body/contour/spots/cheeks/shading are palette-driven.
- Drop 01 static palette QA completed for Deep Ocean / Aqua Mint / Coral Pink / Sand Beige / Lavender / Peach Orange.
- Automated QA: palette alpha mismatch 0 px; fixed-face core RGB variation <=1 level; runtime edge alpha 0 px; transparent RGB residue 0; lossless WebP decode PASS; geometry unchanged; ImageGen not used for split.
- Small-size QA completed at 160/120/100/80/58 px. Eyes remain readable at 58 px; mouth is a WATCH item at 58 px because it weakens first.
- **Still required before LOCK:** user review of runtime QA -> cross-asset optical-mass calibration using actual approved Sea Turtle/Dolphin/Jellyfish binaries -> APP EXACT / Shape Lab verification -> user approval -> LOCK.
