# Sea Turtle v3 · Shell Asset v1

- Status: APPROVED / Shell ownership locked
- Date: 2026-09-27
- Role: fixed shell layer
- Source: approved shell extraction + Shell Ownership QA

## Files
- Full-res shell PNG (Google Drive): https://drive.google.com/file/d/1uaMYm8SOxAO9B3eITm_ZfAqXHdT_0vat/view?usp=drivesdk
- Shell Ownership QA PNG (Google Drive): https://drive.google.com/file/d/1-V3lkiiU_wJdxBzWNn3_19pN5gGxlnym/view?usp=drivesdk
- Shell Asset Pack ZIP (Google Drive): https://drive.google.com/file/d/1g6YtVrYPOjA2L-id3_ECri177ds9FrzT/view?usp=drivesdk

## Asset properties
- Isolated shell: RGBA, 1254 x 1254, transparent background
- QA board: RGB, 1122 x 1402

## Ownership rules
- Shell is a fixed layer.
- Belly is a separate fixed layer.
- Body + both rear flippers are handled separately.
- Only front_flipper_near / front_flipper_far are moving parts.
- Shell owns its alpha, outline, shading, highlight, and internal shell detail.
- Do not merge Belly, Body, rear flippers, or moving front-flipper pixels into Shell.

## Next gate
Use this shell asset in final static recomposition QA together with Belly, Body+Rear, Near, and Far. Check seam, ownership overlap/gap, outline residual, and exact/final composite consistency.
