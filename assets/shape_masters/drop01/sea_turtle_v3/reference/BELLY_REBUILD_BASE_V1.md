# Sea Turtle v3 · Belly Rebuild Base v1

- Status: Belly Hidden Underlap reconstruction reference / QA baseline
- Date: 2026-09-27
- Authoritative source: Sea Turtle v3 authoritative master
- Moving parts: front_flipper_near, front_flipper_far only
- Fixed parts: shell, head_rear_group, belly
- Rule: moving front flippers own their own alpha / outline / shading / highlight. Static body must not retain F0 residuals.
- Belly rule: belly remains one continuous static base surface beneath both moving front flippers, including hidden underlap.

## Purpose

Use this image as the visual baseline when building Belly ownership/mask assets and when checking future Near/Far key poses. If a flipper pose exposes a previously covered area, the belly must still appear complete and natural.

## Full-resolution archive

- Belly Rebuild Base v1: https://drive.google.com/file/d/1USIMOXT2cH7H9V8q5nMTqSBG4a6_9o-A/view?usp=drivesdk
- Belly Rebuild QA v1: https://drive.google.com/file/d/1OT6gpz0t9IjQ2dD-sBW7-uNSz6rXOX9A/view?usp=drivesdk

## Repository preview

![Sea Turtle v3 Belly Rebuild Base v1](./sea_turtle_v3_belly_rebuild_base_v1_preview.webp)

## Next QA gate

1. Belly ownership mask
2. Belly removed remainder
3. Near/Far recomposite
4. residual outline / seam check
5. hidden-underlap reveal check
