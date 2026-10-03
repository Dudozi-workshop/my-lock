# MY LOCK 2-Site Governance v1

Updated: 2026-10-03

## Canonical public sites

MY LOCK uses exactly two public web surfaces.

### MAIN - App Preview
- URL: https://my-lock-preview.rlatkd5959.workers.dev
- Purpose: actual app UI, UX, runtime, and release-target behavior verification.
- Do not add new experimental comparison tools, asset split QA, candidate galleries, or production-lab tooling here.

### LABS - Integrated Labs
- URL: https://my-lock-shape-lab-pages.pages.dev
- Purpose: integrated production workbench for Shape, Style, Palette, Motion, Background, Effect, Runtime QA, Asset, and Registry work.
- New labs must be added as routes/sections inside this site, not as new public sites.

## No third public site

Creating a third public site, Cloudflare Worker, Pages project, or separate public Lab domain is prohibited by default.
A new public endpoint may only replace one of the two canonical sites after explicit user approval.

Cloudflare revision URLs such as hash-prefixed pages.dev deployments are verification-only and must not be presented as the primary user-facing URL.

## Release metadata is mandatory

Every public MAIN or LABS update must define:

- Version
- Purpose
- Scope
- Source branch
- Source commit
- Status

Version format:
- MAIN: MAIN-YYYY.MM.DD-RNN
- LABS: LABS-YYYY.MM.DD-RNN

A deployment without Version and Purpose is not considered complete.

## Route ownership

MAIN:
- actual app behavior only
- release-target UI/UX/runtime

LABS:
- Shape Lab
- Style Lab
- Palette Lab
- Motion Lab
- Background Lab
- Effect Lab
- Runtime QA
- Asset / Registry

Legacy MAIN ?qa= routes may remain temporarily for migration, but must not be expanded with new lab functionality.

## Required pre-deploy check

1. Decide whether the work belongs to MAIN or LABS.
2. Confirm no new public site is being created.
3. Set Version and Purpose.
4. Confirm current Source of Truth and runtime/asset source.
5. Deploy only to the canonical target.
6. Verify the canonical URL after deployment.
7. Keep revision URLs only in deployment records.
