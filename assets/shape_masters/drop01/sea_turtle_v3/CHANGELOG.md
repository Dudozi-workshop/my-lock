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
