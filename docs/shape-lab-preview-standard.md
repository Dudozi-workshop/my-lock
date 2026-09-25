# Shape Lab preview standard

MY LOCK Shape Lab uses three access layers so development does not stop when a
single preview host has a DNS or deployment problem.

## Access order

1. **Primary — Cloudflare Pages**
   - https://my-lock-shape-lab-pages.pages.dev/
   - This is the URL used for normal review and candidate comparison.
2. **Backup — Cloudflare Worker**
   - https://my-lock-shape-lab.rlatkd5959.workers.dev/
   - Use only when the Pages deployment is unavailable.
3. **Recovery — GitHub Actions artifact**
   - Workflow: `MY LOCK Crayon Shape Lab`
   - Artifact: `my-lock-crayon-shape-lab`
   - Retention: 14 days.

## Deployment rule

A push to `feat/crayon-style-lab` that changes ShapeSpec, Shape Lab, or build
configuration performs the following sequence:

1. validate ShapeSpec mask assets;
2. run ShapeSpec tests;
3. build the Flutter Shape Lab once;
4. upload the exact build as a recovery artifact;
5. deploy and verify Cloudflare Pages;
6. deploy and verify the Worker as a non-blocking backup.

The Worker is intentionally non-blocking. A `workers.dev` DNS problem must
not mark the Shape Lab release as failed when the Pages primary is healthy.

## Review rule

All Crayon Soft candidate decisions are made from the live Shape Lab renderer,
not from manually generated screenshots. Candidate cards use the same
`LockTokenPainter` and `ShapeSpecRenderer` as the app. Screenshots are only
records of a review result.

## Failure handling

- Pages works, Worker fails: continue review on Pages.
- Pages fails: treat the workflow as failed and inspect the deployment log.
- Both public hosts are inaccessible: download the GitHub Actions artifact and
  serve `build/shape_lab` locally.
