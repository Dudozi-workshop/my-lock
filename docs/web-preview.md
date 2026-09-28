# Free web preview deployment

MY LOCK keeps the GitHub repository private.

The web preview uses this flow:

1. GitHub Actions builds Flutter Web.
2. The generated `build/web` folder is uploaded as the `my-lock-web` artifact.
3. Wrangler deploys the static Flutter Web bundle through Cloudflare Workers.

## Current public preview

Current deployed Worker:

`https://my-lock-preview.rlatkd5959.workers.dev`

Sea Turtle outer-front-flipper runtime QA:

`https://my-lock-preview.rlatkd5959.workers.dev/?qa=front-flipper-outer`

Do not use the old GitHub Pages URL (`dudozi-workshop.github.io/my-lock`) for this preview. GitHub Pages is not the active deployment target.

## Build locally

```bash
bash tool/build_web.sh
```
