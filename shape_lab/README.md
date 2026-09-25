# MY LOCK Crayon Soft Shape Lab

Production renderer를 그대로 사용해 Crayon Soft 후보를 실제 58×58로 비교합니다.

## Round 11 — P01 Internal Fill

- 외곽 기준: P01 Clean Edge 고정
- 변경 영역: 내부 coverage / dropout / broken stroke / pressure / grain
- 후보: F01 Baseline, F02 Light Gap, F03 Dry Wax, F04 Scribble Fill, F05 Half-Filled, F06 Layered Patch
- 우선 관찰: F02 / F03 / F06
- 후보는 PNG/SVG가 아니라 동일 `LockTokenPainter + ShapeSpecRenderer`에 다른 `CrayonTextureSpec` preset을 주입
- Production `assets/shape_specs/crayon_soft/style.json`은 최종 승인 전 변경하지 않음

## 승인 흐름

Candidate → Shortlist → Selected → APP EXACT / Runtime QA → Production Master
