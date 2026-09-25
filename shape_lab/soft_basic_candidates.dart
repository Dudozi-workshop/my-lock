enum SoftBasicCandidateState {
  candidate,
  shortlist,
  selected,
  partiallyAdopted,
  rejected,
  hold,
}

enum SoftBasicCircleHighlightTechnique {
  mockupReference,
  longLeaf,
  taperedLeaf,
  curvedLeaf,
  broadSoftLeaf,
  edgeLeaf,
  refinedMockup,
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

const softBasicCircleRound5Candidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-C-R5-01',
    name: 'R4-07 Reference',
    intent: 'Round 4에서 가장 양호했던 Mockup Lobe를 그대로 유지한 기준안.',
    state: SoftBasicCandidateState.shortlist,
    highlightTechnique: SoftBasicCircleHighlightTechnique.mockupReference,
    badge: 'BASE',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R5-02',
    name: 'Long Leaf',
    intent: '목업처럼 세로 길이를 조금 더 확보하고 폭은 억제한 자연스러운 긴 Leaf형.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.longLeaf,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R5-03',
    name: 'Tapered Leaf',
    intent: '상·하단을 더 가늘게 테이퍼해 스티커 느낌을 줄이고 자연스러운 광면을 탐색.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.taperedLeaf,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R5-04',
    name: 'Curved Leaf',
    intent: '도형 곡률을 따라 안쪽으로 살짝 휘는 비대칭 Lobe. 2번 Leaf Path의 자연스러움을 참고.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.curvedLeaf,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R5-05',
    name: 'Broad Soft Leaf',
    intent: '폭은 약간 넓히되 경계를 더 부드럽게 녹여 인위적인 흰 덩어리 느낌을 줄인 안.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.broadSoftLeaf,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R5-06',
    name: 'Edge Leaf',
    intent: '좌상단 외곽에 조금 더 가까이 붙여 표면 반사광처럼 읽히게 한 안.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.edgeLeaf,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R5-07',
    name: 'Refined Mockup',
    intent: 'R4-07의 장점을 유지하면서 길이·테이퍼·경계 흐림을 목업 쪽으로 정리한 최종 후보.',
    state: SoftBasicCandidateState.candidate,
    highlightTechnique: SoftBasicCircleHighlightTechnique.refinedMockup,
    badge: 'TARGET',
  ),
];
