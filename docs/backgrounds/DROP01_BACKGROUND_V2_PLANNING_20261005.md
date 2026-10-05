# Drop 01 Background v2 Planning — 2026-10-05

## Status
- Active planning direction for Drop 01 backgrounds.
- Existing background binaries, QA records, and approved motion/effect work are preserved and not overwritten by this planning update.

## Mini World
- Working mini-world: **작은 바다 쉼터**.
- Core: a bright, cozy Soft Storybook Ocean World where small sea friends drift, gather, and rest.
- Drop 01 prioritizes brightness, warmth, open play space, rounded environmental forms, and gentle everyday life over dark/deep-sea drama.
- Shapes are the residents; backgrounds are the illustrated stages they inhabit.
- Not every background is motion-heavy. Tier hierarchy is expressed through environment depth, scene richness, and signature moments.

## Active Background Roster

### Normal · 맑은 물길
- Role: minimal, versatile Ocean Base / open path leading toward the shelter.
- Bright Aqua / Ocean Blue, generous negative space, minimal environment, high Shape readability.
- Mostly static. At most, one very subtle surface-brightness motion may be considered later.
- Requires a new Minimal Redesign.

### Rare · 산호 쉼터
- Role: representative Drop 01 Story Scene / central gathering place.
- **Maximally inherits the current implementation of the former 01 투명한 얕은 바다.**
- Lineage to preserve: Base Only v2 environment composition, R27 A Flow Light, R31 Cell Flow, and the useful subset of R28 Ambient/Bubble.
- Existing 01 implementation history and QA remain valid lineage; do not delete or overwrite.
- Follow-up visual QA may reduce density to match Visual DNA v2, but lineage assets remain immutable unless separately versioned.

### Legendary · 빛나는 바다정원
- Role: highest-tier bright Hero Scene for Drop 01.
- Replaces the former active direction of 고요한 심해; that darker Deep Blue / bioluminescent concept is preserved as historical planning only.
- Bright Aqua / Mint / Coral / Peach / Lavender, layered storybook environment.
- Tier difference should come from scene response and a unique Signature Moment, not merely from adding more objects.
- Motion should be selective: subtle multilayer environment motion plus one dedicated Signature Light Moment.

## Tier Expression Rule
- **Normal:** 1–2 depth layers / mostly static / minimal environment.
- **Rare:** 2–3 depth layers / increased environment detail / 1–2 independent background motions.
- **Legendary:** 3–4 depth layers / subtle whole-scene response / at least one unique Signature Moment.
- Tier must be visibly experienced through spatial richness and direction, not only through labels or colors.

## Historical Planning
- Former roster `01 투명한 얕은 바다 / 02 바닷속 하루 / 03 고요한 심해` is superseded as Active Planning and retained as history.
- The former `바닷속 하루` 24-hour real-time-linked system is removed from current Drop 01 scope and may return later as a standalone Legendary Dynamic Background concept.
- Existing former-01 background binaries and the Base/R27/R28/R31 implementation remain preserved.

## Rare · 산호 쉼터 — Migration Visual QA · 2026-10-05

### Source
- Inherited visual source: former **01 투명한 얕은 바다 · A Open Water · Base Only v2 Approved**.
- Approved visual binary remains unchanged: `shallow_clear_base_only_v2_approved_candidate.png`.
- Existing R27 / R28 / R31 assets and QA history remain lineage assets and are not renamed or regenerated as part of this migration.

### Visual QA Result
- **PASS — Mini-world fit:** bright Aqua/Blue palette, rounded reef forms, pastel coral accents, and broad soft depth read as a cozy Soft Storybook ocean rather than a realistic reef.
- **PASS — Central Play Field:** the center remains strongly open and low-detail; Shape readability remains the visual priority.
- **PASS — Rare tier fit:** the scene already provides clear foreground / midground / surface depth and environmental richness without requiring a new Base.
- **PASS — Composition:** environmental detail is concentrated at the lower/side edges, especially the lower-left cluster, while the main floating area remains open.
- **PASS — Visual DNA v2 compatibility:** no black hard outline, no photorealistic lighting, no deep AO, and no glossy/plastic identity dominates the Base.
- **WATCH — Peripheral density:** the lower-left coral/rock/shell cluster is intentionally richer than Normal. Do not simplify the approved Base pre-emptively; first evaluate the Full Composite with actual Shapes.
- **WATCH — Motion density:** R27 A Flow Light + R31 Cell Flow already satisfy the Rare target of 1–2 independent background motions. R28 Ambient/Bubble should be treated as subordinate/optional atmosphere, not as an additional equally strong motion layer.

### Migration Decision
- The approved former-01 Base is **accepted as the current visual candidate for Rare · 산호 쉼터 without redraw**.
- No Base pixel changes are approved in this migration.
- Former slot naming is historical; active product-slot identity is **Rare · 산호 쉼터**.
- Existing binary IDs, checksums, Drive files, and QA evidence remain immutable lineage references.
- Any future polish must be versioned as a new candidate and must not overwrite Base Only v2.

### Next Gate
- Full Composite QA using the inherited Base + fixed R27 A Flow + fixed R31 Cell Flow.
- R28 is reviewed at low/subordinate intensity or optional state during composite QA.
- Use actual approved Shape assets for post-composite readability QA; do not regenerate Shapes.


## Rare · 산호 쉼터 — Base Refinement Gate · 2026-10-05

- Goal: evaluate whether the inherited approved Base needs a dedicated v3 edit for stronger place identity.
- Result: **no pixel edit required**.
- The approved `background.drop01.shallow_clear.base_only_v2` already satisfies the intended composition:
  - lower-left main coral shelter cluster,
  - smaller lower-right environmental counterweight,
  - broad central Play Field,
  - open upper water column.
- Do not create a redundant Base Candidate v3.
- Do not overwrite or rename the approved Base binary, checksum, Drive source, or lineage.
- ImageGen was not used; approved-Base lock and current ImageGen hard gate remain intact.
- R27 A Flow already functions as upper/mid spatial light and R31 Cell Flow as lower surface light; preserve both approved motion profiles unchanged.
- R28 Ambient/Bubble remains Optional and default OFF for Rare composite QA.
- Next gate: R32 Full Composite visual review at 6 / 9 / 12 runtime Shapes. If accepted, stabilize the Rare body state before adding any Coral Light Sweep signature moment.
