# MY LOCK · Drop 01 Background Handoff · 2026-10-04

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

## Current Lab State
- 01 배경 이미지: **Base Only v2 Approved**.
- 02 레이어 효과: **Next Active Step**.
- 03 합성 QA: Not Started.
- 04 Final: Not Started.
- First Layer Effect target: Surface Refraction; Floor Caustic / Volumetric Light / Ambient / Bubble remain independent layers.

## Next Discussion
Before implementation, decide the minimum LABS changes needed so that:
1. the approved Base is referenced as the immutable Background input,
2. Layer Effect candidates can be compared independently with ON/OFF and Freeze/Play,
3. ratio QA remains automated in LABS instead of being recreated as report images,
4. approved effect presets can progress directly to Composite QA and Registry/CI without parallel ad-hoc workflows.
