# MY LOCK Lab 정리안 v1 — 2026-10-03 KST

상태: 현황 조사 완료 / 정리 제안. UI 재구성·코드 제거·배포는 아직 진행하지 않음.

## 조사 기준

- Lab 소스: 0ea67d467df58a429f4d19ba905c25752c655420, feat/lab-runtime-workbench.
- main: f60f9c516ae8bfbc80bcf6a120bdf8f3bb91c5a9.
- Notion 06. Shape 제작 가이드 및 Drop 01 Asset Master 최신본 대조.
- 공개 Lab 루트 직접 확인: LAB036, 기본 진입은 Crayon C08 Style Lab, 6개 상위 탭.
- Source 및 문서 최신 상태: Sea Turtle Runtime v3 / Swim Motion v1은 사용자 승인 후 Final / Locked / Active. 기존 Static Split 화면의 “모션 구현 금지 / F0만 유지” 문구는 과거 단계의 설명이다.
- 이 조사에서 Master, Geometry, Material, Ownership, Runtime 및 승인 상태를 변경하지 않음.

## 구체적 정리 대상

| 현재 항목 | 처리 제안 | 근거 / 남길 것 |
|---|---|---|
| 루트 진입 시 Crayon C08 후보 화면 | 작업 목록으로 교체 | 현재 진행 중 실험과 기준본을 먼저 찾게 함 |
| 공통 RuntimeWorkbench | 유지·확장 | 실제 LockTokenPainter / ShapeChoiceCard / FloatingPreview 재사용 |
| Shape / Style / Palette 상위 탭 | 분류 및 실험별 비교 화면으로 통합 | 모든 후보에 같은 표시 조건 적용. 재질 상품 기획 변경은 별도 |
| Effect Lab / Runtime QA / Workbench motion | 공통 앱 검수로 통합 | 모두 FloatingPreview 사용. 기존 movement / pop / style / 6·9·12 옵션 보존 |
| PaletteLab 3색 원 중심 화면 | 실험별 색 조합 검수로 통합 | shape+tone variants 활용. 지원하지 않는 조합은 미지원 표시 |
| Circle Round9N / Square Round5 / Triangle Direction1 후보 화면 | 기록으로 분리 | 선택 ID·이유·Source와 현재 기준본만 보존. Candy Soft 방향으로 기본 도형 검수 진행 |
| Crayon C08 A~D | 현황 확인 후 분리 | 현재 기준과 미선택 변형을 구분. 이번 조사만으로 과거 승인/종료 상태를 임의 변경하지 않음 |
| Sea Turtle Static Split / F0 전용 화면 | 과거 Gate 기록으로 이동 | 최신 Whole / Runtime v3 / Swim v1 검수 진입 유지. 과거 설명을 현재 제한으로 보이지 않게 함 |
| Sea Turtle Crayon 전용 painter 2종 | 보관 후 활성 검수에서 제거 | 기존 PNG 기반 Lab 전용 렌더러. 최신 production 경로와 별개 |
| Core Master 비교 | 현재 기준 화면으로 유지 | 승인된 Geometry 및 Source 보존 |
| 공통 화면의 고정 APK URL | 다운로드 안내 분리 | 선택 실험과 관계없이 정식 APK 링크. 후보가 APK에 포함됐다고 오해하지 않게 빌드/포함 여부 명시 |
| 기본 후보 목록 9개 | 활성 코드 제거 대상 | 선언 외 참조 없음. Git 이력과 승인 결과를 먼저 연결해 보존 |
| shape_lab/main.dart 약 6천 줄 | 역할별 파일로 분리 | 공통 화면 / 후보 프로필 / 기록 화면이 한 파일에 혼재 |

## 선언 외 참조 없는 후보 목록

shape_lab, lib, test, tool의 추적 소스를 git grep으로 확인했다. 아직 삭제하지 않았다.

- softBasicCircleRound8Candidates
- softBasicCircleRound9Candidates
- softBasicCircleRound10Candidates
- softBasicCircleRound11Candidates
- softBasicSquareRound1Candidates
- softBasicSquareRound2Candidates
- softBasicSquareRound3Candidates
- softBasicSquareRound4Candidates
- softBasicTriangleGeometryRound1Candidates

현재 참조되는 목록은 Circle Round9Natural, Square Round5, Triangle Final이다.
미참조는 파일 크기/실행 비용 개선량을 의미하지 않는다. Dart tree shaking 가능성을 고려해 소스 유지관리 정리를 목적으로 한다.
과거 승인된 Circle/Square Geometry의 생산용 master는 별도 경로에 있으므로 후보 상수 제거와 Master 제거를 혼동하지 않는다.

## 제안하는 사용자 화면

1. 작업 목록: 진행 중 / 현재 기준. 종료 기록은 보조 진입.
2. 후보 비교: 현재 기준 + 후보를 동일 크기·색·배경·배치로 나란히 표시.
3. 앱 검수: 실제 카드, Floating, rotation, movement, pop, 개수, Light/Dark.
4. 기록: 선택 결과·이유·Source 위치. 모든 라운드 이미지·코드를 중복 복사하지 않음.

Shape / Palette / Motion / Background는 작업 분류로 사용한다.
각 분류마다 새 호스트·새 QA 페이지를 만들지 않고 프로필 어댑터 + 설정으로 공통 화면을 재사용한다.
Background 비교는 실제 승인 Shape를 동일 조건으로 후합성/표시하는 기존 규칙을 따른다.

## 실험별 최소 정보

- 결정할 질문
- 현재 기준과 후보 ID
- Source commit / 원본 위치
- 지원 shape+tone / 표시 옵션
- 선택 결과와 이유
- 남은 검수

Source 승인 상태와 검수 상태는 분리한다. 예: Locked Master라도 특정 기기 QA는 Pending일 수 있다.
웹 검수와 Android LockActivity / lockMain 실기기 검수도 분리한다.
현재 registry의 status 문자열을 곧바로 전부 변경하기보다 필요한 화면부터 두 상태를 명확히 표시한다.

## 적용 순서와 완료 기준

1. 루트 작업 목록과 진행 중/기준/기록 분리.
2. Effect / Runtime QA 옵션을 Workbench 앱 검수로 이관.
3. 옛 라운드와 Sea Turtle 전용 실험을 기록으로 분리하고 해당 과거 deep link는 기록 진입으로 연결.
4. 참조가 없는 후보 상수·중복 painter 제거, 파일 분리.
5. 같은 기존 Lab 링크에 배포 후 version.json commit 확인 및 실제 진입 QA.

각 단계에서 최신 Lab head를 다시 읽고 다른 작업의 변경을 보존한다.
CI: 기존 ShapeSpec / Workbench lifecycle / Raster v3 / Swim 회귀검사, Web build.
브라우저: Candy Soft와 baseline 전환, 확정 Sea Turtle Swim/Aurora, 실제 카드/Floating 및 기존 링크 재진입.
Main과 Locked Master는 수정 범위에 포함하지 않는다. 공개 Lab 변경은 위 검수가 끝난 후 완료로 기록한다.
