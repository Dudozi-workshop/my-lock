# Sea Turtle v3 · Swim Shape Animation v1 Decision — 2026-10-02

## Status
- Motion concept: **Selected / Approved direction**
- Production pose assets: **Not yet locked**
- Scope: front flipper Shape Animation only.
- Static Body / Shell / Underbelly / Rear geometry remain locked and must not be modified.

## Source / scope rules
- S0 uses the current approved Sea Turtle v3 pose as-is.
- New pose work is limited to Front Flipper Near / Far variants.
- New pose variants do not replace or reinterpret the locked S0 geometry.
- No whole-turtle redraw for production.
- ImageGen mockups remain concept-only and are not Production Sources.
- Production extraction / variant asset work must follow the Illustrated Raster Part Production System.

## Approved loop structure
Runtime order:

`S0 → S1 → S2 → S1 → S0`

Unique authored poses:
1. **S0 — Glide / current approved pose**
2. **S1 — Natural transition**
3. **S2 — Upper glide / peak**

The current decision intentionally uses 3 unique poses before considering a separate rising/falling transition.

## Pose intent
### S0
- Current approved pose reused unchanged.
- Comfortable glide / neutral return pose.

### S1
- Natural intermediate pose between S0 and S2.
- Must read as a flipper changing shape, not as a rigid rotated sprite.
- Small amplitude; relaxed movement.

### S2
- Peak pose does **not** need to reach horizontal.
- A slightly lower-than-horizontal flipper is preferred when it produces the more natural silhouette.
- Avoid the flipper appearing folded backward.
- Preserve the long, smooth Sea Turtle v3 silhouette.

## Motion character
- Calm, soft swimming.
- Small motion amplitude.
- No dynamic or exaggerated flap.
- Near and Far flippers share the same rhythm; Far should remain visually subordinate.
- Body / Shell / Rear remain static during the local Shape Animation.

## Timing model
Reference preview timing ratio:

| Step | Ratio |
| --- | ---: |
| S0 start | 23% |
| S1 up | 16% |
| S2 | 22% |
| S1 down | 16% |
| S0 return | 23% |

The ratio is preserved while total cycle duration changes.

### Speed ranges
| Profile | Cycle duration range | Use |
| --- | --- | --- |
| Calm | 1.10–1.30 s | very relaxed swim |
| Standard | 0.90–1.10 s | **default** |
| Lively | 0.78–0.92 s | slightly quicker variation |

## Natural randomization rule
Randomization is allowed, but **never randomize individual frame durations independently**.

Recommended runtime behavior:
1. Select a total cycle duration from the active speed range.
2. Apply the fixed timing ratio above to all five steps.
3. Keep the selected duration for 2–4 loops.
4. When resampling, transition gradually to the new duration; avoid abrupt tempo jumps.
5. Multiple turtles may use a randomized initial phase so they do not flap in sync.

This preserves a natural rhythm while preventing every loop from feeling mechanically identical.

## Production path
1. Keep S0 as the approved source.
2. Produce S1 Near / Far pose variants.
3. Produce S2 Near / Far pose variants.
4. Review silhouettes and root/seam behavior.
5. Material / Palette compatibility QA.
6. Shape Lab sequential playback.
7. Runtime-size QA with Standard range first.
8. Test Calm / Lively ranges.
9. User visual approval.
10. Motion Master Lock.

## Current draft direction update — 2026-10-02
- User selected the latest shoulder-participation motion as the **working draft direction**.
- S0 remains the current approved pose.
- S1/S2 should allow visible motion from the Near flipper root/shoulder region instead of fixing the root and bending only the distal half.
- The current concept preview amplitude is considered **larger than desired**; production refinement should preserve the same motion character while reducing the total excursion.
- Far flipper motion is currently acceptable as the supporting rhythm and should remain visually subordinate.
- This approval is for **motion direction / draft behavior only**. The concept-sheet imagery is not a Production Source and does not promote S1/S2 assets to Locked.

## Current next gate
Refine S1 / S2 Near/Far pose variants from this draft direction, with **reduced Near amplitude + root participation**, then replay the loop before any Production LOCK.
