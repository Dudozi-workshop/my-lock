# MY LOCK · Drop 01 Background Handoff · 2026-10-04

## Current handoff · R17 candidate
- R16 deployed at `00f656e8a57c9e0c9b44f531573f5ec9fcb3bf2e`, CI `37216758856` success; user verdict Modify: too weak.
- R17 uses user concept `76252.png`, panel 03 Volumetric Light v1 as visual direction: brighter cores, broad irregular ribs and clear gaps within 3 fan-shaped shafts. Mid-water fade retained; no surface/floor changes.
- Current release: LABS-2026.10.05-R17. CI/deploy/public verification before user Live review. A art approval pending.

## Previous handoff · R16 candidate
- Preflight reconciliation: older R14 sections below are history. R15 deployed at `365e0f02998a54efbb7bccbb63432453ea90d33f`, Actions `37215859267` success; user verdict Modify (visible, quality insufficient).
- A Broad Sunbeam R16: original procedural light with broad merging lobes, unequal main/support energy and depth-delayed motion. Reference: https://motionarray.com/stock-motion-graphics/light-rays-overlay-loop-1055584/ (preview study only; no stock import).
- Release identity: LABS-2026.10.05-R16. CI/deploy/public checks required before live review; user Keep/Modify/Reject pending.
- Base Only v2 Approved / immutable; B/C R14 unchanged; Surface Deferred; Floor Rework Required; all other effects locked. Background is not Final/LOCK.
- Base v2 is registered and rendered through `background.drop01.shallow_clear.base_only_v2`; older registration-pending notes below are history.

## Scope
Drop 01 Background production handoff after Background Lab structure, Reference Asset Rule v1, Background Canvas Standard v1, and shallow-clear Base Only approval.

## Confirmed Structure
- Background Lab: Drop → Background → Production Step
- Drop 01 backgrounds:
  - 01 투명한 얕은 바다
  - 02 바닷속 하루
  - 03 고요한 심해
- Production Step:
  - 01 배경 이미지
  - 02 레이어 효과
  - 03 합성 QA
  - 04 Final
- P0~P8 internal gates remain internal state only.

## Reference Asset Rule v1
- No production PNG/WebP payload hardcoding.
- Resolve by stable Asset ID → Registry → Runtime binary path.
- Notion = decision/specification.
- Google Drive = canonical binary / approved visual binaries.
- GitHub = runtime binary + registry + implementation docs.
- Integrity gate: byte size / SHA-256 / format signature / dimensions / public asset verify.

## Approved Core Composition Reference
- Asset ID: background.drop01.shallow_clear.v1
- File: shallow_clear_base_v1.webp
- Role: Approved Core Composition / Tone Reference
- Size: 1024×1536
- Status: selected_base_candidate / not Final / not Locked
- Canonical Drive:
  MY LOCK Assets / Drop 01 - 작은 바닷속 / Background Masters / shallow_clear_base_v1.webp
- Runtime:
  assets/backgrounds/drop01/shallow_clear_base_v1.webp
- SHA-256:
  e04aa1a84cbac0d6635fed2d67b703c81ebb9353d3894e7a6e9af18e7a05c599

## Newly Approved Base Direction
- Composition direction: **A Open Water**.
- User-approved visual: **Base Only v2**.
- Keep:
  - pastel 2D MY LOCK underwater language
  - Blue/Aqua depth gradient
  - sand perspective
  - lower-left coral / rock / seaweed / shell cluster
  - large open central Play Field
  - soft distant reef silhouettes
- Do not bake into the Base:
  - Surface Refraction / animated surface-light pattern
  - Volumetric Light / light beams
  - Floor Caustic
  - Bubble
  - Ambient Particle / floating debris / sparkle
- Base approval means the environment/composition is fixed for the next step; it does **not** mean complete Background Final/LOCK.

## Approved Visual Binary Registration
- File: `shallow_clear_base_only_v2_approved_candidate.png`
- Drive:
  https://drive.google.com/file/d/1S_kuKZd9HWtKiVzrJNKNfgm0NivgQc4O/view
- Drive path:
  MY LOCK Assets / Drop 01 - 작은 바닷속 / Background Masters / shallow_clear_base_only_v2_approved_candidate.png
- Role: Approved Base visual candidate / durable review source.
- This file is not yet the final 1440×3200 Production Runtime master and is not registered as Active Runtime binary.

## Background Canvas Standard v1
- Smartphone Production Master ratio: 20:9 Portrait
- Authoring canvas target: 1440×3200 px
- Smartphone QA ratios: 16:9 / 18:9 / 19.5:9 / 20:9 / 21:9
- No stretch.
- Runtime framing: cover + safe zone + bleed.
- Major coral / rocks / central Play Field must remain in the common safe area.
- Foldable unfolded / Tablet are separate ratio classes.

## Workflow Rule After Base Approval
- After the Base visual is approved, subsequent Background production is performed in **LABS Background**.
- Do not continue producing ad-hoc chat mockups or reporting-only images for each effect step.
- If LABS lacks a required comparison/QA function, update the LABS workbench first, then continue the production step there.
- LABS must use the approved Base as the immutable visual input for Layer Effect work.
- Production changes outside the active step remain locked.

## Current Lab State · Closeout 2026-10-05
- 01 배경 이미지: **A Open Water · Base Only v2 Approved**. Background 전체 Final/LOCK은 아님.
- 02 레이어 효과: **In Progress**.
- 03 합성 QA: Not Started.
- 04 Final: Not Started.
- Approved Base remains immutable while Effect work is active.
- LABS review layout: one fixed **Full Live Preview** at the top, Effect Queue below it.
- Legacy Surface Refraction A/B/C large candidate UI was removed from the active review flow. Surface Refraction remains **Deferred**.
- Effect card direction: expand one Effect, compare/select its A/B/C candidates, and apply the selection immediately to the top Full Live. Approved Effects should leave the active queue or collapse into an Approved Effects section.

## Effect Status
- **Volumetric Light:** Active / Rework. R14 A Broad Calm / B Living Rays / C Soft Drift are deployed and technically functional, but all three are visually too weak for art approval.
- **Ambient Particle:** Active / Pending.
- **Bubble:** Active / Pending.
- **Floor Caustic:** Rework Required. R11/R2 procedural line-network approach reads as thin grid/lines and does not meet the organic caustic target.
- **Surface Refraction:** Deferred.

## Latest LABS / CI
- Visible LABS version: **LABS-2026.10.04-R14 · Background Effects · Volumetric Light A-C**.
- Latest verified deployment commit: `317d3812fe0cc94a71356c76f11397207135e7a7`.
- GitHub Actions run: `37213054524` — **SUCCESS**.
- Previous R13 cleanup and first R14 attempts failed Analyze; latest success includes the required fixes. Do not interpret an earlier failed deploy as current public state.

## Volumetric Light Art Direction · Next Gate
Do not tune all three R14 variants in parallel. First establish the target visibility and spatial language with **A · Broad Sunbeam** only.

Target:
- 2–3 broad sunbeams starting at the upper water region.
- Soft edges, but clearly readable against the already-bright Base.
- Solo perceptual strength roughly 2–3× the current R14 impression; composite can later be reduced.
- Beams fade naturally around the middle of the scene rather than extending like lasers to the floor.
- Width, angle, position, and brightness evolve slowly so motion is perceptible within ~1–2 seconds.
- Avoid thin straight rays, hard cones, regular looping, or generic white overlays.
- After A establishes the art baseline, derive B/C as distinct motion characters rather than simple intensity changes.

## Next Session Start
Mandatory MY LOCK Preflight first. Then:
1. inspect the actual current branch/LABS version before editing,
2. keep Base Only v2 and every non-Volumetric effect locked,
3. redesign **Volumetric Light A · Broad Sunbeam only**,
4. deploy to LABS and verify CI/public state,
5. user decides Keep / Modify / Reject,
6. only after A is accepted, expand B/C or proceed to the next Effect.
