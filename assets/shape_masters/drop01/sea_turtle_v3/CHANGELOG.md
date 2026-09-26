# Sea Turtle Decision Change Log

Every decision change is recorded as **Before → After → Why → Impact**. Prior rationale is not silently overwritten.

## 2026-09-26 · Shape Animation ownership
- **Before:** Sea Turtle shape-specific animation was temporarily removed and Motion Set handled all movement.
- **After:** Shape Animation is allowed for Front Flipper Near/Far only. Motion Set still owns whole-object movement.
- **Why:** whole-object movement and internal articulation are different product roles; front-flipper swimming adds shape-specific character without duplicating Motion Set.
- **Impact:** future animation assets are limited to moving flipper parts; body and shell geometry stay static.

## 2026-09-26 · Moving-part rendering
- **Before:** outline/highlight/shadow were primarily global masks or overlays.
- **After:** each moving front flipper owns its alpha, outline, shadow and highlight maps.
- **Why:** replacing F0 with F1–F3 would otherwise leave the old-position outline or highlight behind.
- **Impact:** static overlays explicitly exclude moving-part pixels.

## 2026-09-26 · Canonical source resolution
- **Before:** the 512 px master was used for region refinement and runtime PoC.
- **After:** a 2048 px transparent Canonical Master draft becomes the editing candidate; v2 stays the geometry reference until approval.
- **Why:** 512 px made shell/belly boundaries, outline cleanup and flipper separation unnecessarily fragile.
- **Impact:** semantic masks and moving parts are rebuilt at 2048 while the Long Flipper silhouette remains unchanged.

## 2026-09-26 · Animation production order
- **Before:** transform/pivot experiments could begin soon after the static asset.
- **After:** Static Master → part/region split → Static Lock → whole-turtle animation image mockup → 3–4 key-pose approval → Near Flipper implementation → Far Flipper implementation → loop QA.
- **Why:** approve the visual motion before spending production cost on assets and code.
- **Impact:** no animation code is added during Canonical v3 preparation.
