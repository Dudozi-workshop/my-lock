# Build notes

The archived v2 builder creates the region source without changing locked geometry.

- master alpha: locked silhouette
- underbelly cleanup: far flipper excluded
- shell detail cleanup: shell interior only
- outline: recolorable mask
- shadow/highlight: neutral overlays clipped by master alpha
- palettes: Aqua Mint / Coral Pink / Sand Beige
- QA exports: 64 / 72 / 80 / 96 px
- production runtime scale: FloatingEngine dynamic diameter 14.4–18% of screen min dimension

The archived build script is preserved outside runtime code because it depends on Pillow, NumPy and OpenCV and is a reproducibility tool, not an app dependency.
