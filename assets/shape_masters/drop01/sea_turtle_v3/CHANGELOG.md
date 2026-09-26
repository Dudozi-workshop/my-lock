# Sea Turtle Decision Change Log

Every decision change is recorded as **Before → After → Why → Impact**. Prior rationale is not silently overwritten.

## 2026-09-26 · Master Shape Reference adopted
- **Before:** v3 production planning still inherited the 512 px v2 geometry reference and used generated/upscaled draft assets for split QA.
- **After:** the newly approved eye-free Sea Turtle artwork is adopted as **Sea Turtle v3 Master Shape Reference v1**.
- **Why:** the new artwork provides the intended adult Sea Turtle silhouette, Long Flipper proportions, shell/body relationship, and premium illustration quality at a much stronger visual baseline.
- **Impact:** v2 runtime PNGs must no longer be used as v3 production source. A new 2048 × 2048 transparent Canonical Master must be rebuilt from the approved reference before semantic/moving-part assets are promoted.

## 2026-09-26 · Canonical rebuild boundary
- **Before:** the 2048 draft was generated from the older v2 planning source.
- **After:** the approved Master Shape Reference governs the next Canonical rebuild. Background and external glow are removed while silhouette/proportions/no-eye face are preserved.
- **Why:** Geometry/Art direction must be locked before technical splitting.
- **Impact:** existing v3 split work is retained as pipeline/QA knowledge, but the actual production parts/masks must be regenerated from the new Canonical source.

## 2026-09-26 · Shape Animation ownership
- **Before:** Sea Turtle shape-specific animation was temporarily removed and Motion Set handled all movement.
- **After:** Shape Animation is allowed for Front Flipper Near/Far only. Motion Set still owns whole-object movement.
- **Why:** whole-object movement and internal articulation are different product roles.
- **Impact:** future animation assets are limited to moving flipper parts; body and shell geometry stay static.

## 2026-09-26 · Moving-part rendering
- **Before:** outline/highlight/shadow were primarily global masks or overlays.
- **After:** each moving front flipper owns its alpha, outline, shadow and highlight maps.
- **Why:** replacing F0 with F1–F3 would otherwise leave old-position outline/highlight residue.
- **Impact:** static overlays explicitly exclude moving-part pixels.

## 2026-09-26 · Animation production order
- **Before:** transform/pivot experiments could begin soon after the static asset.
- **After:** Static Master → part/region split → Static Lock → whole-turtle animation image mockup → 3–4 key-pose approval → Near Flipper implementation → Far Flipper implementation → loop QA.
- **Why:** approve visual motion before spending production cost on assets and code.
- **Impact:** no animation code is added during Canonical v3 preparation.


## 2026-09-26 · Bake-only → Hybrid Material Compositor
- **Before:** production planning could be interpreted as baking the finished turtle appearance into static sprites and only applying limited palette changes.
- **After:** Geometry/structural lighting stays baked or pre-derived, while palette/material color and time-varying effects can remain runtime inputs inside region masks. Aurora Sea is the reference stress-test.
- **Why:** a moving Aurora shell cannot be represented correctly by a fully baked static color layer, while a raw overlay would look detached from the shell.
- **Impact:** Shell/Belly regions are prepared for Albedo + Shadow + Highlight + Detail + Outline composition. Dynamic material uses shape-local coordinates and is composited before whole-object Motion Set transforms.

## 2026-09-26 · Layer QA/QC Gate
- **Before:** masks were visually checked individually and then registered.
- **After:** every layer follows Generate → QC → QA → Register, including containment, overlap/gap, ownership, hidden-underlap reveal and rebuild checks.
- **Why:** visually plausible masks can still fail when a moving part reveals hidden areas or when multiple layers are composited.
- **Impact:** Static Master Lock is blocked while any geometry/material QA or QC gate fails.

## 2026-09-26 · Belly Hidden Underlap correction
- **Before:** the first Belly mask represented primarily the currently visible belly surface and was interrupted by the Near front flipper.
- **After:** Belly is defined as a continuous static-body surface that extends behind the moving front flippers.
- **Why:** moving/removing a flipper must reveal a complete belly instead of an empty gap.
- **Impact:** the previously registered Belly mask is marked for replacement; Shell Detail work pauses until the corrected Belly passes reveal QA.
