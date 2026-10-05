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


## Aurora Sea Web live-motion correction — 2026-10-05

Release: `MAIN-2026.10.05-R02`
Status: Fixed / Technical QA Passed / User Visual QA Pending

### Symptom

- Aurora Sea Signature Color preview used the correct small Candy Soft Round, but the H02B field appeared static on the public Web preview.
- Applying Aurora Sea to basic shapes could also look fixed even though the palette clock and time-dependent renderer were connected.

### Root cause

- The canonical H02B clock and sampler were active.
- On Web, the `drawVertices` optical field could repaint while still failing to present perceptible motion at the actual 58–72 px card size.
- Therefore technical frame inequality was insufficient as a visual-motion gate.

### Correction

- H02B Master values and Shape Masters were not changed.
- `AuroraSeaSignature` now uses a Web-safe Canvas field path based on the same `WaterRefractionField.sample()` source.
- Web renders a 20×20 time-varying cell field through Canvas drawRect.
- Native keeps the existing higher-resolution vertices path.
- The Signature Color card remains the approved small live Round preview.
- Password-selection policy remains unchanged.

### Regression QA

- Added a 72 px Aurora preview test at 0 / 0.5 / 1.0 / 1.5 / 2.0 seconds.
- The test requires a perceptible changed-pixel count rather than only asserting that two full frames differ.

### Verification

- Web Build / deploy run: `37261998567` — PASS
- MyLock CI run: `37261998603` — PASS
- Release: `MAIN-2026.10.05-R02`

User-visible motion on the user's actual browser remains the final visual gate.

## Aurora Sea R03 · Approved LABS Renderer Parity — 2026-10-05

Release: `MAIN-2026.10.05-R03`
Status: Implemented / Web Deploy Passed / User Visual QA Pending

### Decision
- R02 Web-only 20×20 Canvas-cell fallback is rejected and removed.
- Production now uses the same H02B field math and optical renderer that the user approved in Palette LABS.
- Password-selection policy remains unchanged.
- Shape Master / H02B parameters remain locked.

### Renderer parity
Approved LABS source commit: `ade16b84e91a9c1d344c34805cc707322622261f`.

Parity points:
- H02B WaterRefractionField parameters unchanged.
- Production `lib/lock_engine/water_refraction_field.dart` is implementation-identical to the approved LABS field; only the top documentation comment differs.
- Optical pass: `drawVertices(field.mesh(timeSeconds), BlendMode.src, Paint()..blendMode = BlendMode.srcIn)`.
- Alpha-first compositing retained.
- Small Aurora Signature swatch uses a dedicated LABS-style Ticker and passes explicit palette time into `LockTokenPainter`.
- Runtime remains on the shared monotonic palette clock.

### Commits
- `bbd206b8` restore exact approved H02B LABS renderer
- `bdb710ea` allow explicit palette time in token painter
- `6bd1dbc5` drive Aurora swatch with approved LABS ticker pattern
- `6e52c686` 72px approved H02B motion regression test
- `6ee993b0` remove obsolete R02 fallback test import
- `728b0b8b` / `4579d3e8` / `fc0d1d59` publish R03 metadata

### Verification
- R03 Web Build / Cloudflare deploy run `37268510568`: **PASS**.
- R03 CI Analyze: **PASS**.
- R03 CI Test: **PASS**.
- ARM64 APK build in run `37268510698`: still running at closeout update time; do not claim full CI completion until finished.

Final visual gate: compare the small Aurora Round and applied Aurora runtime directly against the previously approved LABS H02B behavior in the user's browser.
