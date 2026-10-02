# Sea Turtle v3 · Swim Motion Master v1 — FINAL / LOCKED — 2026-10-03

## Status
- Motion Master: **Final / Locked / Active**
- User visual approval: **Approved**
- Runtime implementation: **Complete**
- Automated QA: **PASS**
- Web deployment: **PASS**

## Locked scope
- Animated: `front_flipper_near`, `front_flipper_far`
- Static / unchanged: `body_with_rear`, `shell_main`, `underbelly`, rear
- No whole-turtle redraw.
- No ImageGen used for Production pose extraction/runtime packaging.

## Locked motion
- Sequence: `S0 → S1 → S2 → S1 → S0`
- Ratio: `23 / 16 / 22 / 16 / 23`
- Near: root/shoulder participation retained.
- Far: root/shoulder participation retained with smaller subordinate amplitude.
- Motion character: calm, soft, low-amplitude swim.

## Locked runtime cadence
- Calm: `1.10–1.30 s`
- Standard: `0.90–1.10 s` (default)
- Lively: `0.78–0.92 s`
- Hold selected cycle duration for 2–4 loops.
- Resample tempo gradually.
- Random initial phase per turtle to avoid synchronized flapping.

## QA evidence
- Runtime Candidate QA run: `37032606322` — SUCCESS
- Web Build / Cloudflare Deploy run: `37032606326` — SUCCESS
- Post-lock Web deploy run: `37034687303` — SUCCESS
- Public QA route: `?qa=sea-turtle-swim-v1`
- Public QA URL: https://my-lock-preview.rlatkd5959.workers.dev/?qa=sea-turtle-swim-v1

## Runtime source
- Branch: `runtime/sea-turtle-v3`
- Final lock metadata commit: `1a95b29e47f00c7922aa95aff746bbbf669d7983`
- Final package manifest commit: `375d2fe2a6ca3247c85e055f381d2fb4752c642a`
- Final package README commit: `48f53b9a07bf7b9038199f9c1bf724fb391a2dc0`
- Package path: `assets/raster_shapes/swim_v1/`
- Package manifest: `assets/raster_shapes/swim_v1/MOTION_MASTER_V1_FINAL.json`

## Lock rule
This version is immutable as Motion Master v1. Any later change to pose geometry, timing, cadence, randomization, palette behavior, or root motion must be created as a new candidate/version and pass the production gates again.
