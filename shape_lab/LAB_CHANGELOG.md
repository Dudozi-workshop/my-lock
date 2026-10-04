## LABS-2026.10.05-R18 · Volumetric A concept fan
- User clarification: do not preserve a three-shaft count; use the original concept fan. R17 superseded before art review.
- Seven unequal soft shafts fan out from upper centre, overlap at the source and separate downward; bright core, irregular widths, mid-water fade.
- A only; all locked assets/effects unchanged. Candidate pending Live Keep/Modify/Reject.

## LABS-2026.10.05-R17 · Volumetric A luminous fan
- R16 Modify: still weak; user concept 76252.png panel 03 is the visual reference.
- Brighter cores, unequal broad ribs, clear blue gaps, fan-shaped spread from upper centre; mid-water fade unchanged.
- A only. Base v2, B/C R14 and other effects immutable. Original procedural renderer; no ImageGen.
- Candidate awaiting Live Keep/Modify/Reject; not Final/Locked.

## LABS-2026.10.05-R16 · Volumetric A refinement
- R15 user verdict: Modify — visible, quality needs refinement.
- A only: unequal main/support beams, overlapping soft internal lobes, depth-delayed aperture movement; 24-second closed loop.
- Reference: Motion Array Light Rays Overlay Loop (1055584), visual study only; no downloaded stock media.
- Base v2 immutable; B/C R14 and all other effects unchanged. Candidate awaiting Keep/Modify/Reject.

# MY LOCK Labs Patch Log

## Patch version policy
- Every user-visible deployed patch increments the `LAB NNN` number shown at the top of MY LOCK Labs.
- Failed CI attempts do **not** consume a new LAB number. The same LAB number remains until that patch is successfully deployed.
- Header format: `LAB NNN · <focus> · <short patch name>`.
- Completion reports to the user must always include: **LAB version / commit / patch contents / deploy result**.

## LAB 035 · Sea Turtle v3 Static Split QA · Decode Fix
- **Before:** Header still showed `LAB 034 · Soft Basic Triangle Direction Round 1`, so Sea Turtle patches could not be visually distinguished.
- **After:** Header shows `LAB 035 · Sea Turtle v3 Static Split QA · Decode Fix`.
- **Why:** the deployed screen itself must identify which patch is currently visible.
- **Impact:** future patches must bump the visible LAB number before deployment.
- **Preview asset fix:** replaced the broken/truncated static split preview with a verified 1200×430 PNG under a cache-busted LAB 035 filename.
- **QA source:** local PNG open/verify PASS before GitHub blob creation.

## LABS-2026.10.03-R03 · Water Wave R2
- Purpose: replace rejected wave strokes with a coupled broad refractive color field and organic caustic area field.
- H01 Sunlit Caustic / H02 Living Water (baseline candidate) / H03 Deep Glass Sea.
- Enlarged + 58px Light/Dark, freeze/resume, 2-second exposure auto-pause.
- Existing locked palette-base alpha and fixed-finish pixels reused without modification.
- W01/W02/W03 Rejected / Archived; R1 history remains in Git.
- C02 Quick Signature v2 remains Production Final / Locked / Active. No candidate auto-promotion.
- CPU mesh field at 24Hz, shared across enlarged/58px previews; Android runtime/performance unverified.


## LABS-2026.10.04-R09 · Starfish 58px QA
- Replaced stale Starfish Round 1 silhouette candidates with the approved Appearance Master v1.
- Uses the locked 2048×2048 RGBA canonical binary; no generated reference substitution.
- Added 160/120/100/80/58px legibility comparison and 58px light/aqua/ocean/dark background contrast checks.
- Geometry, color, shading and source pixels remain immutable; only runtime resize/background presentation changes.
- 58px Gate remains visually pending until explicit user approval.


## LABS-2026.10.04-R10 · Starfish Color QA
- 58px Legibility QA recorded as PASS after user visual approval.
- Fixed R09 analyzer failure: unqualified dart:math max() usage and removed superseded unused Round-1 Starfish candidate renderer.
- Added Starfish locked-master static 6-color QA in Palette Lab.
- Exact Drop 01 colors: Deep Ocean #4F8EDB / Aqua Mint #7CCFC4 / Coral Pink #F7A7B5 / Sand Beige #EFD59A / Lavender #B9A7E8 / Peach Orange #F7B385.
- Color QA uses the same locked 2048 RGBA master and preserves alpha/luminosity via BlendMode.color; no new raster candidates are generated.
- Aurora Sea is intentionally not approximated as a static image; exact H02B dynamic renderer is deferred to Starfish Runtime palette binding QA.

## LABS-2026.10.05-R15 · A Broad Sunbeam
- A only: 3 feathered, gently bending volumes; warm-to-aqua light; mid-scene smooth attenuation.
- Dedicated seamless 24-second A clock; width, angle, brightness and position evolve in 1–2 seconds. B/C retain R14 timing and renderer.
- Base Only v2 and non-volumetric renderers/binaries unchanged. No ImageGen.
- Release identity now uses R15 metadata rather than stale R10 Starfish metadata.
- Art status: Candidate / Keep-Modify-Reject pending. No Final/LOCK or B/C expansion.
