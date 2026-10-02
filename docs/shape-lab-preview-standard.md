# Shape Lab preview standard

MY LOCK Shape Lab uses three access layers so development does not stop when a
single preview host has a DNS or deployment problem.

## Access order

1. **Primary — Cloudflare Pages**
   - https://my-lock-shape-lab-pages.pages.dev/
   - This is the URL used for normal review and candidate comparison.
2. **Backup — Cloudflare Worker**
   - https://my-lock-shape-lab.rlatkd5959.workers.dev/
   - Use only when the Pages deployment is unavailable.
3. **Recovery — GitHub Actions artifact**
   - Workflow: `MY LOCK Shared Shape Lab`
   - Artifact: `my-lock-crayon-shape-lab`
   - Retention: 14 days.

## Deployment rule

A push to `feat/lab-runtime-workbench` or `feat/style-lab-integration` that changes ShapeSpec, Shape Lab, or build
configuration performs the following sequence:

1. validate ShapeSpec mask assets;
2. run ShapeSpec tests;
3. build the Flutter Shape Lab once;
4. upload the exact build as a recovery artifact;
5. deploy and verify Cloudflare Pages;
6. deploy and verify the Worker as a non-blocking backup.

The Worker is intentionally non-blocking. A `workers.dev` DNS problem must
not mark the Shape Lab release as failed when the Pages primary is healthy.

## Review rule

All Crayon Soft candidate decisions are made from the live Shape Lab renderer,
not from manually generated screenshots. Candidate cards use the same
`LockTokenPainter` and `ShapeSpecRenderer` as the app. Screenshots are only
records of a review result.

## Failure handling

- Pages works, Worker fails: continue review on Pages.
- Pages fails: treat the workflow as failed and inspect the deployment log.
- Both public hosts are inaccessible: download the GitHub Actions artifact and
  serve `build/shape_lab` locally.

## Main / Lab 운영 원칙 — 2026-10-02

- Main: https://my-lock-preview.rlatkd5959.workers.dev/ — 승인되어 적용된 앱 확인.
- Lab: https://my-lock-shape-lab-pages.pages.dev/ — 후보 비교 및 QA. 앞으로 실험마다 새 호스트를 만들지 않는다.
- 공통 검수: https://my-lock-shape-lab-pages.pages.dev/?lab=review&experiment=candy-soft
- Main 반영과 Candidate → Final / Locked 승격은 별도 사용자 승인 이후 진행한다.

## 재사용 검수 서식

`shape_lab/runtime_workbench.dart`는 앱의 `LockTokenPainter`, `ShapeChoiceCard`, `FloatingPreview`를 재사용한다.
표시 크기, Light/Dark, 실제 카드, 6/9/12개 Floating 및 POP/재생성을 동일 화면에서 비교한다.
기존 Shape / Style / Palette / Effect / Runtime QA 탭은 유지한다. 후보 렌더링은 공통 검수 화면이 열린 동안만 활성화한다.

다음 실험은 `assets/lab/experiments.json`에 항목을 등록한다:
`id`, `title`, `category`, `status`, `profile`, `source_commit`, `sizes`, `object_counts`, `variants`, `pending`.
`profile`은 기존 앱 렌더러 `production` 또는 현재 후보 `candy-soft`이다. 새 렌더러가 필요한 경우 프로필 어댑터만 추가하고 화면/호스트는 재사용한다.
에셋은 소스 그대로 별도 경로에 보관한다. 기존 승인 Master를 덮어쓰지 않는다.

운영 순서: 원본/스펙 최신 확인 → 에셋/프로필 및 실험 등록 → CI 테스트/빌드 → 기존 Lab 배포 → 동일 검수 서식으로 실제 확인 → 검수 기록 → 사용자 승인 → Main 적용.
딥링크는 실험 ID를 유지한다. 각 항목에 Source commit과 Candidate 상태, 미완료 QA를 표시한다.
웹 검수만으로 Android LockActivity / lockMain 실기기 검증을 완료 처리하지 않는다.
