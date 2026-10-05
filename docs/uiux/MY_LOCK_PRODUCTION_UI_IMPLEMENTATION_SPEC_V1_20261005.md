# MY LOCK Production UI Implementation Spec v1

Date: 2026-10-05
Status: Implemented / QA Pending
Scope: Foundation + Customize Main + Lock Settings Main
Platform: Android-first Flutter
Theme: Light only for launch

## 1. Source of Truth

Priority order:
1. Notion 07. UX/UI 화면 구조도 — 2026-10-05 Production UI Foundation 1차 Visual Approved
2. Approved mockup: Google Drive `14_production_ui_foundation_v1_visual_approved_20261005.png`
3. This implementation spec
4. GitHub main for existing functional behavior

The approved mockup is a visual reference, not a raster asset to hard-code into the app.

## 2. Implementation principle

- Keep the confirmed IA and functional behavior.
- Reuse existing settings/runtime/business logic wherever possible.
- Replace legacy presentation with reusable Production UI components.
- Do not bake screenshot text, cards, or mockup artwork into the app.
- Existing Shape/Background assets are referenced from their approved runtime sources; do not regenerate them for UI implementation.
- Production UI and runtime lock rendering remain separate layers.

## 3. Foundation tokens

These are v1 implementation targets. Device QA may adjust small values by about 2 px without changing hierarchy.

### Color
- Brand Purple: `#7659F6`
- Brand Lavender: `#F1EDFF`
- App Background: `#F8F8FC`
- Surface: `#FFFFFF`
- Ink: `#1C1A25`
- Secondary Ink: `#777480`
- Border: `#EDEBF2`
- Success: use a soft teal/green status accent with sufficient contrast
- Warning/Beta: warm cream/yellow surface, not an error tone
- Error: semantic error color only for actual errors

### Typography
Use the app's Korean production font stack. If Pretendard is bundled/approved, use Pretendard; otherwise preserve current platform-compatible Korean font until font packaging is finalized.

- Screen title: 24–28 / 800
- Section title: 16–18 / 800
- Card title: 15–16 / 700–800
- Body: 14 / 500
- Supporting text: 12 / 400–500
- Navigation label: 12 / selected 700, unselected 600

### Spacing
Base scale:
- 4 / 8 / 12 / 16 / 20 / 24 / 32
- Screen horizontal padding: 20
- Compact row internal gap: 12
- Section gap: 20–24

### Radius
- Small icon tile: 15–16
- List row/group child: 18–20
- Standard card: 24
- Hero/large preview: 28–32
- Pills/chips: 99

### Elevation
- Use very soft shadows only.
- Standard card shadow target: low-opacity purple/indigo shadow, blur 16–20, vertical offset 6–8.
- Avoid heavy Material elevation.

## 4. Shared component language

### Screen title
Use a small soft icon immediately before:
- 꾸미기: sparkle family
- 상점: storefront family
- 잠금 설정: lock family

The title icon and Bottom Navigation icon must belong to the same visual family.

### Bottom Navigation
Fixed destinations:
1. 꾸미기
2. 상점
3. 잠금 설정

Rules:
- soft rounded selected background
- selected icon + label = Brand Purple
- unselected = muted gray
- no new top-level destinations
- Safe Area aware
- target height about 70–72 plus system inset

### Primary button
- full-width when used as a main page CTA
- purple fill
- rounded 20–24
- clear pressed and disabled states
- minimum touch target 48

### List row
- soft icon tile
- title + compact supporting value
- chevron for navigation
- switch only for direct boolean settings
- no oversized card per row when rows belong to one semantic group

### Group card
Used for Settings sections.
- one rounded outer card
- rows remain directly tappable
- very subtle dividers or spacing between rows
- grouping is visual only; do not add intermediate hub screens

### Required states
Reusable states must exist for:
- Loading
- Empty
- Error
- Disabled
- Pressed
- Selected

## 5. Customize Main

Current legacy large LIVE preview is superseded.

### Structure
1. Safe Area
2. Title row: sparkle icon + `꾸미기`
3. Short supporting line
4. Current-lock representative preview image/card
5. Three shortcut tiles:
   - 모양 & 색상
   - 움직임 & 반응
   - 배경
6. Large full-width CTA:
   - expand/fullscreen arrow icon
   - label exactly: `전체화면 보기`
7. Bottom Navigation

### Preview
- Main page preview is representative, not a permanently running large LIVE canvas.
- Full runtime behavior is checked in the fullscreen Runtime Preview.
- Do not show the old `LIVE` badge or `도형을 눌러보세요` chip on Customize Main.

### Shortcut icons
Preserve the approved Round-1 cute icon language:
- 모양 & 색상: palette-like soft icon
- 움직임 & 반응: cute motion/reaction icon language
- 배경: image/background icon
Use soft pink / blue / mint tiles as in the approved visual direction.

### Navigation
- `전체화면 보기` opens the existing/planned full Runtime Preview.
- Shortcut tiles navigate directly to their corresponding screens.

## 6. Lock Settings Main

### Normal protection state
Keep the existing compact behavior when healthy:
- shield icon
- `보호 ON`
- `정상 작동 중`
- chevron
- compact one-row card

When permission/service health is abnormal, expand the protection status card and expose resolution CTA(s).

### Main layout
Do not add a `잠금 방식` intermediate hub only for grouping.
Group related functions visually while keeping direct access.

Order:

1. Compact protection status
2. 잠금화면 테스트
3. 보호 대상
   - 보호할 앱
4. 인증 & 다시 잠그기
   - 비밀번호 변경
   - 보조 PIN 변경
   - 다시 잠그기
5. 화면 & 피드백
   - 화면 동작
   - 효과음 & 진동
6. 기타
   - 실험실
   - 도움 주신 분들
   - 앱 정보
7. Bottom Navigation

### Row supporting values
Examples:
- 비밀번호 변경: `2자리 그래픽 패턴`
- 보조 PIN 변경: `4자리 PIN 설정됨`
- 다시 잠그기: current relock policy
- 보호할 앱: current protected app count
- 화면 동작: `도형 9개 · 하단 영역 · 속도 보통`
- 효과음 & 진동: current ON/OFF summary

### Experimental feature
`화면 켤 때 MY LOCK · BETA` moves under 실험실 rather than being directly exposed on the main Settings page.

### App info
App version, privacy policy, open-source licenses, and inquiry/feedback belong under 앱 정보. Do not duplicate version text at the bottom of Settings Main.

## 7. Responsive rules

- Portrait-first.
- Always respect Safe Area / system insets.
- Use width-based constraints rather than fixed screen-size assumptions.
- Narrow phones: preserve single-column layout and reduce decorative spacing before reducing touch targets.
- Large phones/foldables: keep the same IA; expand max content width and whitespace rather than introducing a different navigation model.
- No clipped CTA, preview, navigation label, or settings row under font scaling and system gesture areas.

## 8. Existing code mapping

Primary files:
- `lib/app/theme.dart`
  - promote approved tokens to reusable theme/components
- `lib/features/shell/root_shell.dart`
  - Bottom Navigation visual update
- `lib/features/customize/customize_screen.dart`
  - replace legacy 48% LIVE preview layout with approved Customize Main
- `lib/widgets/customization_card.dart`
  - either refactor into generic soft card/shortcut component or supersede with new Production components
- `lib/features/lock_settings/lock_settings_screen.dart`
  - preserve permission/status/business logic
  - replace individual-card list with approved visual groups
  - keep compact protection status logic
  - move experimental screen-lock entry under Lab navigation

Do not rewrite:
- lock runtime engine
- permission monitoring
- relock semantics
- secure password/PIN storage
unless implementation uncovers an actual integration defect.

## 9. QA checklist for this gate

Before marking Implemented / QA Passed:
- Bottom Navigation matches approved icon family and selected-state treatment.
- Customize Main has no old large persistent LIVE preview.
- CTA reads exactly `전체화면 보기` and uses expand/fullscreen icon.
- All three Customize shortcuts remain directly reachable.
- Protection healthy state is compact.
- Protection abnormal state expands correctly.
- Settings rows are visually grouped but still directly accessible.
- Existing password/PIN/protected-app/relock/screen-behavior functions still work.
- Safe Area checked on small/normal/large portrait Android layouts.
- Loading/Error states remain functional.
- Flutter analyze/test/build pass.

## 10. Lifecycle state

Current:
- Planning Locked
- Visual Approved
- Component / State Defined
- Android Implementation complete for Foundation + Customize Main + Lock Settings Main

Implementation commits:
- `88febd28` — Production UI foundation components
- `06e67f87` — Production theme refinement
- `d047678b` — Customize fullscreen Runtime Preview
- `200bb9ff` — Production Customize Main
- `8d3c14c5` / `1c9954b2` — Lock Settings detail screens and app-info actions
- `5640356b` — Grouped Production Lock Settings Main

Next:
- Flutter analyze / test / build
- responsive/device QA
- visual comparison against approved mockup
- QA Passed promotion

Note: current connector exposed no workflow/check result for the latest commit, so build/test completion is not claimed yet.
