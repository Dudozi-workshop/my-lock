enum SoftBasicCandidateState {
  candidate,
  shortlist,
  selected,
  partiallyAdopted,
  rejected,
  hold,
}

enum SoftBasicCircleFinishTechnique {
  edgeLeafReference,
  bottomBloom,
  innerRimShell,
  crescentBounce,
  dualRim,
  mockupPush,
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

const softBasicCircleRound6Candidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-C-R6-01',
    name: 'Edge Leaf Base',
    intent: '선택된 R5-06 Edge Leaf를 그대로 유지한 비교 기준안.',
    state: SoftBasicCandidateState.selected,
    finishTechnique: SoftBasicCircleFinishTechnique.edgeLeafReference,
    badge: 'SELECTED',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R6-02',
    name: 'Bottom Bloom',
    intent: '4~6시 방향에 넓은 확산광을 넣어 목업의 아래쪽 빛 번짐을 직접 추가.',
    state: SoftBasicCandidateState.rejected,
    finishTechnique: SoftBasicCircleFinishTechnique.bottomBloom,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R6-03',
    name: 'Inner Rim Shell',
    intent: '외곽 안쪽에 도톰한 밝은 Shell을 만들어 테두리 자체의 존재감을 키운 방식.',
    state: SoftBasicCandidateState.rejected,
    finishTechnique: SoftBasicCircleFinishTechnique.innerRimShell,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R6-04',
    name: 'Crescent Bounce',
    intent: '하단을 따라 휘는 초승달형 반사광으로 점광 없이 아래쪽 볼륨을 살린 방식.',
    state: SoftBasicCandidateState.rejected,
    finishTechnique: SoftBasicCircleFinishTechnique.crescentBounce,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R6-05',
    name: 'Dual Rim',
    intent: '색상 외곽선 + 밝은 하단 Inner Rim을 분리해 실루엣을 더 또렷하게 잡는 방식.',
    state: SoftBasicCandidateState.rejected,
    finishTechnique: SoftBasicCircleFinishTechnique.dualRim,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R6-06',
    name: 'Mockup Push',
    intent: '하단 확산광 + 도톰한 컬러 림 + 밝은 하단 림을 함께 써 목표 목업에 가장 직접적으로 접근.',
    state: SoftBasicCandidateState.rejected,
    finishTechnique: SoftBasicCircleFinishTechnique.mockupPush,
    badge: 'TARGET',
  ),
];
