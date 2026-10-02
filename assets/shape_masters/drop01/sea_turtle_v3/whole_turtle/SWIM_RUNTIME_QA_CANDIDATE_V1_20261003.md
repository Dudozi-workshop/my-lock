# Sea Turtle v3 · Swim Runtime QA Candidate v1 — 2026-10-03

## Status
- Runtime implementation: **COMPLETE**
- Automated QA: **PASS**
- Web preview deployment: **PASS**
- User visual QA: **PENDING**
- Motion Master: **NOT LOCKED**

## Source / scope
- S0 remains the approved Sea Turtle v3 source pose.
- S1/S2 are the approved front-flipper Production Candidate poses.
- Body / Shell / Underbelly / Rear remain static and locked.
- No ImageGen was used for Production pose asset extraction or Runtime packaging.

## Runtime behavior
- Loop: `S0 → S1 → S2 → S1 → S0`
- Step ratio: `23 / 16 / 22 / 16 / 23`
- Calm: `1.10–1.30 s`
- Standard: `0.90–1.10 s` (default)
- Lively: `0.78–0.92 s`
- Selected cycle duration is held for 2–4 loops.
- Tempo resampling transitions gradually.
- Each turtle uses an independent initial phase so multiple turtles do not flap in sync.

## Runtime implementation
- Branch: `runtime/sea-turtle-v3`
- QA/deploy commit: `30258f06288a8f6fe617b6702d776730a95a55f3`
- Dedicated QA route: `?qa=sea-turtle-swim-v1`
- Public QA URL: https://my-lock-preview.rlatkd5959.workers.dev/?qa=sea-turtle-swim-v1

## Build / deployment verification
### Web
- Workflow: `MY LOCK Web Build`
- Run: `37032606326` / run #697
- Web build: **PASS**
- Artifact upload: **PASS**
- Cloudflare Worker deploy: **PASS**

### Runtime Candidate QA
- Workflow: `Runtime v3 Candidate QA`
- Run: `37032606322` / run #34
- Validate / Analyze / Test: **PASS**
- Production Web build: **PASS**
- Android release build including `lockMain`: **PASS**
- Review artifact upload: **PASS**

## Visual QA checklist
User should verify the deployed runtime for:
1. Near root / shoulder continuity.
2. Far root continuity and subordinate amplitude.
3. S0→S1→S2→S1→S0 rhythm.
4. No obvious synchronized flapping across multiple turtles.
5. Standard cadence first, then Calm / Lively.
6. 58 px readability.
7. Palette / Aurora detail retention during pose changes.

## Gate
This candidate is **not Final / not Locked** until deployed visual QA is user-approved.

Next Gate:
**User visual approval → Motion Master Lock → final manifest/package registration.**
