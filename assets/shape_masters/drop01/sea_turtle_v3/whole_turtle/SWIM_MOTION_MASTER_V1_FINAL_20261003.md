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
- Public QA route: `?qa=sea-turtle-swim-v1`
- Public QA URL: https://my-lock-preview.rlatkd5959.workers.dev/?qa=sea-turtle-swim-v1

## Runtime source
- Branch: `runtime/sea-turtle-v3`
- Final lock metadata commit: `4fca5dac3123aeb5f732301d886cff91040ba63d`
- QA label commit: `5447ff6524e20253ccf57a2c51aefa7f9a42062b`

## Lock rule
This version is immutable as Motion Master v1. Any later change to pose geometry, timing, cadence, randomization, palette behavior, or root motion must be created as a new candidate/version and pass the production gates again.
