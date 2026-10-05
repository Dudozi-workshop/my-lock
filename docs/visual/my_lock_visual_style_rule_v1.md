# MY LOCK Visual Style Rule v1 — Soft Pastel Storybook

Status: Active Working Style / Jellyfish Anchor Approved / Cross-Asset QA Pending  
Decision date: 2026-10-05

## 1. Purpose
Define the shared character-construction and render language for MY LOCK so Jellyfish, Dolphin, Sea Turtle, Starfish, and later character Shapes read as one world.

## 2. Anchor
- Primary visual anchor: **Jellyfish Character Appearance Master v1**
- Approved source: `MYLOCK_Jellyfish_Character_Appearance_Master_v1_20261005.jpg`
- Source size: **1536×1536 RGB JPEG**
- SHA-256: `815e823c166b0aa3d9c22e5931cd6cc204ff4d317046c370b489ecb70a031067`
- Drive file ID: `1OB62WuS0xx__1spO8mpaizJiQOeLYJzt`
- This source is the **visual appearance master**. 2048 transparent RGBA production canonicalization is a separate downstream gate.

## 3. Core Impression
- soft
- warm
- storybook-like
- character-first
- pastel
- clean rather than texturally noisy
- illustrated rather than realistic
- cute without excessive mascot exaggeration

## 4. Character Construction
- Build from a small number of large, rounded masses.
- Preserve immediate species/object recognition, but simplify anatomy into a friendly character silhouette.
- Prefer stable organic curves over sharp points.
- Keep proportions compact and soft, but avoid oversized-head / tiny-body mascot formulas.
- Character identity should come from silhouette, curve rhythm, and minimal face before decoration.

## 5. Color
- Use light pastel families.
- Keep transitions soft and airy rather than high-contrast.
- Avoid muddy color mixing and excessive saturation.
- Do not fragment the character into many small color patches.
- Multi-color characters may use blended pastel fields when the overall mass remains clear.

## 6. Shading
- Use shallow, soft shading only.
- Shading explains overlap and structure; it does not simulate realistic lighting.
- Avoid deep AO, hard cast shadows, and photorealistic volume.
- Avoid glossy / jelly / plastic rendering as base identity.

## 7. Edge Language
- No black hard outline.
- Use a soft colored contour that supports the local color.
- Contours should be visible enough to stabilize small-size readability, but never dominate the illustration.
- Edge quality should feel hand-drawn but controlled.

## 8. Texture
- Allow light watercolor / wash texture.
- Texture must remain subtle enough that the asset still feels clean.
- Do not use heavy paper grain, rough crayon noise, or dense pigment breakup.
- Runtime reduction must not turn texture into dirt/noise.

## 9. Minimal Face
- Small dot or short-oval eyes.
- Short simple curved mouth.
- Blush allowed at low contrast.
- No default eyebrows, teeth, wide-open mouth, or exaggerated emotional acting.
- Face should support the character, not become the dominant feature.

## 10. Base Art vs Effect
The base character must remain complete with effects disabled.

Not base identity:
- strong specular
- glass/jelly gloss
- glow/bloom
- caustic/refraction
- moving light
- bubbles/particles
- sparkle
- aurora

## 11. Prohibited Directions
- realistic biological illustration
- realistic 3D render
- strong gloss
- deep volumetric shading
- black-outline cartoon
- heavy cel shading
- neon-led identity
- excessive facial exaggeration
- dense micro-detail
- inconsistent per-asset art styles

## 12. QA
Check:
1. silhouette readability
2. rounded construction language
3. pastel clarity
4. shallow shading
5. controlled colored contour
6. minimal-face balance
7. texture cleanliness
8. runtime readability
9. cross-asset world fit

Result:
- PASS
- CALIBRATE
- REJECT

## 13. Current Gate
- Jellyfish: Appearance Master v1 approved as style anchor.
- Dolphin: next character-construction translation target.
- Sea Turtle: follows Dolphin.
- Visual Style Rule v1 remains **not globally locked** until at least two additional character assets pass cross-asset QA.
