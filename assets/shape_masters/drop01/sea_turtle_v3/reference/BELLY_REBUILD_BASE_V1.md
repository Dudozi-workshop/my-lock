# Sea Turtle v3 · Belly Rebuild Base v1

- Status: Belly Hidden Underlap reconstruction reference / QA baseline
- Date: 2026-09-27
- Authoritative source: Sea Turtle v3 authoritative master
- Moving parts: front_flipper_near, front_flipper_far only
- Fixed runtime groups: shell, belly, body/head+rear group
- Authoring split rule: belly is always independent. head_upper and rear_flipper regions may be extracted and QA'd separately, then merged later only if runtime packaging benefits.
- Rule: moving front flippers own their own alpha / outline / shading / highlight. Static body must not retain F0 residuals.
- Belly rule: belly remains one continuous static base surface beneath both moving front flippers, including hidden underlap.

## Purpose

Use this image as the visual baseline when building Belly ownership/mask assets and when checking future Near/Far key poses. If a flipper pose exposes a previously covered area, the belly must still appear complete and natural.

## Layer extraction policy — 2026-09-27 revision

1. Belly is completed and locked before head/rear/shell refinement continues.
2. Do not extract head + belly + rear as one authoring asset.
3. Head upper region excludes the mouth/lower-jaw/cream underside.
4. Rear flipper regions may be extracted independently from head/body during authoring. They do not need to be contiguous with the head.
5. If desired later, head_upper + rear_flipper_near + rear_flipper_far can be merged into one fixed runtime group after each region passes QA.
6. QA boards are review artifacts only. Every accepted region must also have a real transparent asset, a mask, and a removed-remainder/recomposition check.

## No-image-generation rule for layer split

- Normal layer extraction must use the authoritative master/rebuild pixels + explicit masks only.
- Do not use image generation to create, repaint, or reinterpret ordinary semantic regions.
- Image generation/editing is reserved only for genuinely missing hidden-underlap pixels that do not exist in the source.
- Even for hidden-underlap reconstruction, ask the user for approval before using image generation.
- Once a hidden-underlap reference is approved, subsequent ownership extraction is pixel/mask based and must not regenerate the region.

## Belly deliverables

- belly_2048 / production-resolution transparent asset
- belly_mask
- belly_removed_remainder
- belly_ownership_qa
- hidden_underlap_reveal_qa
- Near/Far recomposite QA
- seam / residual-outline check

## Full-resolution archive

- Belly Rebuild Base v1: https://drive.google.com/file/d/1USIMOXT2cH7H9V8q5nMTqSBG4a6_9o-A/view?usp=drivesdk
- Belly Rebuild QA v1: https://drive.google.com/file/d/1OT6gpz0t9IjQ2dD-sBW7-uNSz6rXOX9A/view?usp=drivesdk

## Repository preview

![Sea Turtle v3 Belly Rebuild Base v1](./sea_turtle_v3_belly_rebuild_base_v1_preview.webp)

## Next QA gate

1. Extract Belly from the approved Belly Rebuild Base without image generation.
2. Save the Belly asset and mask.
3. Generate Belly removed remainder.
4. Recompose Near/Far front flippers.
5. Check residual outline / seam.
6. Check hidden-underlap reveal.
7. Lock Belly region before proceeding to head/rear.
