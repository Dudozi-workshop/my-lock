# MY LOCK Web Surface Inventory v1

Updated: 2026-10-04
Purpose: classify existing public and QA routes under the locked two-site governance.
Status: Inventory and migration plan only. This document does not delete routes.

## Canonical surfaces

| Surface | Canonical URL | Decision |
| --- | --- | --- |
| MAIN | https://my-lock-preview.rlatkd5959.workers.dev/ | KEEP |
| LABS | https://my-lock-shape-lab-pages.pages.dev/ | KEEP |

## MAIN route classification

| Existing route | Decision | Destination / note |
| --- | --- | --- |
| root | KEEP | Actual app preview |
| qa=lab | RETIRE | LABS root replaces this Main-side Lab home |
| qa=background-composition | MIGRATE | LABS lab=background |
| qa=aurora-sea-palette-round1 | MIGRATE | LABS lab=palette; preserve history in Decision Log |
| qa=aurora-sea-palette-round2 | MIGRATE | LABS lab=palette; preserve history in Decision Log |
| qa=aurora-sea-palette-round3 | MIGRATE | LABS lab=palette; preserve history in Decision Log |
| qa=sea-turtle-shell-runtime | MIGRATE | LABS lab=qa |
| qa=front-flipper-outer | MIGRATE | LABS lab=qa |
| qa=front-flipper-far | MIGRATE | LABS lab=qa |
| qa=sea-turtle-body-with-rear | MIGRATE | LABS lab=qa |
| qa=sea-turtle-underbelly | MIGRATE | LABS lab=qa |
| qa=sea-turtle-whole | MIGRATE | LABS lab=qa |
| qa=sea-turtle-production | REVIEW | Keep only if release-target runtime acceptance; otherwise migrate |
| qa=sea-turtle-app-integration | REVIEW | Keep only if release-target app integration acceptance; otherwise migrate |
| qa=sea-turtle-runtime-v3 | REVIEW | Alias of app integration route; remove alias after migration decision |
| qa=sea-turtle-swim-v1 | MIGRATE | LABS Runtime or Motion QA |
| asset-book path | MIGRATE | LABS Asset and Registry section; not a third surface |

## LABS routes

| Route | Decision | Ownership |
| --- | --- | --- |
| lab=background | KEEP | Background Lab |
| lab=shape | KEEP | Shape Lab |
| lab=style | KEEP | Style Lab |
| lab=palette | KEEP | Palette Lab |
| lab=effect | KEEP | Effect Lab |
| lab=qa | KEEP | Runtime QA |
| lab=motion | ADD WHEN NEEDED | Motion Lab inside LABS |
| lab=assets | ADD WHEN NEEDED | Asset and Registry inside LABS |

## Migration rule

1. No route is deleted merely because this inventory says MIGRATE or RETIRE.
2. First reproduce and verify required capability in LABS.
3. Verify the canonical LABS URL.
4. Then remove the redundant MAIN QA route in a separate change.
5. MAIN remains release-target app behavior only.
6. Historical candidates belong in Decision Logs and Registry, not permanent public websites.
