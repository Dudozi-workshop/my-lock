# Sea Turtle v3 · Shell Asset v1 — FINAL

- Status: FINAL / LOCKED
- Approval date: 2026-09-29
- Role: fixed shell layer
- Canonical canvas: 2048 × 2048 RGBA
- Source pixels: sea_turtle_master_v3_2048.png only
- Review reference: approved 1254 × 1254 Shell review crop (ownership reference only)

## Final production files
- Asset: https://drive.google.com/file/d/1nCUJQ35ST_fuwTq48WxQz5YjveN_KlB7/view?usp=drivesdk
- Mask: https://drive.google.com/file/d/1h23rjWhefJb0Hp6x1dMeErSrUJkXha2T/view?usp=drivesdk
- Removed remainder: https://drive.google.com/file/d/1F35oGhotELwwXiM03Tw7nVCFIgL2DeRI/view?usp=drivesdk
- Recomposite QA: https://drive.google.com/file/d/1dpJHEvgXQocwD0jh4jRGKA4GwyrVi5o_/view?usp=drivesdk
- Recomposite diff: https://drive.google.com/file/d/1NH2T3RVattIj7lhEchD6pLDQm0V91mwr/view?usp=drivesdk
- Ownership QA: https://drive.google.com/file/d/11l8kAbcH7xGMhuKVdwbyTZYkr9AyAjPu/view?usp=drivesdk
- Manifest: https://drive.google.com/file/d/1KPOiKOudPaxDCva73cDV8FQkQxkC9oFw/view?usp=drivesdk
- Final pack ZIP: https://drive.google.com/file/d/1C4SBlAedd1_1staOFtSlZLU2X71KZsvX/view?usp=drivesdk

## Ownership lock
- Shell owns its alpha, outline, shading, highlight, pattern, division lines, and internal detail.
- Belly, body_with_rear, front_flipper_near, and front_flipper_far pixels are excluded.
- Every deliverable derives from one binary ownership mask.
- The 1254 review crop does not replace the 2048 canonical asset.

## QA lock
- Recomposite changed pixels: 0
- Maximum channel difference: 0
- Non-shell pixels in asset: 0

## Runtime lock
- Material model: Hybrid Material Compositor
- Pink / Blue / Yellow fixed palettes retained.
- Aurora Sea colors: #65D8CF, #72BDED, #A894E2, #E58FBE, #66D5B9
- Duration: 4 seconds
- Moving layer: base color / albedo only
- Fixed layers: shadow, pattern, division lines, highlight, outline
- Detail overlay opacity: 0.52

Shell v1 is closed. Whole-turtle recomposition remains a later gate after Belly and both front flippers are finalized.
