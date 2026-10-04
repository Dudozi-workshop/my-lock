# Candy Soft R2 · core shape closeout review

User chose Candy Soft as the basic-shape refinement direction on 2026-10-04.
The approved source is the byte-preserved atlas from commit
086ff273be38acf5063f0dd8124bf39d4908ce8e, located at
assets/raster_shapes/candy_soft/approved_direction_atlas.png on the retained
feat/candy-soft-runtime branch (SHA256 is recorded in the R2 manifest).

R2 derives independent padded 256px slots using the original pixels. It retains
the authored pink circle, yellow triangle and blue square colors. Other basic
tones use the same chroma/common-channel field: chroma selects hue, while the
common channel retains white highlights and dark depth. Color-specific asset
copies are not created. Alpha, framing, rotation and POP use a common source.

Route: canonical LABS ?lab=shape&review=candy-soft. Version LABS-2026.10.04-R03.
The shared ShapeSpecRenderer, LockTokenPainter, ShapeChoiceCard and
FloatingPreview support an explicit opt-in candidate flag, default false.
Crayon is always delegated to the existing renderer. Existing vector masters,
Crayon parameters, H02B, catalog and default production behavior are unchanged.

Review: 3×3 identities, 58/96/160px, light/dark, actual selection cards,
6/9/12 moving objects, rotation, POP and repeated spawn. Tests verify alpha and
safe edges, distinct colors, Crayon invariance and opacity. Web technical QA
does not replace physical Android LockActivity performance and visual QA.

Status: Visual Master Final / Locked / Active. User approved the reviewed candidate on 2026-10-04. Production PR #52 merged as 1cbaa3ac8e30239794ab3d10ea6d4fe6ccccdd52; 99 tests and Android/Web premerge builds passed. Physical Android QA remains pending. LABS keeps its explicit review flag; production uses the approved default renderer. No wholesale integration-branch merge.
