enum SoftBasicCandidateState {
  candidate,
  shortlist,
  selected,
  partiallyAdopted,
  rejected,
  hold,
}

enum SoftBasicCircleFinishTechnique {
  outlineBase,
  softInnerRim,
  colorShell,
  lowerRim,
  cleanOutline,
  premiumRim,
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

const softBasicCircleRound8Candidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-C-R8-01',
    name: 'Outline Base',
    intent: '선택된 R7-01 Edge Leaf를 유지하고 외곽선 보강 없이 보는 기준안.',
    state: SoftBasicCandidateState.shortlist,
    finishTechnique: SoftBasicCircleFinishTechnique.outlineBase,
    badge: 'BASE',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R8-02',
    name: 'Soft Inner Rim',
    intent: '도형 안쪽에 넓고 부드러운 밝은 림을 넣어 외곽 두께감을 만드는 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.softInnerRim,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R8-03',
    name: 'Color Shell',
    intent: 'Base Hue에서 파생한 컬러 외곽선으로 실루엣을 또렷하게 잡는 안.',
    state: SoftBasicCandidateState.selected,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    badge: 'SELECTED',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R8-04',
    name: 'Lower Rim',
    intent: '우하단 외곽 일부에만 도톰한 림을 넣어 전체 선 느낌 없이 형태를 받치는 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.lowerRim,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R8-05',
    name: 'Clean Outline',
    intent: '전체 외곽을 가장 얇고 정돈된 컬러 라인으로 감싼 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.cleanOutline,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R8-06',
    name: 'Premium Rim',
    intent: '약한 컬러 Shell과 부드러운 Inner Rim을 함께 써 도톰하지만 선처럼 보이지 않게 정리한 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.premiumRim,
    badge: 'TARGET',
  ),
];
