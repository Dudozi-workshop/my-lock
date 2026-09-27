# MY LOCK Shape Asset Execution & Reporting Protocol v1

Date: 2026-09-27
Scope: all Shape / illustrated asset / semantic layer work

## 0. Mandatory preflight

Before every asset/image production step:
1. Read the current Notion page **06. Shape 제작 가이드**, especially:
   - Canonical Production Asset Rule
   - Shape Asset Execution & Reporting Protocol
2. Read the current Shape-specific Asset Master / latest approved output.
3. Identify the **Authoritative Master**, current locked parts, exact requested scope, and current candidate version.
4. Do not reinterpret locked geometry, ratio, silhouette, layer ownership, palette, overlay, or detail unless the user explicitly approves a change.

If any source/version conflicts, stop and resolve the source-of-truth conflict before producing a new asset.

## 1. Work modes

### Default
- Unless the user explicitly says `이미지만 ㄱㄱ`, all Shape/Image/Asset work is handled in **산출물 보고형** by default.

### 이미지만 ㄱㄱ
- Return image/result only.
- No report, no analysis, no next-step commentary.

### 산출물 보고형 ㄱㄱ
- Do **not** create a report-image unless explicitly requested.
- Produce the actual files separately.
- In chat, report:
  1. Current step
  2. Source / Authoritative Master
  3. Canvas / resolution / coordinate basis
  4. Exact scope changed
  5. Method used (including whether ImageGen was used)
  6. Actual outputs created, each with role
  7. QA / alignment / recomposition result
  8. Current status: Intermediate / QA candidate / LOCK candidate / Final
  9. Next single step
- Show only the artifacts needed for the current step.
- When the entire part is completed, provide a final bundle review with all final part assets.

### 논의 ㄱㄱ
- Do not produce or implement.
- Analyze problem, alternatives, tradeoffs, and recommended direction only.

### 구현 ㄱㄱ
- Implement directly in code/app/web.
- Minimize preamble.
- Verify and report actual result/link.

## 2. One-step-at-a-time rule

Do not jump ahead.
For semantic-layer work, progress one gate at a time:
1. Source review
2. Ownership overlay on source
3. User approval of overlay
4. Mask derived from approved overlay
5. Asset extraction
6. Removed remainder
7. Recomposite / residual QA
8. User approval
9. LOCK / save / register

Only proceed to the next gate after the current gate is approved or objectively verified.

## 3. Overlay-first review rule

For semantic ownership work:
- Primary review artifact is **the ownership overlay placed on the actual source/base**.
- Do not ask the user to judge a mask alone.
- A mask is a derived technical artifact after overlay approval.
- The approved overlay is the visual ownership reference.

## 4. Canonical raster rule

For complex illustrated raster Shapes:
- Canonical canvas = **2048 × 2048 transparent RGBA** unless the current Master explicitly says otherwise.
- Every part keeps the same full-canvas coordinate system, scale, anchor, and position as the Authoritative Master.
- Cropped assets are review/derived artifacts only.
- Production part extraction must come from the approved canonical source/base; do not generate a visually similar replacement.

## 5. Image generation rule — HARD GATE

- **ImageGen is prohibited by default for all Shape / Part / Mask / Asset work.**
- Do not use ImageGen for:
  - Ownership extraction
  - layer separation
  - Mask creation
  - Asset extraction
  - Removed Remainder
  - Recomposite
  - QA
- Use only approved existing pixels + explicit masks + deterministic pixel/compositing operations.

### Exception: genuinely missing pixels only
- Hidden Underlap or other truly missing source pixels may be candidates for reconstruction.
- ImageGen may be used **only when the user explicitly approves its use in that specific turn**.
- Prior approval, general project approval, or an earlier exception does not carry forward.
- If explicit approval is absent, **do not call ImageGen**.
- Once a reconstruction is approved, all subsequent ownership/mask/asset/remainder/QA derivations must be pixel/mask based and must not regenerate the part.

### Accidental ImageGen use
- Any asset generated in violation of this rule is **not a Production Candidate**.
- Treat it as discarded and restart from the last approved Source using non-generative operations.

## 6. Scope-lock rule

If the user says a specific part only:
- Everything outside that scope is locked.
- Do not regenerate the entire Shape.
- Do not modify Shell, Belly, other flippers, head, palette, ratio, silhouette, or overlays unless explicitly requested.
- A new output does not automatically replace the Authoritative Master.

## 7. Reporting format for each asset step

Use this chat structure for 산출물 보고형:

### 현재 단계
What was done and why.

### 작업 기준
- Authoritative Master
- source/base
- canvas/resolution
- locked parts
- exact scope
- ImageGen used? yes/no

### 실제 산출물
For each file:
- filename
- role
- what to inspect
- whether it is Intermediate / QA / LOCK candidate / Final

### QA 결과
Only claim what was actually verified.
Examples:
- 2048 full-canvas confirmed
- overlay alignment confirmed
- recomposite pixel diff
- residual outline check
- hidden-underlap reveal check

Do **not** say “맞다/완료/LOCK 가능” merely because a recomposite returns 0px diff. That only proves reconstruction of the selected base, not semantic correctness.

### 다음 단계
One next gate only.

## 8. Artifact accumulation rule

During a part:
- Show only artifacts needed for the current gate.
- Do not repeatedly dump all prior files.

When the part finishes:
- Provide the final set:
  - canonical asset
  - mask
  - removed remainder
  - ownership QA
  - recomposite QA
  - manifest
  - optional review crop
- Then register final approved state to GitHub / Notion / Drive as appropriate.

## 9. Status vocabulary

- Authoritative Master: current source of truth
- Intermediate: working output, not approved
- QA Candidate: ready for review
- LOCK Candidate: technically complete and awaiting explicit user approval
- Final / Locked: user explicitly approved

Never promote automatically.

## 10. Sea Turtle-specific immediate application

For Sea Turtle v3:
- Authoritative Master: Q3 canonical master
- Front Near/Far: moving parts
- Belly: fixed base surface with hidden underlap beneath front flippers
- Belly workflow must be:
  approved front-flippers-removed base → ownership overlay → approval → mask → asset → remainder → recomposite/residual QA → LOCK
- body_with_rear workflow must follow the same gate sequence.
- Shell/Belly/Front Flippers remain locked while body_with_rear is being processed unless separately requested.


## 11. Production-system reference

The reusable end-to-end method for complex illustrated raster Parts is documented in:
- `docs/illustrated-raster-part-production-system.md`

Key additions now treated as standard:
- semantic ownership is approved before technical mask extraction;
- extraction and missing-pixel reconstruction are separate workflows;
- material source-pixel ownership uses Base/Albedo + Pattern/Detail + Shadow + Highlight + Outline;
- QA is split into Ownership QA, Technical QA, and Production QA;
- Base/Albedo is derived last as the remainder of approved material ownership;
- an approved gate is saved immediately before proceeding to the next gate;
- final Part closeout requires gap/overlap/recomposition/PNG/runtime-size checks and a registered manifest.
