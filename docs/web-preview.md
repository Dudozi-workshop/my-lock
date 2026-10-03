# Free web preview deployment

MY LOCK keeps the GitHub repository private.

The web preview uses this flow:

1. GitHub Actions builds Flutter Web.
2. The generated `build/web` folder is uploaded as the `my-lock-web` artifact.
3. Wrangler deploys the static Flutter Web bundle through Cloudflare Workers.

## Canonical route rule

MY LOCK currently has **two public web surfaces**. Do not mix their query families.

- **Main Preview Worker** — `https://my-lock-preview.rlatkd5959.workers.dev/`
  - Uses `?qa=...`
  - App/runtime QA, including Sea Turtle and Aurora Sea candidate screens
- **Integrated Labs Pages** — `https://my-lock-shape-lab-pages.pages.dev/`
  - Uses `?lab=...`
  - Shape / Style / Palette / Effect / Runtime Lab tabs

Examples:
- Aurora Sea Round 1: `https://my-lock-preview.rlatkd5959.workers.dev/?qa=aurora-sea-palette-round1`
- Integrated Palette Lab: `https://my-lock-shape-lab-pages.pages.dev/?lab=palette`

**Never construct `pages.dev/?qa=...` or `workers.dev/?lab=...`.**
Before sharing a public link, check `docs/public-preview-routes.json` and confirm the matching deployment workflow succeeded for the current commit.

## Current public preview

Current deployed Worker:

`https://my-lock-preview.rlatkd5959.workers.dev`

Sea Turtle outer-front-flipper runtime QA:

`https://my-lock-preview.rlatkd5959.workers.dev/?qa=front-flipper-outer`

Sea Turtle production Asset Book:

`https://my-lock-preview.rlatkd5959.workers.dev/asset-book/`

The Asset Book is a read-only viewer generated from Final / Locked Production manifests during the web build. It is not a Source of Truth. Public preview images are version-guarded low-resolution mirrors; when a Production version changes, a stale preview is hidden until its viewer mirror is refreshed.

Do not use the old GitHub Pages URL (`dudozi-workshop.github.io/my-lock`) for this preview. GitHub Pages is not the active deployment target.

## Build locally

```bash
bash tool/build_web.sh
```


## Asset Book test freeze

The Asset Book is currently a frozen test snapshot.

- Default web builds do not regenerate Asset Book data from Production manifests.
- Set `ASSET_BOOK_AUTO_SYNC=1` explicitly to regenerate the registry.
- Until re-enabled, Production asset changes must not be treated as automatically reflected in the Asset Book.
