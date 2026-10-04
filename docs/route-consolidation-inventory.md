# MY LOCK Route Consolidation Inventory v2

Updated: 2026-10-04
Status: Step 4 source inventory complete; migration/retirement pending. No routes or deployments changed.

This is the consolidated inventory. `web-surface-inventory.md` and `web-route-inventory.md` are superseded summaries. Live link construction remains owned by `public-preview-routes.json`; proposed destinations below are not proof of implemented replacements.

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

## Step 4 audit evidence and scope

- MAIN snapshot: `d3db5c4`; router: `lib/app/my_lock_app.dart` (15 QA values).
- LABS Integration snapshot: `6209c32`; router: `shape_lab/main.dart` (6 tabs, plus `review=candy-soft` under Shape).
- Handoff commit `a6db7ad` is an ancestor of Integration, not its current head. Later Candy Soft work/header R03 must be preserved.
- All 78 fetched origin remote references were scanned for pages.dev / workers.dev / github.io references, including workflows, documents and asset manifests.
- Current MAIN and Integration workflows and static web files were inspected.
- Notion governance pages `3eecfef7-d763-8192-9500-f7c251d27c02` and `3eecfef7-d763-8122-a2f0-d4194931e1f4` agree on exactly two public sites and LABS ownership of production QA.
- This is a repository-backed census. Cloudflare account project/deployment inventory and live route rendering were not queried; historical endpoints' deployment/deletion status is unverified. Repository references do not prove an endpoint is still live.

## Additional sites and route variants

| Existing endpoint / route | Evidence | Classification | Destination / completion condition |
| --- | --- | --- | --- |
| my-lock-shape-lab.rlatkd5959.workers.dev | Historical shape-lab.yml and shape-lab-preview-standard.md | RETIRE PLANNED | LABS; check Cloudflare deployment ownership and dependencies before disabling |
| my-lock-preview.pages.dev | Historical web-preview.md | RETIRE PLANNED | MAIN; deployment existence unverified |
| dudozi-workshop.github.io/my-lock | web-preview.md explicitly says not active preview target | RETIRE AS PREVIEW | MAIN; preserve any required privacy-policy/support content before disabling GitHub Pages |
| LABS ?lab=review | Historical shape-lab-preview-standard.md | RETIRE / NORMALIZE | No current review tab; current router falls back to Style. Assess historical review capability before replacement |
| LABS ?lab=shape&review=candy-soft | Integration router and Candy Soft link | KEEP | Shape sub-review; preserve current Candy Soft work |
| LABS ?lab=motion | Absent from current enum/router | PLANNED ADDITION | Existing LABS host only; not usable as a Motion destination yet |
| LABS ?lab=assets | Absent from current enum/router | PLANNED ADDITION | Existing LABS host only; not usable as an Asset destination yet |
| LABS ?lab=runtime | Absent from current enum/router | DO NOT ADD ALIAS | Keep current ?lab=qa; no need for a duplicate runtime route |
| Hash-prefixed Pages revision URLs | Governance rule | VERIFICATION RECORD ONLY | Never primary user links; not separate canonical sites |
| pages.dev/?qa=... or workers.dev/?lab=... | web-preview.md prohibited examples | INVALID COMBINATIONS | Route family must match canonical host; not implemented routes |

`?lab=style` and LABS root both resolve to Style by default. An unknown lab value currently falls back to Style; page loading alone cannot verify Motion/Asset/Review availability.

## Classification reconciliation

The earlier three inventories disagree on app-integration ownership. Apply the temporary-retention rule in this consolidated inventory: keep `?qa=sea-turtle-app-integration` operational until release-target app acceptance exists, while dedicated production/part QA migrates to LABS. This is a migration classification, not a permanent exception to governance. The alias `?qa=sea-turtle-runtime-v3` is a planned retirement, not already removed.

The 15 MAIN QA values classify as 12 MIGRATE, 2 planned RETIRE (`lab`, `sea-turtle-runtime-v3`), and 1 KEEP TEMPORARILY (`sea-turtle-app-integration`). MAIN Asset Book also migrates. LABS retains root, six tab routes, and Candy Soft sub-review.

Preserve palette candidate outcomes in decision history. Migration must not silently promote old candidates or alter locked H02B/Sea Turtle assets. Part QA needs selector/control parity, not merely a link to a generic QA tab. Asset Book automatic reflection remains paused per prior decision.

## Source alignment required before Step 5

MAIN contains `config/site_registry.json`, `tool/validate_site_governance.py`, and a governance validation step in the Integration workflow. The current Integration snapshot lacks that Registry and validation step. MAIN's LABS Registry metadata still references R02 / Water Wave R1, while current Integration has later R03 / Candy Soft content. Therefore the statement that both current deployment branches share enforced governance is not supported by current source.

Do not roll back the Integration branch or replace its current header with the earlier R01 handoff. Before migration/deployment, align governance enforcement and source metadata using the current Integration work as the base, then verify the canonical LABS deployment. Record the actual deploying source commit.

## Verification and next execution

- Existing MAIN `validate_site_governance.py`: PASS.
- Existing MAIN `validate_public_preview_routes.py`: PASS. This validates current link syntax, not migration parity or live rendering.
- No route removed, redirects installed, asset changed, host created, or Cloudflare deployment disabled in Step 4.
- Step 5 order: reconcile Integration governance/metadata; implement Motion and Asset sections; verify each replacement's required controls and current asset sources; update editable links; retire redundant routes only after replacement QA and required approval.
- Locked asset manifests containing old QA URLs are evidence/history; do not rewrite them as part of inventory. Track editable document/workflow references separately during migration.
