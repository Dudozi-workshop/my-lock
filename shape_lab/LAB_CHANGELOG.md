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
