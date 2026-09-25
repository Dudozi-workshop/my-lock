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

enum SoftBasicBottomHighlightTechnique {
  none,
  softBloom,
  narrowBloom,
  crescent,
  liftedGlow,
  premiumBottom,
}

enum SoftBasicLowerVolumeTechnique {
  none,
  tintedBloom,
  embeddedLight,
  liftGradient,
  shadowCarve,
  ambientBounce,
  ambientBounceStrong,
  ambientBounceWide,
  ambientBounceContrast,
  ambientBounceAsymmetric,
  ambientBounceCarved,
}

class SoftBasicCandidate {
  const SoftBasicCandidate({
    required this.id,
    required this.name,
    required this.intent,
    required this.state,
    required this.finishTechnique,
    this.bottomHighlightTechnique = SoftBasicBottomHighlightTechnique.none,
    this.lowerVolumeTechnique = SoftBasicLowerVolumeTechnique.none,
    this.badge,
  });

  final String id;
  final String name;
  final String intent;
  final SoftBasicCandidateState state;
  final SoftBasicCircleFinishTechnique finishTechnique;
  final SoftBasicBottomHighlightTechnique bottomHighlightTechnique;
  final SoftBasicLowerVolumeTechnique lowerVolumeTechnique;
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


const softBasicCircleRound9Candidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-C-R9-01',
    name: 'Base',
    intent: 'R8-03 Color Shell + R7-01 상단 하이라이트만 유지한 하단 무처리 기준안.',
    state: SoftBasicCandidateState.shortlist,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    bottomHighlightTechnique: SoftBasicBottomHighlightTechnique.none,
    badge: 'BASE',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R9-02',
    name: 'Soft Bloom',
    intent: '하단 안쪽에 넓고 흐린 빛 번짐을 넣어 말랑한 볼륨을 받치는 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    bottomHighlightTechnique: SoftBasicBottomHighlightTechnique.softBloom,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R9-03',
    name: 'Narrow Bloom',
    intent: '하단 중심부에 폭이 좁고 선명한 밝기를 넣어 형태를 가볍게 들어 올리는 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    bottomHighlightTechnique: SoftBasicBottomHighlightTechnique.narrowBloom,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R9-04',
    name: 'Crescent',
    intent: '하단 곡률을 따라 짧은 초승달형 하이라이트를 배치해 입체감을 강조한 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    bottomHighlightTechnique: SoftBasicBottomHighlightTechnique.crescent,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R9-05',
    name: 'Lifted Glow',
    intent: '외곽선에서 살짝 띄운 내부 광점을 두어 둥근 표면이 떠 보이게 만드는 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    bottomHighlightTechnique: SoftBasicBottomHighlightTechnique.liftedGlow,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R9-06',
    name: 'Premium Bottom',
    intent: '넓은 Bloom과 얇은 코어 하이라이트를 겹쳐 과하지 않게 깊이를 만드는 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    bottomHighlightTechnique: SoftBasicBottomHighlightTechnique.premiumBottom,
    badge: 'TARGET',
  ),
];


const softBasicCircleRound10Candidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-C-R10-01',
    name: 'Clean Base',
    intent: 'R8-03 Color Shell + R7-01 상단 하이라이트만 유지한 기준안. 하단 추가광 없음.',
    state: SoftBasicCandidateState.shortlist,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.none,
    badge: 'BASE',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R10-02',
    name: 'Tinted Bloom',
    intent: 'R9-02의 장점만 남겨 흰 선 없이 현재 색상의 밝은 톤이 하단 안쪽에서 넓게 번지는 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.tintedBloom,
    badge: 'R9-02 REWORK',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R10-03',
    name: 'Embedded Light',
    intent: '별도 하이라이트 경계 없이 표면 내부 밝기만 미세하게 올려 빛이 재질 안에 녹아든 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.embeddedLight,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R10-04',
    name: 'Bottom Lift Gradient',
    intent: '하단으로 갈수록 같은 색 계열의 밝기가 서서히 되살아나는 그라디언트 기반 볼륨안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.liftGradient,
    badge: 'CORE',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R10-05',
    name: 'Shadow Carving',
    intent: '새 빛을 그리지 않고 우하단의 기존 깊은 음영만 완화해 하단이 자연스럽게 떠 보이게 한 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.shadowCarve,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R10-06',
    name: 'Ambient Bounce',
    intent: '레퍼런스의 Diffuse Light처럼 하단에 넓은 색 반사광을 넣어 부드러운 2D 볼륨을 만드는 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.ambientBounce,
    badge: 'REF',
  ),
];


const softBasicCircleRound11Candidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-C-R11-01',
    name: 'Ambient Base',
    intent: 'R10-06 Ambient Bounce 그대로. Round 11 체감 강화 비교의 기준안.',
    state: SoftBasicCandidateState.selected,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.ambientBounce,
    badge: 'SELECTED',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R11-02',
    name: 'Bounce +25%',
    intent: '위치와 범위는 유지하고 색상 기반 반사광의 강도만 약 25% 높인 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.ambientBounceStrong,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R11-03',
    name: 'Wide Bounce',
    intent: '하단 반사광 범위를 넓혀 58px에서도 볼륨 변화가 더 쉽게 읽히도록 한 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.ambientBounceWide,
    badge: 'WIDE',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R11-04',
    name: 'Color Contrast',
    intent: '흰색 없이 현재 색상의 밝은 톤 대비만 강화해 반사광을 명확하게 만든 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.ambientBounceContrast,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R11-05',
    name: 'Asymmetric Bounce',
    intent: '반사광 중심을 살짝 좌측으로 이동해 균일한 띠 대신 자연스러운 비대칭 볼륨을 만든 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.ambientBounceAsymmetric,
  ),
  SoftBasicCandidate(
    id: 'SB-C-R11-06',
    name: 'Bounce + Carve',
    intent: '넓은 반사광과 우하단 음영 완화를 함께 적용해 선을 추가하지 않고 체감 볼륨을 키운 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    lowerVolumeTechnique: SoftBasicLowerVolumeTechnique.ambientBounceCarved,
  ),
];
