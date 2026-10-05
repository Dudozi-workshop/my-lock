# Floor Caustic · Static Study v1 · 2026-10-05

- User accepts R28 particle/bubble direction: “응 좋은데?!” / “좋다좋다”. Preserve R28 unchanged; no full Background lock or MAIN promotion implied.
- User authorizes Floor planning and trial: “응 어떻게 구현할지 일단 기획해보자” followed by “응 해보자” at 2026-10-05 11:59:29 KST.
- Fresh Preflight: Notion 06 Shape guide / Drop01 Asset Master / 05 Troubleshooting / 04 Manifest, GitHub background handoff, branch d304f792 and completed CI 37249040322 SUCCESS. Source of Truth agrees: approved immutable Base v2, approved Flow A, R28 details preserved, Surface Deferred, Floor Rework Required.
- Stage: STATIC ART DIRECTION CANDIDATE. No motion implemented, no LABS/release change. Public remains R28. Not Approved/Final/Locked.
- Reference: user's 76252 sheet panel 04 and 76038 anime shallow sea. Deterministic independent RGBA study, not extraction or ImageGen; warped irregular cellular boundary field, uneven cream edges, perspective-scaled cells and soft horizon fade.
- Canvas: 841×1870 RGBA, exact approved Base dimensions. Base binary unchanged and hash verified; composite QA changes zero pixels above floor start y=.655. Original renderer and every other runtime/source asset unchanged.
- Occlusion is an approximate scene-specific static mask for rocks/coral/shell, not production ownership data. Review at runtime viewport/aspect mapping before use.
- Generator: tool/render_floor_caustic_static_v1.py --base assets/backgrounds/drop01/shallow_clear_base_only_v2_approved_candidate.png --output OUTPUT. Requires numpy/Pillow, deterministic seed 10504. Saved package includes exact preview/layer/source/metadata.
- Next gate: user checks static shape/brightness → selected pattern gets independent local deformation and staggered brightness (visible within 1–2 seconds, calm motion) → stable asset registration if raster used → LABS version/CI/deploy/Public/actual Solo/composite playback review. Do not animate an unreviewed pattern or silently bundle all effects as Final.
