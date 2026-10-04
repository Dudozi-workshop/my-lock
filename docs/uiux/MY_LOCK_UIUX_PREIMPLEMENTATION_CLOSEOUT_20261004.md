# MY LOCK UI/UX Pre-Implementation Closeout — 2026-10-04

Status: Active Planning Baseline / Production Implementation Pending

## Scope
This document records the pre-implementation UI/UX baseline confirmed on 2026-10-04. It does not claim Android production implementation is complete.

## Source of Truth
- Notion: 07. UX/UI 화면 구조도
- Notion: 01. 확정 기획 및 제품 사양
- Notion: 04. 다음 작업 및 검증 항목
- Google Drive: approved/reference UI mockup folder

When planning text and implementation differ, planning intent is resolved in Notion and actual implemented state is verified from GitHub main.

## Top-level IA
Bottom navigation is fixed to:
1. 꾸미기
2. 상점
3. 잠금 설정

No standalone 보관함 or 시스템 설정 top-level destination is used.

## Customize
Main entries:
- 모양 & 색상
- 움직임 & 반응
- 배경

The main screen uses a representative current-lock image plus a separate Preview entry. It does not run a large persistent live preview.

Shape and Color are multi-select with at least one item required in each set. Motion and Reaction are single-select. Background is single-select.

Full-screen Customize Preview uses actual runtime layout rules without running authentication. Reshuffle only changes sampled Shape/Color combinations and positions.

## Store
Top tabs:
- 추천
- 신규
- 컬렉션
- 한정

Wishlist is a Store function. Archive is entered from 한정 > 지난 컬렉션/지난 시즌 보기.

Product detail uses a category-specific Showcase area occupying roughly 50–55% of the screen with a full-screen experience mode. Full-screen Showcase is experience-only and does not show purchase controls.

Purchase completion does not auto-equip. CTA:
- 꾸미기에서 사용하기
- 계속 둘러보기

First collection completion shows one Compact Celebration Modal and announces Signature Color unlock.

## Lock Settings
Order:
1. 보호 상태
2. 잠금화면 테스트
3. 보호할 앱
4. 잠금 방식
5. 화면 동작
6. 효과음 / 진동
7. 실험실
8. 도움 주신 분들
9. 앱 정보

Missing required permissions expand the protection-status card with a resolution CTA. Returning after permission repair triggers automatic status re-check.

## Responsive baseline
- Launch UI: Light only
- Portrait-first responsive layout
- Safe Area / system insets are mandatory
- Foldables reuse the same IA and expand responsively rather than introducing a separate structure
- Loading / Empty / Error / Disabled states are required implementation states

## Deferred to implementation / device QA
- exact spacing, radius, icon sizes, animation timing/easing
- concurrent animated Store-card playback limit
- final free Light/Dark background visuals

## Google Drive mockups
Folder:
https://drive.google.com/drive/folders/17cI1oF78F8piPbb2-VPdrZmKoGhnNpYS

Recent Store Showcase references:
- 12_shop_showcase_background_motion_reaction_mockup_20261004.png
  https://drive.google.com/file/d/1mBnArwDxviGu0mog0eS8LFeP2Ax87VmG/view
- 13_shop_showcase_preview_size_fullscreen_flow_mockup_20261004.png
  https://drive.google.com/file/d/1rnHgp61t3uB9KxmMzfDyyIrUc2yRgaEa/view

## Production UI execution protocol — 2026-10-05

Status: In Progress / Planning Locked -> Visual Candidate

The confirmed IA and UX remain locked. Production visual polish must not redesign screen structure or functional responsibility.

Per-screen workflow is fixed to:
1. Production UI mockup
2. User approval
3. Component and state definition
4. Android implementation
5. Responsive / runtime / permission / state QA
6. Post-approval synchronization to Notion / GitHub / Drive

Screen-state progression:
- Planning Locked
- Visual Candidate
- Visual Approved
- Implemented / QA Passed

Mockup strategy:
- Primary: ImageGen for broad visual direction -> approved direction reproduced precisely in Flutter Mock Screen -> Production promotion
- Fallback: Flutter Mock Screen -> rendered screenshot -> user approval, so UI work does not stop when image generation is unavailable

Phase order:
- Phase A: Foundation
- Phase B: Customize
- Phase C: Store
- Phase D: Lock Settings
- Phase E: Integrated Production QA

Phase A scope:
- Root Shell
- Bottom Navigation
- Minimum Production Design System
- App Bar / base surface / Card / Section Header / CTA / Chip / Tab / Toggle-Switch / List Row / Badge / Bottom Sheet / Snackbar / Modal
- Loading / Empty / Error / Disabled states
- Minimum design tokens: typography hierarchy / spacing / radius / icon size / divider / shadow / selected / pressed / disabled / Safe Area

Current gate:
**Create and approve the Phase A Foundation Production UI mockup before moving to Customize production screens.**

TS-004 remains mandatory for all external repository writes: execute repositories independently, read back immediately after each write, and resume idempotently from the first unverified step.

## Next Gate
Production UI mockup/component-state definition -> Android implementation -> real-device responsive/performance/permission QA -> UX/UI map implementation-state update.

## Closeout rule
Planning approval and production implementation remain separate states. This file is a handoff baseline, not proof of implementation.
