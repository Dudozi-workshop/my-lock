enum SoftBasicCandidateState {
  candidate,
  shortlist,
  selected,
  partiallyAdopted,
  rejected,
  hold,
}

enum SoftBasicCircleHighlightTechnique {
  airbrushReference,
  leafPath,
  featheredCapsule,
  stackedSingleLobe,
  paintedBrush,
  edgeMeltedLobe,
  targetLobe,
}

class SoftBasicCandidate {
  const SoftBasicCandidate({
    required this.id,
    required this.name,
    required this.intent,
    required this.state,
    required this.highlightTechnique,
    this.badge,
  });

  final String id;
  final String name;
  final String intent;
  final SoftBasicCandidateState state;
  final SoftBasicCircleHighlightTechnique highlightTechnique;
  final String? badge;
}

const softBasicCircleRound4Candidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-C-R4-01',
    name: 'Airbrush Reference',
    intent: 'R3-02의 전체 볼륨 구성을 기준으로 고정한 비교 기준안.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.airbrushReference,
    badge: 'BASE',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R4-02',
    name: 'Soft Leaf Path',
    intent: '목업처럼 길고 살짝 휘어진 Leaf형 Path를 하나의 연속 하이라이트로 사용.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.leafPath,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R4-03',
    name: 'Feathered Capsule',
    intent: '긴 Capsule 외곽을 강하게 흐려 면광처럼 녹이는 방식. 별도 점광 없음.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.featheredCapsule,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R4-04',
    name: 'Layered Lobe',
    intent: '하나의 Lobe를 Blur층과 밝은 내부층으로 겹쳐 단일 하이라이트 안에서 깊이를 표현.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.stackedSingleLobe,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R4-05',
    name: 'Painted Brush',
    intent: '붓으로 한 번 쓸어낸 듯한 비대칭 곡면 Path로 자연스러운 광택 형태를 탐색.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.paintedBrush,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R4-06',
    name: 'Edge Melt',
    intent: '하이라이트 경계 일부를 Diffuse Light에 녹여 흰 스티커처럼 보이지 않게 만드는 방식.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.edgeMeltedLobe,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R4-07',
    name: 'Mockup Lobe',
    intent: '목표 목업의 길이·곡률·부드러운 경계를 가장 직접적으로 재현한 단일 Lobe.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.targetLobe,
    badge: 'TARGET',
  ),
];
