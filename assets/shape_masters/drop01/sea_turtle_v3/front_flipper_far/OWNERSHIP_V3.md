# Sea Turtle v3 · Front Flipper Far F0 · Ownership v3

- Status: **Selected / QA Hold**
- User approval: 2026-09-30, “holy 맞아 이대로 쭉쭉 진행”
- Authoritative Master: **Q3 Canonical Master**
- Canvas: **2048 × 2048 RGBA**
- Part: `front_flipper_far` / F0
- ImageGen: **not used**
- Change from v2: lower-left outline residual region added to Far ownership.
- Locked and unchanged: `body_with_rear` / `shell_main` / `underbelly` / `front_flipper_near`

## QA at selection
- Ownership pixels: **62,712 px**
- v2 → v3 added pixels: **1,289 px**
- Added bbox: **[474, 1209, 582, 1360]**
- Source alpha outside pixels: **0**
- User-visible lower-left residual: removed in preview.

## Stored artifacts
- Ownership overlay: https://drive.google.com/file/d/14_o9tNCd8jnaIqET3vGppcUXCv7ja4NG/view?usp=drivesdk
- Review crop: https://drive.google.com/file/d/1jHA01P9jnIKF8xNPPx4ITzInrhdBqIXO/view?usp=drivesdk
- Lower-left review: https://drive.google.com/file/d/1SsPHpLePzQa8cbwax1AhMqRkvtKkm9Nb/view?usp=drivesdk
- Lower-left remainder proof: https://drive.google.com/file/d/1vrNaetCsvTTFYqUhH7vzyX9vx64ol8Wu/view?usp=drivesdk

## QA hold
Downstream Removed Remainder audit found **317 detached fringe pixels** within the local Far-Flipper zone that are source-visible but remained outside Ownership v3. A connected root-edge seam is also visible but remains attached to the locked static body, so it is not auto-reassigned without user review.

Ownership v3 is preserved as the approved lineage checkpoint, but downstream Mask/Asset promotion is on hold pending residual cleanup candidate review.
