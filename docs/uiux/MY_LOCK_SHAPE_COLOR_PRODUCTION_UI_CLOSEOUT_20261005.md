# MY LOCK · 모양 & 색상 Production UI Implementation Closeout

Date: 2026-10-05
Status: Implemented / Technical QA Passed / Web Visual QA Pending
Approved visual: Google Drive `15_customize_shape_color_production_visual_approved_20261005.png`
MAIN release: `MAIN-2026.10.05-R01`

## Scope implemented

- Production title: `모양 & 색상`
- Two-tab structure: `모양 / 색상`
- Compact Preview (132 px)
  - Preview tap -> full-screen Runtime Preview
  - compact shuffle action
  - no persistent LIVE badge
- Browse model: `전체 + 필터`
- Overall ordering:
  1. `기본`
  2. Collection Group Sections
  3. Standalone Section when actual standalone items exist
- Filter composition: `전체 / 기본 / 컬렉션 / 개별`
- Collection Focus View inside the same screen state
- Shape and Color multi-select
- Minimum one selected item per category
- Brand-purple selection outline/check state
- Store ownership filters remain disabled until a real ownership source exists
- Future-ready unowned-item Bottom Sheet component

## Runtime correction — 2026-10-05

### Root cause corrected

The approved Candy Soft R2 basic geometry was previously selected only for Pink / Blue / Yellow.
When a premium or collection color was applied, `CandySoftRuntime` returned false and the renderer silently fell through to the legacy vector ShapeSpec path.

Color preview also hardcoded:
- ordinary colors -> Circle
- Aurora Sea -> Sea Turtle

Aurora Sea therefore had two visual paths: the approved Sea Turtle H02B Water Refraction runtime and an older generic vector Aurora gradient.

### Runtime rule now

- Candy Soft R2 circle / triangle / square remain the active Soft Basic geometry for **all ShapeTone values**.
- Static collection colors recolor the approved Candy Soft field instead of selecting legacy vector geometry.
- Aurora Sea uses one shared `AuroraSeaSignature` runtime.
- Active Signature source: **H02B · Living Water · Brighter / Final / Locked / Active**.
- H02B constants:
  - palette `#0754A3 -> #138BD3 -> #20CCD7 -> #9AF0F3`
  - speed `1.28`
  - refraction `0.92`
  - cellScale `3.7`
  - light `0.84`
  - seed `29`
  - mesh resolution `46`
  - field `24 Hz`
- Sea Turtle and Candy Soft basic shapes now reference the same shared H02B field.
- Locked Shape binaries / geometry / ownership / masks were not modified.

## Catalog correction

### Shape
- Basic: Circle / Triangle / Square
- Collection: registered Collection shapes
- Standalone: bottom section only when real standalone items exist

### Color
- Basic: Pink / Blue / Yellow
- Collection regular colors: Deep Ocean / Aqua Mint / Coral Pink / Sand Beige / Lavender / Peach Orange
- Signature: Aurora Sea
- Standalone: bottom section only when real standalone items exist
- Every Color catalog preview uses the current approved **Candy Soft Round** as the neutral preview shape.
- Aurora Sea is no longer previewed as a Sea Turtle.
- Aurora Sea is rendered as a **full-width 3-column-spanning Signature Color card** below the six regular Collection colors.

This is a catalog/runtime mapping for currently registered app data, not a claim that the full Drop 01 collection is complete.

## Data / Source-of-Truth constraints

The current app does not yet expose a production Store ownership/IAP state model.
This implementation does not infer ownership from `premium`, `directSale`, planned Drop assets, or mockup state.
Planned or non-runtime-registered Drop assets are not fabricated into selectable production items.

## Completion behavior

Approved UX remains:
- incomplete -> `n/N`
- complete -> no `6/6`, no `완료` text, no check badge
- completion is expressed by a theme-specific Collection surface effect

Actual completion state remains dependent on real ownership/completion data.

## Code changes

Core files:
- `lib/features/customize/shape_style/widgets/catalog_ui.dart`
- `lib/features/customize/shape_style/widgets/color_choice_card.dart`
- `lib/features/customize/shape_style/tabs/shape_tab.dart`
- `lib/features/customize/shape_style/tabs/color_tab.dart`
- `lib/lock_engine/aurora_sea_signature.dart`
- `lib/lock_engine/shape_spec/candy_soft_runtime.dart`
- `lib/lock_engine/shape_spec/shape_spec_renderer.dart`
- `test/candy_soft_r2_test.dart`

Initial Production UI commits:
- `46dcfc7e` Collection/filter shared components
- `9b5f5b2a` Compact Preview + fullscreen preview action
- `b398e0b3` Shape collection browsing
- `9cda7ca1` Color collection browsing
- `e2aeff35` Production `모양 & 색상` screen
- `6cf71f6d` Future-ready unowned-item Bottom Sheet

Runtime/catalog correction commits:
- `b7b83c6c` / `7e70f972` shared Aurora Sea H02B runtime
- `20cb31ba` / `3f94217b` shared Signature renderer integration
- `1054d736` / `e73277da` Candy Soft all-tone + Aurora alpha-safe rendering
- `ec1d35fc` / `16da84fb` / `6f94c5ab` Basic filter + current RadioGroup API
- `d2691487` Candy Soft Round Color preview + wide Signature card
- `eb9abc87` Basic Shape top section
- `f1a51990` Basic Color top section + full-width Aurora Sea
- `f48bdb3f` / `8c53921d` regression tests
- `8d68767d` MAIN-2026.10.05-R01 release metadata

## Verification

Read-back verified on `main`:
- Basic-first Shape and Color sections
- Collection below Basic
- Standalone bottom behavior
- Color preview always uses ShapeKind.circle -> approved Candy Soft Round
- Aurora Sea no longer hardcodes Sea Turtle in ColorChoiceCard
- Aurora Sea wide Signature card
- shared H02B runtime
- Candy Soft runtime no longer gates on default three tones
- premium/static tone and moving-Aurora regression tests present

Technical QA for release head `8d68767d715b07666f02ff37577f698fa3ac7357`:

### MyLock CI — run 37259534473
- ShapeSpec mask validation: PASS
- Asset lifecycle validation: PASS
- Flutter Analyze: PASS
- Flutter Test: PASS
- ARM64 APK build: PASS
- APK upload: PASS
- APK download/byte verification: PASS
- Email APK: intentionally skipped

### MY LOCK Web Build — run 37259534410
- Two-site governance validation: PASS
- Public preview route validation: PASS
- Flutter Web build: PASS
- Web artifact upload: PASS
- Cloudflare Worker deploy: PASS
- Canonical QA link publication: PASS

## Current Gate

Technical QA is passed.
Remaining approval gates:
1. Canonical MAIN visual review of the corrected catalog/runtime
2. Small / Standard / Large viewport visual QA
3. Aurora Sea motion/identity visual confirmation on the actual page
4. Android physical-device visual/performance QA

Do not promote physical Android QA to PASS from CI alone.

## Deferred

- Store ownership source + IAP
- owned / unowned filter activation
- real unowned-item routing to product detail
- full Drop 01 runtime registration for planned assets
- collection-completion runtime data
- Customize Main collection summary / Collection Hub
