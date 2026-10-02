# MY LOCK Lab 제작·검수·마감 체계 v1

상태: 개발 이력에 근거한 설계안. Lab UI 적용·새 빌드·배포는 아직 진행하지 않았다.
이 문서는 메뉴 정리안보다 상위의 작업 흐름이다. 기존 main 및 Lab 링크를 유지한다.

## 목적과 근거

작업 하나를 등록하면 제작, 동일 조건 비교, 필요한 검수, 사용자 승인, Main 반영, 마감 기록까지 같은 틀에서 이어진다.
검수 항목은 변경 범위에 따라 선택한다. 모든 작업에 모든 Android 검사를 반복하지 않는다.

근거:
- Notion 03. 개발 이력 · 결정 · 실험 로그: 실제 renderer와 목업의 차이, canonical trace drift, 승인 전 production 반영 후 revert, Shared Renderer 도입, Overlay 통합 및 기기 안정성 이력.
- Notion 04. 다음 작업 및 검증 항목: 실제 58px / Light·Dark / 6·9·12개 / Floating 및 잠금 Overlay, 재부팅·업데이트·권한 복구, Source 변경 후 재검수.
- 최신 06. Shape 제작 가이드 / Drop 01 Asset Master: Locked Master와 Runtime Derived 경계, Runtime v3 / Swim v1 현재 승인 상태.
- 현재 대화의 앱 장애: 이미지 decompression 실패, 선택한 기본 도형/Crayon의 배포 누락, APK 다운로드 및 빌드 확인.
- 현황 조사: docs/lab-cleanup-audit-20261003.md.

과거 문서는 당시 문제의 근거로 사용한다. 현재 활성 경로·승인 상태는 최신 Notion과 GitHub main에서 확인한다.
과거 LockActivity/Overlay 또는 Material 기획을 현재 사실로 자동 승격하지 않는다.

## 공통 작업 순서

| 단계 | 할 일 | 다음 단계로 넘어가는 근거 |
|---|---|---|
| 1. 시작 확인 | 작업 종류·목표·변경 허용 범위, 최신 Source와 기준본, 승인 상태, 필요한 검수 선택 | Source 충돌 없음; 결정할 질문과 완료 조건 기록 |
| 2. 제작 | 기존 Lab의 공통 renderer/설정으로 후보 제작, 후보 ID 및 source hash 기록 | 후보가 실제 로드·렌더 가능; Main에는 미승인 후보 미적용 |
| 3. 비교·선별 | 기준본+후보를 같은 크기·색·배경·배치로 비교; 선별 후 국소 수정 | 선택 후보 및 이유 기록; 반복 라운드는 같은 작업에 누적 |
| 4. 구현 검수 | 실제 production component와 해당 변경의 기술·동작·기기 검수 | 필수 항목에 결과/근거 연결; 실패 항목 해결 또는 명시적인 제외 결정 |
| 5. 승인·반영 | 사용자 승인 대상과 Source를 연결; 승인 후보만 Main 반영; 동일 source로 빌드·배포 | 승인 기록 및 반영 commit; 웹/APK의 실제 버전·후보 포함 여부 확인 |
| 6. 마감 | Main 스모크 검수, 결과/남은 한계/링크 및 Notion 갱신, 활성 후보 정리 | 승인본=Main 반영본=배포본 확인; 다음 작업·미확인 기기 항목 명시 |

사용자 승인 전에 Final / Locked로 승격하지 않는다.
이미 승인된 Master를 다시 승인 대기 상태로 바꾸지 않는다. 새로운 변경 범위만 승인 대상으로 지정한다.
실기기 필수 항목이 남으면 Device QA Pending으로 표시하며 전체 검수 완료로 보고하지 않는다.
기기 증거를 자동 생성하거나 Web 확인으로 기기 통과를 대신하지 않는다.

## 공통 검수와 조건부 검수

| 작업 종류 | 공통으로 확인할 것 | 변경 범위가 있을 때 추가 |
|---|---|---|
| 모든 시각 작업 | Source/후보 추적, 실제 renderer, 실제 사용 크기·Light/Dark, 지원 조합, 관련 analyze/test/build, 배포 버전 | Main 반영 후 같은 후보가 실제 활성인지 |
| Shape / Style / Raster Runtime | 58px 가독성·크기 균형, ShapeChoiceCard·FloatingPreview, 지원 색, 외곽·음영·디테일 유지 | Raster: 파일 실제 decode·alpha·padding·rotation/pop crop; Part 변경: seam/occlusion/ownership; 최종 runtime: 실제 잠금 화면 |
| Palette | 실제 Shape별 색 정체성 및 finish 보존 | Animated: 여러 시간 프레임, alpha 밖 누출 없음, finish 고정; 필요 시 실제 기기 성능 |
| Motion / Effect | Floating 및 실제 잠금 경로, 6/9/12개, 반복 spawn, rotation, 충돌/터치/pop | 다중 위상·속도 차이, pause/resume·화면 전환·FPS; 센서 변경 시 실기기 센서 |
| Background | 승인 Shape를 고정한 동일 조건 비교, 텍스트·Shape 가독성, Light/Dark | 시간 변화, 화면비·회전·edge/inset; 이미지 재생성으로 Shape를 바꾸지 않음 |
| 잠금 / Android 엔진 | 실제 기기 설치·인증·PIN·보호 앱 전환·화면 OFF/ON | 관련 변경 시 재부팅/업데이트/권한 해제·복구/서비스 생존/회전/시스템 UI/센서 |
| Lab 도구·기록만 변경 | 작업 진입·프로필 전환·기존 링크·lifecycle 및 Web build/version | 사용하지 않는 엔진 기능 전체 기기 QA를 자동 요구하지 않음 |

필수 항목은 Pass / Fail / Pending / N/A로 기록한다.
N/A에는 이유를 남긴다. 자동 테스트, 브라우저 확인, 실기기 확인, 사용자 시각 승인은 서로 다른 근거이다.
검수 후 Source 또는 renderer가 바뀌면 영향을 받은 항목만 Pending으로 되돌린다.
승인은 후보 ID + Source hash에 묶는다. 이후 후보가 변경되면 예전 승인을 새 후보에 적용하지 않는다.

## 작업 카드와 재사용 화면

작업 카드 하나에 다음 정보를 연결한다.
- 작업 ID·유형·목표, 변경 허용 범위 / 잠금 범위
- 기준본·후보 ID, Source 위치·hash·commit, renderer profile
- 현재 단계, 선택 결과·이유, 승인 범위·기록
- 필요한 검수 preset 및 결과: 항목/상태/검수한 Source/환경/시각/증거
- 웹·APK: build commit, 포함된 후보, 확인 링크
- 남은 문제·다음 행동·마감 기록

초기 UI는 작업 목록 → 작업 상세의 제작/비교/검수/마감 순서로 구성한다.
진행 중·현재 기준·종료 기록을 구분한다. 각 단계마다 새로운 페이지나 호스트를 만들지 않는다.
기존 RuntimeWorkbench 및 experiments.json을 확장하고 실제 production components를 재사용한다.
검수 preset은 Shape / Palette / Motion / Background / Android에서 고르며 작업별 추가·제외 이유를 허용한다.
데이터베이스·권한 시스템·대형 자동화 엔진은 초기 구축 범위에 넣지 않는다.

## 배포와 기기 확인 규칙

- 같은 기존 Main/Lab 링크를 유지하고 실험별 deep link를 사용한다.
- HTTP 200이나 CI 성공만으로 최신 배포 확인을 완료하지 않는다. version.json/build commit을 비교한다.
- APK는 링크뿐 아니라 다운로드 가능 여부·빌드 commit·포함 후보를 표시한다.
- Production APK에 없는 Lab 후보는 '이 APK에서 검수 불가'로 표시한다.
- 실제 디코딩/Bootstrap 확인 및 packaged asset hash로 파일 전달 문제를 확인한다.
- 실제 잠금 QA는 최신 main의 활성 production 진입 경로를 확인한 뒤 수행한다. 별도 Android entrypoint에 영향이 있으면 그 경로도 따로 기록한다.
- 기기 기록: 모델/OS, APK commit, 재현 단계, 결과 및 필요 시 영상/스크린샷.
- known limitation과 이번 변경 회귀를 구분하고 미확인 항목을 숨기지 않는다.

## 레거시 정리 위치

정리는 이 제작 흐름을 구축하면서 진행한다.
1. 승인본·활성 실험·과거 기록의 Source 연결.
2. 기존 비교/QA 기능을 공통 화면으로 이관.
3. 호출되지 않는 후보 목록과 중복 painter 제거.
4. Git 이력과 선택 이유를 남기고 과거 화면을 기본 진입에서 제외.

Crayon R3-04의 과거 승인 기록이 존재하므로 현재 C08 등의 표기와 실제 활성 style.json을 대조한 뒤 정리한다.
옛 라운드에 대한 사용자의 승인과 현재 사용 여부를 임의로 추정하지 않는다.
Locked 원본 및 production Master 삭제는 레거시 화면 정리와 별개이며 이 작업에 포함하지 않는다.

## 구축 순서

1. 작업 카드·단계·검수 preset·Source 연결 구조 확정.
2. Candy Soft 기본 도형을 첫 활성 샘플로, Locked Sea Turtle를 기준본 샘플로 연결.
3. 기존 비교 화면과 공통 Workbench를 새 흐름에 연결.
4. 필요한 기기 검수 및 승인·배포·마감 근거 입력 기능 연결.
5. 역할이 이관된 레거시 정리 후 기존 Lab 링크에 검증 배포.

첫 샘플이 시작부터 마감까지 실제로 통과하는지 검증한 후 다른 콘텐츠에 확장한다.
