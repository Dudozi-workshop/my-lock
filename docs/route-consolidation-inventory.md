# MY LOCK Route Consolidation Inventory v1

Updated: 2026-10-04
Status: Classification only. No route removal in this step.

## Policy

Public surfaces remain exactly:
- MAIN: https://my-lock-preview.rlatkd5959.workers.dev/
- LABS: https://my-lock-shape-lab-pages.pages.dev/

MAIN owns release-target app UI/UX/runtime.
LABS owns production creation, comparison, candidate review, part QA, palette/effect/background work, and asset tooling.

## MAIN route classification

| Current route | Current role | Decision | Target |
| --- | --- | --- | --- |
| / | Actual app preview | KEEP | MAIN / |
| ?qa=lab | Legacy Lab home | RETIRE | LABS / |
| ?qa=background-composition | Background candidate comparison | MIGRATE | LABS ?lab=background |
| ?qa=aurora-sea-palette-round1 | Palette candidate comparison | MIGRATE | LABS ?lab=palette |
| ?qa=aurora-sea-palette-round2 | Palette candidate comparison | MIGRATE | LABS ?lab=palette |
| ?qa=aurora-sea-palette-round3 | Palette candidate comparison | MIGRATE | LABS ?lab=palette |
| ?qa=sea-turtle-shell-runtime | Part runtime QA | MIGRATE | LABS ?lab=qa |
| ?qa=front-flipper-outer | Part runtime QA | MIGRATE | LABS ?lab=qa |
| ?qa=front-flipper-far | Part runtime QA | MIGRATE | LABS ?lab=qa |
| ?qa=sea-turtle-body-with-rear | Part runtime QA | MIGRATE | LABS ?lab=qa |
| ?qa=sea-turtle-underbelly | Part runtime QA | MIGRATE | LABS ?lab=qa |
| ?qa=sea-turtle-whole | Whole assembly QA | MIGRATE | LABS ?lab=qa |
| ?qa=sea-turtle-production | Production-shape QA | MIGRATE | LABS ?lab=qa |
| ?qa=sea-turtle-app-integration | App integration verification | KEEP TEMPORARILY | MAIN until equivalent release-target verification exists |
| ?qa=sea-turtle-runtime-v3 | Alias of app integration QA | RETIRE | use canonical app-integration verification |
| ?qa=sea-turtle-swim-v1 | Motion candidate/runtime QA | MIGRATE | LABS Motion/Runtime QA |

## Static MAIN paths

| Current path | Decision | Target |
| --- | --- | --- |
| asset-book/ | MIGRATE | LABS Asset / Registry |

Asset Book is production tooling/reference, not actual app UI.

## LABS canonical routes

Keep and expand only inside the canonical LABS host:
- ?lab=background
- ?lab=shape
- ?lab=style
- ?lab=palette
- ?lab=effect
- ?lab=qa

Planned additions required by the governance model:
- ?lab=motion
- ?lab=assets

No separate public site is created for either addition.

## Migration order

1. Add missing LABS Motion and Asset/Registry sections.
2. Confirm LABS equivalents for each MAIN QA route.
3. Redirect or remove legacy MAIN candidate/part-QA routes only after equivalent verification.
4. Retain MAIN app-integration verification until it is represented by the actual release-target app flow.
5. Update public-preview-routes registry to contain only active canonical routes.

No route is deleted merely because it appears in this inventory.
