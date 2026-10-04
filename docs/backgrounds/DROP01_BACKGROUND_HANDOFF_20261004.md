# MY LOCK · Drop 01 Background Handoff · 2026-10-04

## Scope
Drop 01 Background production handoff after Background Lab structure, Reference Asset Rule v1, and Background Canvas Standard v1 confirmation.

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

## Reference Asset Rule v1
- No production PNG/WebP payload hardcoding.
- Resolve by stable Asset ID → Registry → Runtime binary path.
- Notion = decision/specification.
- Google Drive = canonical binary.
- GitHub = runtime binary + registry.
- Integrity gate: byte size / SHA-256 / format signature / dimensions / public asset verify.

## Current Approved Core Composition
- Asset ID: background.drop01.shallow_clear.v1
- File: shallow_clear_base_v1.webp
- Current role: Approved Core Composition / Tone Reference
- Size: 1024×1536
- Status: selected_base_candidate / not Final / not Locked
- Canonical Drive:
  MY LOCK Assets / Drop 01 - 작은 바닷속 / Background Masters / shallow_clear_base_v1.webp
- Runtime:
  assets/backgrounds/drop01/shallow_clear_base_v1.webp
- SHA-256:
  e04aa1a84cbac0d6635fed2d67b703c81ebb9353d3894e7a6e9af18e7a05c599

## Background Canvas Standard v1
- Smartphone Production Master ratio: 20:9 Portrait
- Authoring canvas: 1440×3200 px
- Smartphone QA ratios: 16:9 / 18:9 / 19.5:9 / 20:9 / 21:9
- No stretch.
- Runtime framing: cover + safe zone + bleed.
- Major coral / rocks / central Play Field must remain in the common safe area.
- Foldable unfolded / Tablet are separate ratio classes.

## Locked Visual Direction for Next Production Master
- Preserve current pastel 2D underwater visual language.
- Preserve Blue/Aqua depth, sand perspective, left-bottom coral/rock/seaweed cluster, central negative space, texture density, color and value tone.
- Do not upscale/distort the 1024×1536 Base into the new master.
- Extend the same scene/world into the 20:9 canvas.
- Do not add new glossy/3D/material language.

## Upload / Registration Status
- Required current image is already durably uploaded to Google Drive and GitHub runtime storage.
- Registry reference is active and integrity verified.
- No new 1440×3200 Production Master exists yet, so no additional production image should be uploaded or promoted.
- Do not create reporting-only images.

## Next Gate
Discussion first:
1. 1440×3200 composition layout.
2. Preserve region vs extension region.
3. Safe Zone / Bleed / Anchor / Play Field.
4. 16:9~21:9 crop behavior.
5. User approval.
Only after that: create Production Master Candidate.
