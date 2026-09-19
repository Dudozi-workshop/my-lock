# Free web preview deployment

MY LOCK keeps the GitHub repository private.

The web preview uses this flow:

1. GitHub Actions builds Flutter Web for free.
2. The generated `build/web` folder is uploaded as the `my-lock-web` artifact.
3. Cloudflare Pages can host that static folder on the free plan.

## Cloudflare Pages target

Recommended project name:

`my-lock-preview`

Expected public URL after the one-time Cloudflare setup:

`https://my-lock-preview.pages.dev`

The repository intentionally does not require a paid GitHub Pages plan.

## Build locally

```bash
bash tool/build_web.sh
```
