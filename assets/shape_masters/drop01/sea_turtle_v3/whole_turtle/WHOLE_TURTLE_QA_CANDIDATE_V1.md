# Sea Turtle v3 · Whole-turtle Seam / Material QA Candidate v1

## Status
**QA Candidate / user visual approval pending**

## Scope
- Static F0 only
- Final / Locked / Active parts only
- No Geometry edits
- No Material ownership edits
- No ImageGen
- QA compositor / placement only

## Locked inputs
- shell_main: Final / Locked
- body_with_rear: Geometry FINAL_v2 / Outline FINAL_v3 / FULL REMAP v2
- underbelly: Geometry FINAL_v4_cleanup / Material v2
- front_flipper_near (outer): Final Closeout v2 / Geometry v3 / Palette Runtime v2
- front_flipper_far: Geometry FINAL_v4 / Material-Palette-Runtime FINAL_v1

## Render order
1. front_flipper_far
2. body_with_rear
3. shell_main
4. underbelly
5. front_flipper_near

## QA compositor correction
The approved near/outer runtime58 PNG is a tight square crop rather than a full-canvas export.
The initial Whole QA screen incorrectly stretched that crop across the whole shape canvas.
No Part source was changed.

Correction:
- active canonical geometry bbox: (809, 909)-(1318, 1460) on 2048 canvas
- runtime crop placement square: left 788 / top 909 / side 551 on 2048 canvas
- commit: `75e1cf4f22bec058f38f33a44d55065c564e8337`

## Visual QA
Artifact-based F0 recomposition was inspected at:
- 58 px Light
- 58 px Dark
- 116 px inspection
- 232 px seam / outline inspection
- Pink #FF8FD1
- Blue #79BFFF
- Yellow #FFDA72

### Result
- Complete static F0 recomposition: PASS
- Part attachment gap: PASS
- Obvious double-outline / stacked-line artifact at 58 px: PASS
- Near front-flipper root continuity: PASS
- Far front-flipper root continuity: PASS
- Body ↔ underbelly ↔ shell palette-family continuity: PASS
- Pink / Blue / Yellow Shape + Color identity: PASS
- Light background readability: PASS
- Dark background readability: PASS
- 58 px silhouette readability: PASS
- obvious alpha halo / transparent fringe at 58 px: PASS
- render order / occlusion: PASS

### Inspection note
The Near/Outer Part uses its approved 58 px runtime bitmap. At 116/232 px inspection it is intentionally visibly rasterized; this is not treated as a Geometry or Material defect. The production decision remains based on actual 58 px readability.

## Build / Deploy
- Whole QA route: `?qa=sea-turtle-whole`
- public route: https://my-lock-preview.rlatkd5959.workers.dev/?qa=sea-turtle-whole
- corrected QA commit: `75e1cf4f22bec058f38f33a44d55065c564e8337`
- Web Build run: `36962408553` — PASS
- Cloudflare Deploy: PASS
- Android CI run: `36962408554` — pending at Candidate write time

## Gate
Do not promote Whole-turtle QA to Final / Locked until:
1. Android CI completes successfully, and
2. user visually approves the public Whole QA route.

No individual Part is reopened by this Candidate.
