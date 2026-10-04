# Jellyfish R4 — Handoff 2026-10-04

## Status
- Appearance direction: **J04-M3-R4 Compact**
- Current stage: **2-Part Static Master ownership correction**
- Final Body / Legs production masters are **NOT LOCKED yet**.

## Confirmed 2-Part Architecture

### Body Master
Owns:
- Full Bell
- Lower scallop
- Left / right outer rounded lower body lobes
- The yellow-marked rounded side regions from the latest user review are **BODY**, not Legs.

### Legs / Tentacles Master
Owns:
- Main tentacles
- Sub tentacles
- Central hanging appendage structures
- Must not contain Body-lobe pixels.

## Superseded / Reference Only
Do not use as production masters:
- CleanSplit v1
- Registered v3
- Any auto-split candidate with Body/Legs cross-ownership.

## Next Gate
1. Re-split the approved R4 Appearance Master into **Body Only** and **Legs Only** using corrected ownership.
2. Produce independent **2048×2048 RGBA Master Candidates**.
3. Review both parts separately.
4. Do **not** work on Motion, Color/Multi Palette, or Hidden Underlap at this Gate.
5. After Static 2-Part approval, proceed to completed Pose Variant assets:
   - Body: subtle contraction + lower rounded body-lobe flutter.
   - Legs: delayed gentle follow-through.

## Locked Scope
- Approved R4 exterior silhouette and proportions remain fixed.
- Other MY LOCK assets remain untouched.
- Color / Multi Palette is a separate track.
- ImageGen may be used later only if source-missing hidden-underlap pixels are explicitly approved for restoration.


## Hidden Underlap ImageGen Troubleshooting — 2026-10-04

### Incident
- During local Hidden Underlap restoration, ImageGen repeatedly generated a whole jellyfish / QA asset sheet instead of restoring only the approved hidden region.
- All such generated sheets are **REJECTED / NOT FOR PRODUCTION**.

### Approved state retained
- Corrected Split v3 ownership remains approved.
- Merged No-Gap Mask v5 remains the approved restoration boundary.
- Visible Body pixels, exterior silhouette, Legs, Color and Motion remain locked.

### Mandatory prevention rule
1. Confirm the authoritative source binary before any restore.
2. Create and obtain user approval for the restoration mask first.
3. Treat all pixels outside the approved mask as immutable.
4. Never request or accept a QA sheet, comparison layout, labeled panel, or whole-shape redraw from ImageGen.
5. ImageGen output, when used for source-missing pixels, is only a donor for pixels inside the approved mask; it is never the production asset itself.
6. Composite donor pixels into the authoritative source deterministically.
7. Automated gate must pass:
   - outside-mask changed pixels = 0
   - locked visible-region changed pixels = 0
   - Legs unchanged
   - canvas/registration/alpha preserved
   - recomposite visually matches Appearance Master
8. If ImageGen produces a whole-shape redraw or report sheet once, reject it immediately and **do not repeat the same invocation strategy**. Fix the source/mask/compositing path first.
9. For deliverable-report mode, do not generate a new report image. Provide actual Asset / Mask / QA outputs only.

### Current next step
- Hidden Underlap fill remains unresolved.
- Do not promote any v6/v7-style fill or generated QA sheet.
- Resume only with the approved Mask v5 and a source-locked local restoration pipeline.


## Static 2-Part Candidate v13 QA — 2026-10-04
- Current Body candidate: Jellyfish_R4_Body_HiddenUnderlap_Candidate_v13_2048.png
- Current Legs candidate: Jellyfish_R4_Legs_Clean_Candidate_v3_2048.png
- Approved underlap boundary: Merged No-Gap Mask v5.
- Source-lock QA: outside-mask Body changed pixels = 0; locked visible-region changed pixels = 0; new alpha pixels exist only inside Mask v5.
- Runtime order: Body below, Legs above.
- Raw RGBA recomposite differs from Appearance Master in hidden-underlap pixels because the legs contain partial transparency; this is expected for the restored hidden layer and is not treated as geometry drift.
- Status: Candidate / NOT FINAL / NOT LOCKED.
- Next gate: user visual approval, then Static 2-Part Master LOCK and production registration.


## STATIC 2-PART MASTER — FINAL / LOCKED — 2026-10-04
- User approved v13 visual QA and authorized promotion.
- Appearance: J04-M3-R4 Compact.
- Body Master: Hidden Underlap v13 -> FINAL / LOCKED.
- Legs Master: Corrected Split v3 -> FINAL / LOCKED.
- Underlap Mask: Merged No-Gap Mask v5 -> LOCKED support asset.
- Runtime layer order: Body below -> Legs above.
- Canvas: 2048x2048 RGBA.
- QA gate passed: outside-mask Body changed pixels = 0; locked visible Body changed pixels = 0; Legs unchanged.
- Color / Multi Palette and Motion remain separate tracks and were not modified.
- Prior CleanSplit v1 / Registered v3 cross-ownership assets and rejected Hidden Underlap v2/v6/v7-style outputs remain excluded from Production.
- This promotion supersedes Candidate status for the static 2-part geometry only.
