# Sea Turtle v3 · Swim Motion Master v1

Status: **Final / Locked / Active**  
Lock date: **2026-10-03**

## Locked behavior
- Loop: `S0 → S1 → S2 → S1 → S0`
- Timing ratio: `23 / 16 / 22 / 16 / 23`
- Calm: `1.10–1.30 s`
- Standard: `0.90–1.10 s`
- Lively: `0.78–0.92 s`
- Selected duration holds for 2–4 loops, then changes gradually.
- Each turtle has an independent initial phase.
- Near and Far front flippers animate; Far remains visually subordinate.
- Body / Shell / Underbelly / Rear remain static and locked.

## Active files
The S1/S2 runtime chunks in this folder are the locked Motion Master v1 assets referenced by `../sea_turtle_v3_runtime_v3.json`.

Authoritative package manifest: `MOTION_MASTER_V1_FINAL.json`.

## QA
- Candidate automated QA run `37032606322`: SUCCESS
- Candidate Web/Cloudflare deploy run `37032606326`: SUCCESS
- Post-lock Web deploy run `37034687303`: SUCCESS
- User visual QA: APPROVED
- Production ImageGen: not used

## Versioning
Do not modify Motion Master v1 in place. Any future swim change must start a new candidate/version and pass the normal Gate.
