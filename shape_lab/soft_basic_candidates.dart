enum SoftBasicCandidateState {
  candidate,
  shortlist,
  selected,
  partiallyAdopted,
  rejected,
  hold,
}

enum SoftBasicCircleFinishTechnique {
  baseHold,
  longTaper,
  softBelly,
  innerFade,
  flattenedTop,
  refinedEdgeLeaf,
}

class SoftBasicCandidate {
  const SoftBasicCandidate({
    required this.id,
    required this.name,
    required this.intent,
    required this.state,
    required this.finishTechnique,
    this.badge,
  });

  final String id;
  final String name;
  final String intent;
  final SoftBasicCandidateState state;
  final SoftBasicCircleFinishTechnique finishTechnique;
  final String? badge;
}

const softBasicCircleRound7Candidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-C-R7-01',
    name: 'Base Hold',
    intent: 'Round 6에서 가장 나았던 Edge Leaf Base를 그대로 유지한 기준안.',
    state: SoftBasicCandidateState.shortlist,
    finishTechnique: SoftBasicCircleFinishTechnique.baseHold,
    badge: 'BASE',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R7-02',
    name: 'Long Taper',
    intent: '하이라이트 끝을 더 길고 가늘게 빼서 흐름을 유려하게 만든 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.longTaper,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R7-03',
    name: 'Soft Belly',
    intent: '중앙 폭을 살짝 키워 흰 선보다 부드러운 면광으로 읽히게 만든 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.softBelly,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R7-04',
    name: 'Inner Fade',
    intent: '외곽 형태는 유지하고 안쪽으로 밝기가 자연스럽게 사라지는 페이드형.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.innerFade,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R7-05',
    name: 'Flattened Top',
    intent: '상단 시작부를 눌러 더 차분하고 덜 인위적인 하이라이트로 정리한 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.flattenedTop,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R7-06',
    name: 'Refined Edge Leaf',
    intent: 'Base Hold의 장점을 유지하면서 길이·폭·곡률·페이드를 균형 있게 정리한 최종 후보.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.refinedEdgeLeaf,
    badge: 'TARGET',
  ),
];
