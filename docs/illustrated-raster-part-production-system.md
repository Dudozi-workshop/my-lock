# MY LOCK Illustrated Raster Part Production System v1

Date: 2026-09-27
Scope: complex illustrated raster Shapes and semantic/material Part extraction

## 0. Purpose
This system standardizes the production method proven during Sea Turtle v3 front-flipper work so future Parts are not rebuilt from scratch and QA remains reproducible.

## 1. Non-negotiable source rules
- Use exactly one current **Authoritative Master** per task.
- Complex illustrated raster production uses a **2048x2048 transparent RGBA canonical canvas** unless the Shape Master explicitly overrides it.
- Every Part keeps the Master's exact canvas, coordinate system, scale, anchor and placement.
- Review crops, screenshots and QA boards are never production sources.
- Once a Part is approved, treat it as locked. New work must derive from the locked source, not a reinterpreted copy.

## 2. Scope lock
When the user requests one Part or layer:
- modify only that Part/layer;
- all other geometry, palette, silhouette, shading and overlays remain locked;
- do not regenerate the whole Shape;
- do not silently promote a new candidate over the current Master.

## 3. Production gate sequence
For every semantic/material ownership region, follow exactly:

1. Source confirmation
2. Ownership Overlay on the real source/base
3. User approval of the Overlay
4. Exact Mask derived from the approved Overlay
5. Asset extraction from existing source pixels
6. Removed Remainder
7. Recomposite / Residual QA
8. User approval
9. LOCK / Save / Register

Do not skip gates.

## 4. Overlay-first ownership review
- Ownership decisions are made on an overlay placed over the actual source.
- A mask alone is not sufficient for visual ownership approval.
- The approved overlay is the visual reference; the mask is a technical derivative.
- If the user annotates additions/removals, treat those marks as guidance and rebuild the final overlay against the real source before deriving a mask.

## 5. Extraction vs reconstruction
These are different tasks.

### Extraction
- Source pixels already exist.
- Use deterministic mask/compositing only.
- Image generation is prohibited.

### Reconstruction
- Required pixels do not exist in the source, e.g. Hidden Underlap.
- Only then may reconstruction be considered.
- Image generation still requires explicit approval in that turn.
- After the reconstructed base is approved, all later splits return to deterministic mask/pixel operations.

## 6. Material decomposition model
For illustrated Parts, use a disjoint ownership partition when practical:

- Base / Albedo
- Pattern / Detail
- Shadow
- Highlight
- Outline

Each visible source pixel should be owned by exactly one production region for the decomposition QA pass.
If a compositor intentionally uses overlapping optical layers later, that runtime blend model must be documented separately from source-pixel ownership.

Recommended extraction order:
1. Alpha / ownership boundary
2. Outline
3. Pattern / Detail
4. Shadow
5. Highlight
6. Base / Albedo = source remainder after approved material regions
7. Full Material Recomposition QA

## 7. Required per-layer outputs
For each approved layer keep:
- `*_asset_*_2048.png`
- `*_mask_*_2048.png`
- `*_removed_remainder_*_2048.png`
- `*_ownership_qa_*.png`
- `*_recomposite_*.png`
- `*_recomposite_diff_*.png`
- `*_manifest_*.json`
- optional review crop for visual inspection

## 8. Three-stage QA

### A. Ownership QA
Human visual decision:
- missing area?
- over-selected area?
- wrong semantic owner?
- clipped pattern / broken silhouette?
- problematic attachment/root/tip region?

### B. Technical QA
Deterministic checks:
- canonical canvas and PNG mode
- containment inside source alpha
- overlap pixels
- gap pixels
- isolated noise / holes when relevant
- transparent RGB residue
- recomposite changed pixels
- max channel diff
- manifest/hash integrity

Important: `recomposite diff = 0` only proves the selected pieces reproduce the selected source. It does **not** prove semantic ownership is correct.

### C. Production QA
Usage-oriented checks:
- seam at neighboring Parts
- outline residual
- hidden-underlap reveal
- variant replacement reveal
- runtime-size legibility
- complete Shape recomposition

## 9. Review artifacts
- Prefer a tight review crop around the real problem area.
- Full-canvas files remain the production truth.
- QA boards are summaries only; never substitute them for actual assets/masks.
- Show only the files needed for the current gate. Provide the full bundle when the Part is complete.

## 10. Save and version discipline
Statuses:
- Authoritative Master
- Intermediate
- QA Candidate
- LOCK Candidate
- Final / Locked

Rules:
- User approval is required for promotion to Final / Locked.
- Never overwrite a Master silently; version upward.
- On approval, save immediately so the same extraction is never repeated.
- Register approved state in:
  - Google Drive: production binaries
  - GitHub: spec / manifest / history
  - Notion: decision / current source-of-truth state

## 11. Efficiency rules proven in Sea Turtle v3
- Lock geometry before decomposing visual detail.
- Correct ownership early with overlays; do not polish a wrong mask.
- Work one region at a time rather than generating all layers speculatively.
- Reuse the exact locked 2048 source for every later derivative.
- Separate human semantic approval from numeric recomposition checks.
- Keep each approved layer disjoint during source-pixel decomposition to make gap/overlap QA deterministic.
- Derive Base/Albedo last from the remainder of all approved ownership regions.
- Save every approved gate immediately before moving on.
- For future variants, copy the workflow, not the pixels: each pose gets its own approved ownership and material set.

## 12. Final Part closeout
Before declaring a Part complete:
1. all layer gates are locked;
2. Base/Albedo remainder is generated;
3. all ownership regions cover the visible source exactly;
4. gap = 0;
5. overlap = 0 unless explicitly documented;
6. material recomposite matches the source;
7. PNG integrity passes;
8. runtime-size review is available;
9. final package + manifest are saved and registered.

Then the Part may become the reusable source for later runtime/variant work.


## 13. Palette and runtime gate

A complex illustrated Part is not Final merely because source-pixel recomposition passes.

Before final closeout, verify the actual app palette and runtime presentation:

1. Keep geometry, alpha, pattern, shadow, highlight and outline locked.
2. Apply only the app's registered palette values with deterministic recolor/compositing.
3. Do not use ImageGen for palette application.
4. Verify representative runtime size(s), including the smallest intended display size.
5. Check at minimum:
   - silhouette readability
   - outline continuity/contrast
   - pattern separation
   - highlight retention on bright colors
   - shadow retention on dark colors
   - alpha edge cleanliness
   - light/dark background legibility when relevant
6. Use only palette entries actually registered in the current app runtime unless a separate palette expansion is explicitly approved.
7. Record the exact palette hex values, runtime size, build result and user visual approval in the Part manifest.

Final closeout requires:
- material recomposition QA PASS;
- palette QA approved;
- runtime QA approved;
- build/deployment verification PASS;
- final package saved and registered.
