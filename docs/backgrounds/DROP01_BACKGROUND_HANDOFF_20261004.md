# MY LOCK · Drop 01 Background Handoff · 2026-10-04

## Current handoff · A R26 Canvas image motion / QA Candidate
- R25 full CI/deploy passed but live showed clock running while texture was absent, including static frame. Browser reported CPU-only fallback (webGLVersion -1); no shader load exception. Treat visual failure as open, not deployment success.
- R26 actual renderer uses image-only Canvas overlapping strip warp, width/brightness modulation with same registered R22 PNG. Removes FragmentShader dependency from the layer. Top anchor/mid-water image alpha preserved. Actual runtime painter tested at 0/2s/loop, not a separate shader.
- Auto-play, explicit pause/reference and R21 comparison retained. Header/metadata/workflow synchronized R26. No new binary, other effects unchanged. Live verification pending.

## Previous handoff · A R25 visible motion / QA Candidate
- User reports R22 playback seems absent and requests visible motion. R22 frame delta was technical PASS, insufficient perceptual change. No claim that user device playback was reproduced.
- R25 keeps exact registered R22 texture and static phase zero. Local horizontal warp 0.020/0.007, vertical 0.007, brightness 0.18, primary period 4.8 seconds on preserved 24-second A clock. Upper anchor/mid-water cutoff preserved. R21 and B/C clocks/other effects unchanged.
- Selecting painted A now auto-plays instead of silently pausing; explicit reference frame still pauses. Visible play state and clock progress added. Pause/play retained.
- Preflight Notion 06/Master/05/04 and GitHub handoff/current branch read. Concurrent R23/R24 Starfish integration preserved from c46da86. Shared release identity synchronized to R25.
- CI/deployment/live verification pending; art approval pending. No new binary or ImageGen. Not Final/LOCK.

## Previous handoff · A texture study R22 / QA Candidate
- User authorizes an A-only painted-layer + subtle warp trial after R21 quality concerns. R21 renderer is preserved behind a comparison chip. No B/C expansion.
- Preflight reads Notion 06 / Asset Master / 05 / 04 and current branch. Latest remote `32820b4210959188ba0b1c3392fd4f1747d333b0`, CI `37235876928` success; unrelated palette changes retained.
- User reference `76252.png` has baked checker pixels. R22 texture is an approximate reference-density study (293×436 RGBA), not an original-alpha extraction or Production Master. No ImageGen.
- Runtime: registered asset ID, cached per-widget texture/shader, local anchored deformation and mild brightness, mid-water fade. Reference frame / pause / play and R21 comparison.
- Drive upload rejected by automatic approval review: explicit upload authorization required. Folder metadata confirms same approved-Base folder and non-shared state, but review still rejects. Do not retry or use another external destination to bypass.
- User explicitly approved Drive upload on 2026-10-05. Uploaded and read-back verified: file `1hVs9mcDvkYdltEQoinaOiEAGSg8xQxeR`, PNG 20,248 bytes. Registry linked. CI/deploy/public verification next; art approval pending.
- Base checksum unchanged. Non-A effect renderer file unchanged. Background remains not Final/LOCK.

### R22 prior validation / deployment blocker (resolved below)
- A-only tests in CI `37237651130`, commit `b13f7c3dfeb485b68b26ff5045fed4655ef3188a`: texture decode / gap contrast / floor alpha, shader 2-second change / loop continuity, preserved R21 tests PASS. Background integrity PASS.
- Full CI fails Analyze with the same 18 inherited Shape runtime errors as `a31ced6`: missing runtime dependency files, removed LABS renderer arguments and ShapeTone switch compatibility. Build/Deploy/Public skipped.
- R22 introduces no additional Analyze error. No scope-out runtime rollback or approved asset change performed.
- Actual Public metadata still R21 / source `32820b4210959188ba0b1c3392fd4f1747d333b0`. R22 is registered but not deployed, not art-approved or locked.
- Notion TS-007 records the integration blocker and recurrence prevention. Next: reconcile shared runtime dependencies/caller APIs, then whole CI/deploy/public and user Live review.

### R22 deployed validation · 2026-10-05 · art review pending
- User authorized shared-runtime repair. Source `72345db0f3a0328a9b3895ffba750ea7d25e0236`; CI [37243341257](https://github.com/Dudozi-workshop/my-lock/actions/runs/37243341257) success: A texture/R21 tests, Analyze, full tests, web build/deploy, Public release identity and both PNG SHA256 checks.
- TS-007 repaired through missing MAIN runtime modules, restored LABS caller options/enum compatibility, exact approved raster dependency assets and root bootstrap. Free vector catalog/spec tests use their original free defaults; new actual raster loading/rendering test checks premium dependency closure.
- Starfish static runtime uses approved MAIN binaries and manifest anchors. Micro-idle configuration was absent; idle remains disabled, not invented or art-approved. No background Base, B/C, or other effect source changes in this repair.
- Public LABS-2026.10.05-R22 at https://my-lock-shape-lab-pages.pages.dev/?lab=background. Cloud browser actual texture/shader renders, reference pause captures are identical, play captures differ, and R21 comparison is visible. No application error observed; extension metadata noise excluded. Physical Android/device performance smoke remains pending.
- Use 02 레이어 효과 → A 그림 레이어 · R22 → A 기준 프레임 / A 재생. Selecting A reference/comparison solos Volumetric Light and switches other effects OFF. User Keep/Modify/Reject still required. Approximate low-resolution density study remains QA Candidate, not Production Master or Background Final/LOCK.

## Previous deployed handoff · R21 candidate
- R20 deployed `5be8a8d3029afc77f8494c6119dee3a3f2fccd04`, CI `37218684946` success; user rejects direction: independent overhead lamps, too thick, missing coherent fan.
- User `76038.png` is primary art reference. R21 uses broad upper source region with a coherent outward fan, thin/medium shafts, faint broad support, irregular blue gaps, asymmetric soft boundaries.
- A reference-frame/pause/play in Full Live: inspect frozen composition first, then motion. B/C clocks and every other effect unchanged.
- LABS-2026.10.05-R21; CI/deploy/public before user art review. Base immutable; no ImageGen; not Final/LOCK.

## Previous handoff · R20 candidate
- R19 deployed at `5fd0f95603c508e7e72856a360751bf27e06245c`, CI `37218031852` success. User verdict Modify: central entry cluster and excessive similar widths.
- A R20 distributes unequal large/medium/small light planes across the surface with irregular blue gaps and varied angles. Warm tint only near the source; sky-blue depth blend, asymmetric density, individual taper/fade.
- LABS-2026.10.05-R20; CI/deploy/public verification then user Live Keep/Modify/Reject. Base/B/C/other effects immutable; no ImageGen. Not Final/LOCK.

## Previous handoff · R19 candidate
- R18 deployed at `c3087cd458c64e7a732b00601e4c1aef6ab9bb10`, run `37217486802` success. User verdict Modify: wants illustrated anime-style light per `76038.png`.
- A R19: broad translucent cream/mint light planes, near-flat fill with narrow soft edges; width and opacity motion prioritised over positional sway. Mid-water fade retained.
- LABS-2026.10.05-R19; CI/deploy/public verification then user Live Keep/Modify/Reject. Base v2/B/C/other effects immutable; no ImageGen. Background not Final/LOCK.

## Previous handoff · R18 candidate
- User clarification supersedes three-shaft constraint: follow the initial concept with many unequal soft rays spreading from one upper source. R17 `25dbb42ed1065ba5f068d009fb13c946a8a4817e` superseded before art review.
- R18 A uses seven unequal overlapping soft shafts as the current implementation of the concept fan; count is not an approval requirement. Existing mid-water fade retained; Base/B/C/other effects locked.
- LABS-2026.10.05-R18; CI/deploy/public verification then user Live Keep/Modify/Reject.

## Previous handoff · R17 superseded
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
