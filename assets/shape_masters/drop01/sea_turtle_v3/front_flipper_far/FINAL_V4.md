# Sea Turtle v3 · Front Flipper Far F0 · FINAL v4

- Status: **Final / Locked / Active**
- Approved: 2026-09-30
- User decision: keep current root seam ownership unchanged; do not auto-reassign the connected static-body seam.
- Authoritative Master: **Q3 Canonical Master**
- Canvas: **2048 × 2048 RGBA**
- Part: `front_flipper_far` / F0
- ImageGen: **not used**
- Source lineage: Ownership v3 user-approved → v4 detached residual cleanup (+317 px) → user-approved root seam exclusion.
- Locked and unchanged: `body_with_rear` / `shell_main` / `underbelly` / `front_flipper_near`

## QA
- Ownership/Mask pixels: **63,029 px**
- bbox: **[470, 945, 712, 1362]**
- Connected components: **2** (main 63,015 px + source-valid 14 px lower-edge fringe)
- Asset visible pixels: **63,029 px**
- Asset ↔ Mask mismatch: **0 px**
- Asset ↔ Remainder overlap: **0 px**
- Remainder inside mask: **0 px**
- Transparent RGB residue: **0 px**
- Local Far-zone detached residual after cleanup: **0 px**
- Recomposite changed pixels: **0**
- Recomposite max channel diff: **0**
- Root seam auto-reassignment: **not performed by user decision**

## Google Drive
- Asset: https://drive.google.com/file/d/1-pEpuUWCs_VeOICKQe9iWS67Weh5hZfo/view
- Mask: https://drive.google.com/file/d/1b0ctUahdwyhYrqFk_OXCG_GvtzCSsUI6/view
- Removed Remainder: https://drive.google.com/file/d/1SkHNsHYJFbWO_c774tmT1U92iBFwRQMe/view
- Ownership Overlay: https://drive.google.com/file/d/1HxsxCpxGwFlVpRa8cO0WoQb-3jmCEi3h/view
- Ownership QA: https://drive.google.com/file/d/1yhJK7wMmQwMNrIf5L2tJW_JkMDkFPSOZ/view
- Recomposite QA: https://drive.google.com/file/d/1-ZVxZnJcupB6Vo_alM6t2kfTTq5_Gbpv/view
- Recomposite Diff: https://drive.google.com/file/d/1WxNL8cGIoHOJn2GHu5t81RoC1y1uDfQr/view
- Review Strip: https://drive.google.com/file/d/1wCxX5DVeb1bsc3dMFUC8mtI-tPHjMvw7/view
- Final Package: https://drive.google.com/file/d/1alvbbMRfJdtQL3jK8d7zhNcjGUPOZnOX/view

## Next Gate
`front_flipper_far` F0 Shape Beauty / Material Decomposition → **Outline Ownership Overlay**.

Sequence: `Outline → Pattern / Detail → Shadow → Highlight → Base / Albedo → Material Recomposition QA → Palette QA → Surface/Material Compatibility QA → Runtime QA`.

`front_flipper_near` is already locked and must not be re-derived in this continuation.
