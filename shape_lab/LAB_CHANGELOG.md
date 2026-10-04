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
