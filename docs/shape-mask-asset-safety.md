# ShapeSpec Mask Asset Safety

## Why this exists
Soft Basic PREVIEW 004, 005, and 007 repeatedly hit the same failure class: a Base64 text file looked valid enough to commit, but the decoded PNG payload was truncated or malformed. Flutter's image codec then failed during `shape_spec_test.dart`, while the web build could still succeed.

## Required asset contract
Every ShapeSpec raster mask must:
- be valid Base64 text;
- decode to a complete PNG with valid chunk boundaries and CRCs;
- contain IHDR and IEND;
- be exactly 128 x 128;
- use 8-bit RGBA PNG (PNG color type 6);
- use transparency for mask intensity when the layer is intended as an alpha mask.

## Mandatory workflow
1. Generate/edit the PNG source.
2. Convert the PNG to Base64 without manual copy/truncation.
3. Run `python3 tool/validate_shape_masks.py`.
4. Only then update the corresponding ShapeSpec JSON.
5. A build is not considered complete until both:
   - MY LOCK Web Build = success
   - MyLock CI = success

## Do not
- manually trim or reconstruct Base64 strings;
- assume a successful Flutter Web build proves Android codec compatibility;
- report a preview as completed while MyLock CI is red;
- create a new preview iteration before the current asset payload passes validation.

## Incident note
PREVIEW 007 failed because `circle_form_shadow_v4.b64` and `circle_core_spec_v6.b64` were corrupted in the repository. The failure presented as:
`Codec failed to produce an image, possibly due to invalid image data.`

The validator is now executed before both web build and Flutter CI to stop this failure earlier.
