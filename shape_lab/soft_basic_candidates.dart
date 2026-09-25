enum SoftBasicCandidateState {
  candidate,
  shortlist,
  selected,
  partiallyAdopted,
  rejected,
  hold,
}

enum SoftBasicCircleTechnique {
  currentLayeredMask,
  airbrushMultiBlur,
  glossLobePath,
  dualRadialVolume,
  innerRimShell,
  meshBlend,
  softCandyEdge,
  bakedSpriteEmulation,
}

class SoftBasicCandidate {
  const SoftBasicCandidate({
    required this.id,
    required this.name,
    required this.intent,
    required this.state,
    required this.technique,
    this.badge,
  });

  final String id;
  final String name;
  final String intent;
  final SoftBasicCandidateState state;
  final SoftBasicCircleTechnique technique;
  final String? badge;
}

const softBasicCircleRound3Candidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-C-R3-01',
    name: 'Current Layered',
    intent: '현재 Production Mask Layer 합성 방식. 비교용 기준안.',
    state: SoftBasicCandidateState.candidate,
    technique: SoftBasicCircleTechnique.currentLayeredMask,
    badge: 'CURRENT',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R3-02',
    name: 'Airbrush Volume',
    intent: '큰 Blur Light/Shadow를 직접 겹쳐 면 전체를 부드럽게 조형하는 방식.',
    state: SoftBasicCandidateState.candidate,
    technique: SoftBasicCircleTechnique.airbrushMultiBlur,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R3-03',
    name: 'Gloss Lobe',
    intent: '목업의 길쭉한 광택을 Path로 직접 그리고 Base와 분리하는 방식.',
    state: SoftBasicCandidateState.candidate,
    technique: SoftBasicCircleTechnique.glossLobePath,
    badge: 'PATH',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R3-04',
    name: 'Dual Radial',
    intent: '좌상단 Light Radial과 우하단 Shadow Radial을 독립 합성해 깊이를 만드는 방식.',
    state: SoftBasicCandidateState.candidate,
    technique: SoftBasicCircleTechnique.dualRadialVolume,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R3-05',
    name: 'Inner Rim Shell',
    intent: '외곽 안쪽의 밝은 Shell/Rim과 내부 그라데이션으로 탱글한 외곽을 만드는 방식.',
    state: SoftBasicCandidateState.candidate,
    technique: SoftBasicCircleTechnique.innerRimShell,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R3-06',
    name: 'Mesh Blend',
    intent: '여러 컬러 Blob을 Blur 합성해 Gradient Mesh처럼 풍부한 면색을 만드는 방식.',
    state: SoftBasicCandidateState.candidate,
    technique: SoftBasicCircleTechnique.meshBlend,
    badge: 'MESH',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R3-07',
    name: 'Soft Candy Edge',
    intent: '강한 하단 Edge와 넓은 Gloss를 조합해 목업의 캔디형 볼륨을 직접 노리는 방식.',
    state: SoftBasicCandidateState.candidate,
    technique: SoftBasicCircleTechnique.softCandyEdge,
    badge: 'TARGET',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R3-08',
    name: 'Baked-look',
    intent: '여러 Blur/Spec 레이어를 한 번에 굽는 스프라이트 같은 결과를 Canvas로 재현하는 방식.',
    state: SoftBasicCandidateState.candidate,
    technique: SoftBasicCircleTechnique.bakedSpriteEmulation,
  ),
];
