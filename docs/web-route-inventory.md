> Superseded on 2026-10-04 by [Route Consolidation Inventory v2](route-consolidation-inventory.md). Use that single classification table; the historical recommendations below are not current execution instructions.

# MY LOCK Web Route Inventory v1

Updated: 2026-10-04
Status: migration inventory
Rule: public surfaces remain exactly MAIN and LABS. This inventory does not create or remove routes by itself.

## MAIN - keep

| Route | Classification | Reason |
| --- | --- | --- |
| root | KEEP | Actual app preview / release-target runtime. |

## MAIN legacy QA - migrate to LABS

| Route | Target | Classification |
| --- | --- | --- |
| ?qa=lab | LABS root | MIGRATE |
| ?qa=sea-turtle-shell-runtime | ?lab=shape or ?lab=qa | MIGRATE |
| ?qa=front-flipper-outer | ?lab=shape | MIGRATE |
| ?qa=front-flipper-far | ?lab=shape | MIGRATE |
| ?qa=sea-turtle-body-with-rear | ?lab=shape | MIGRATE |
| ?qa=sea-turtle-underbelly | ?lab=shape | MIGRATE |
| ?qa=sea-turtle-whole | ?lab=shape / ?lab=qa | MIGRATE |
| ?qa=sea-turtle-production | ?lab=qa | MIGRATE |
| ?qa=sea-turtle-app-integration | ?lab=qa | MIGRATE |
| ?qa=sea-turtle-runtime-v3 | ?lab=qa | MIGRATE |
| ?qa=sea-turtle-swim-v1 | ?lab=motion or ?lab=qa | MIGRATE |
| ?qa=background-composition | ?lab=background | MIGRATE |
| ?qa=aurora-sea-palette-round1 | ?lab=palette | MIGRATE |
| ?qa=aurora-sea-palette-round2 | ?lab=palette | MIGRATE |
| ?qa=aurora-sea-palette-round3 | ?lab=palette | MIGRATE |
| /asset-book/ | ?lab=assets | MIGRATE |

MAIN legacy routes stay operational until their LABS replacement is verified. Do not delete them during inventory.

## LABS - keep

| Route | Classification | Purpose |
| --- | --- | --- |
| root | KEEP | Integrated Labs entry |
| ?lab=background | KEEP | Background production / comparison / QA |
| ?lab=shape | KEEP | Shape production / decomposition / QA |
| ?lab=style | KEEP | Style production / comparison |
| ?lab=palette | KEEP | Palette / signature color comparison |
| ?lab=effect | KEEP | Effect production / comparison |
| ?lab=qa | KEEP | Runtime QA |

## LABS - normalized additions

These are sections inside the existing LABS site, not new sites.

| Route | Classification | Purpose |
| --- | --- | --- |
| ?lab=motion | ADD | Motion candidates and motion QA |
| ?lab=assets | ADD | Asset Book / Registry |
| ?lab=runtime | ALIAS / NORMALIZE | Human-readable Runtime QA route; may replace ?lab=qa after compatibility check |

## Retirement rule

A MAIN legacy QA route can be marked RETIRE only when:
1. equivalent LABS function exists,
2. current Source of Truth is used,
3. canonical LABS URL is verified,
4. no required workflow/document still points to the MAIN QA route,
5. user approves retirement.

Until then its status remains MIGRATE, not DELETE.
