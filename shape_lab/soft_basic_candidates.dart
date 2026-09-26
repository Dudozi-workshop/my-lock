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
  sideKiss,
  softSpot,
  edgeFade,
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


const softBasicCircleRound9NaturalCandidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-C-R9N-01',
    name: 'Side Kiss',
    intent: '하단 전체를 따라가지 않고 우하단 한쪽에만 짧은 색상광을 얹어 작은 포인트만 남긴 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    bottomHighlightTechnique: SoftBasicBottomHighlightTechnique.sideKiss,
    badge: 'POINT',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R9N-02',
    name: 'Soft Spot',
    intent: '선 대신 작은 타원형 밝은 면을 표면 안쪽에 녹여 우연히 빛이 맺힌 듯 보이게 한 안.',
    state: SoftBasicCandidateState.candidate,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    bottomHighlightTechnique: SoftBasicBottomHighlightTechnique.softSpot,
    badge: 'SOFT',
  ),
  SoftBasicCandidate(
    id: 'SB-C-R9N-03',
    name: 'Edge Fade',
    intent: '우하단 외곽 일부만 같은 색 계열로 살짝 밝아졌다 사라지게 해 별도 장식처럼 보이지 않는 안.',
    state: SoftBasicCandidateState.selected,
    finishTechnique: SoftBasicCircleFinishTechnique.colorShell,
    bottomHighlightTechnique: SoftBasicBottomHighlightTechnique.edgeFade,
    badge: 'SELECTED',
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


enum SoftBasicSquareTechnique {
  balanced,
  softerCorner,
  tighterCorner,
  wideHighlight,
  compactHighlight,
  strongerBounce,
}

enum SoftBasicSquareHighlightTechnique {
  round1Base,
  flatInset,
  shortCompact,
  taperedEdge,
  cornerKiss,
  softFacet,
  edgeFade,
}

enum SoftBasicSquareMaterialProfile {
  legacy,
  circleTransfer,
  mockupGloss,
  softGloss,
  wideDiffuse,
  highSpec,
  balancedGloss,
}

enum SoftBasicSquareGlossRefinement {
  base,
  highSoftPatch,
  highCompactCore,
  balancedBright,
  balancedWide,
}

class SoftBasicSquareCandidate {
  const SoftBasicSquareCandidate({
    required this.id,
    required this.name,
    required this.intent,
    required this.technique,
    this.highlightTechnique = SoftBasicSquareHighlightTechnique.round1Base,
    this.materialProfile = SoftBasicSquareMaterialProfile.legacy,
    this.glossRefinement = SoftBasicSquareGlossRefinement.base,
    this.badge,
  });

  final String id;
  final String name;
  final String intent;
  final SoftBasicSquareTechnique technique;
  final SoftBasicSquareHighlightTechnique highlightTechnique;
  final SoftBasicSquareMaterialProfile materialProfile;
  final SoftBasicSquareGlossRefinement glossRefinement;
  final String? badge;
}

const softBasicSquareRound1Candidates = <SoftBasicSquareCandidate>[
  SoftBasicSquareCandidate(
    id: 'SB-S-R1-01',
    name: 'Balanced',
    intent: 'Circle 확정 언어를 Square에 가장 중립적으로 이식한 기준안.',
    technique: SoftBasicSquareTechnique.balanced,
    badge: 'BASE',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R1-02',
    name: 'Softer Corner',
    intent: '모서리를 더 둥글게 하여 말랑한 인상을 강화한 안.',
    technique: SoftBasicSquareTechnique.softerCorner,
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R1-03',
    name: 'Tighter Corner',
    intent: 'Square 정체성이 더 선명하도록 코너 반경을 줄인 안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R1-04',
    name: 'Wide Highlight',
    intent: '상단 좌측 하이라이트를 넓혀 Circle과 같은 부드러운 빛 흐름을 강조한 안.',
    technique: SoftBasicSquareTechnique.wideHighlight,
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R1-05',
    name: 'Compact Highlight',
    intent: '하이라이트를 작고 응축되게 만들어 Square의 면감을 살린 안.',
    technique: SoftBasicSquareTechnique.compactHighlight,
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R1-06',
    name: 'Stronger Bounce',
    intent: '하단 Ambient Bounce를 조금 강화해 사각 면에서도 볼륨이 읽히게 한 안.',
    technique: SoftBasicSquareTechnique.strongerBounce,
    badge: 'VOLUME',
  ),
];


const softBasicSquareRound2Candidates = <SoftBasicSquareCandidate>[
  SoftBasicSquareCandidate(
    id: 'SB-S-R2-01',
    name: 'Reference Pill',
    intent: '레퍼런스처럼 좌상단에 길쭉한 세로형 glossy pill을 두고, 별도 core glint를 겹쳐 입체감을 만든 기준안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    highlightTechnique: SoftBasicSquareHighlightTechnique.flatInset,
    badge: 'REF',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R2-02',
    name: 'Soft Wide Pill',
    intent: 'Reference Pill보다 폭과 번짐을 약간 넓혀 더 부드럽고 사랑스러운 Soft Basic 인상을 강조한 안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    highlightTechnique: SoftBasicSquareHighlightTechnique.shortCompact,
    badge: 'SOFT',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R2-03',
    name: 'Corner Sweep',
    intent: '하이라이트를 코너 곡률을 따라 조금 더 길게 흘려 레퍼런스의 glossy edge 느낌을 강화한 안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    highlightTechnique: SoftBasicSquareHighlightTechnique.taperedEdge,
    badge: 'EDGE',
  ),
];


const softBasicSquareRound3Candidates = <SoftBasicSquareCandidate>[
  SoftBasicSquareCandidate(
    id: 'SB-S-R3-01',
    name: 'Corner Kiss',
    intent: '좌상단 코너 한쪽에만 짧은 색상광을 두어 하이라이트를 장식이 아닌 작은 포인트로 읽히게 한 안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    highlightTechnique: SoftBasicSquareHighlightTechnique.cornerKiss,
    badge: 'POINT',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R3-02',
    name: 'Soft Facet',
    intent: '선이나 pill 없이 좌상단 면 자체의 밝기만 살짝 올려 자연스러운 면광으로 처리한 안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    highlightTechnique: SoftBasicSquareHighlightTechnique.softFacet,
    badge: 'SOFT',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R3-03',
    name: 'Edge Fade',
    intent: '상단과 좌측 엣지 일부가 같은 색 계열로 자연스럽게 밝아졌다 사라지도록 한 가장 절제된 안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    highlightTechnique: SoftBasicSquareHighlightTechnique.edgeFade,
    badge: 'NATURAL',
  ),
];


const softBasicSquareRound4Candidates = <SoftBasicSquareCandidate>[
  SoftBasicSquareCandidate(
    id: 'SB-S-R4-01',
    name: 'Circle Transfer',
    intent: '확정 Circle R9N-03의 광원 구조와 재질감을 Square geometry에 가장 직접적으로 이식한 기준안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.circleTransfer,
    badge: 'CIRCLE',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R4-02',
    name: 'Mockup Gloss',
    intent: '목업의 Soft Spec, Core Spec, Diffuse Light, Form Shadow를 가장 선명하게 재현한 고광택 기준안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.mockupGloss,
    badge: 'MOCKUP',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R4-03',
    name: 'Soft Gloss',
    intent: 'Mockup Gloss의 광택 구조는 유지하되 광도와 대비를 약 15~20% 낮춘 부드러운 절충안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.softGloss,
    badge: 'SOFT',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R4-04',
    name: 'Wide Diffuse',
    intent: '하단 색상 반사광을 넓게 퍼뜨려 선 없이도 말랑한 볼륨이 읽히도록 만든 안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.wideDiffuse,
    badge: 'DIFFUSE',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R4-05',
    name: 'High Spec',
    intent: '좌상단 Soft Spec과 작은 Core Spec을 선명하게 잡아 매끈한 표면 광택을 가장 쉽게 읽히게 한 안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.highSpec,
    badge: 'SPEC',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R4-06',
    name: 'Balanced Gloss',
    intent: '상단광, 코어광, 하단 반사광, 우하단 음영을 균형 있게 조정해 실사용 58px까지 노린 종합안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.balancedGloss,
    badge: 'BALANCED',
  ),
];


const softBasicSquareRound5Candidates = <SoftBasicSquareCandidate>[
  SoftBasicSquareCandidate(
    id: 'SB-S-R5-01',
    name: 'High Spec Base',
    intent: 'Round 4-05 High Spec을 그대로 유지한 기준안. 선명한 Core Spec과 응축된 좌상단 면광을 비교 기준으로 사용.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.highSpec,
    glossRefinement: SoftBasicSquareGlossRefinement.base,
    badge: 'HS BASE',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R5-02',
    name: 'High Spec · Soft Patch',
    intent: 'High Spec의 Core Spec은 유지하고 Soft Spec 면적을 넓히며 경계를 부드럽게 해 목업의 면광 비중을 강화한 안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.highSpec,
    glossRefinement: SoftBasicSquareGlossRefinement.highSoftPatch,
    badge: 'HS SOFT',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R5-03',
    name: 'High Spec · No Core',
    intent: '넓은 Soft Spec은 유지하고 Core Spec과 secondary sparkle을 제거해 가장 깔끔한 glossy patch만 남긴 Round 5 최종 Master.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.highSpec,
    glossRefinement: SoftBasicSquareGlossRefinement.highCompactCore,
    badge: 'SELECTED',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R5-04',
    name: 'Balanced Base',
    intent: 'Round 4-06 Balanced Gloss를 그대로 유지한 기준안. 상단 면광, Core Spec, 하단 Bounce의 균형을 비교 기준으로 사용.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.balancedGloss,
    glossRefinement: SoftBasicSquareGlossRefinement.base,
    badge: 'BG BASE',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R5-05',
    name: 'Balanced · Brighter',
    intent: 'Balanced의 비율은 유지하면서 좌상단 Soft/Core Spec을 한 단계 밝게 올려 58px에서도 광택이 확실히 읽히게 한 안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.balancedGloss,
    glossRefinement: SoftBasicSquareGlossRefinement.balancedBright,
    badge: 'BG BRIGHT',
  ),
  SoftBasicSquareCandidate(
    id: 'SB-S-R5-06',
    name: 'Balanced · Wide Soft',
    intent: '좌상단 면광과 하단 Bounce를 조금 넓히고 Core Spec은 살짝 낮춰 가장 부드럽고 목업 친화적인 균형을 노린 안.',
    technique: SoftBasicSquareTechnique.tighterCorner,
    materialProfile: SoftBasicSquareMaterialProfile.balancedGloss,
    glossRefinement: SoftBasicSquareGlossRefinement.balancedWide,
    badge: 'BG WIDE',
  ),
];

const softBasicSquareSelectedMasterId = 'SB-S-R5-03';


class SoftBasicTriangleGeometryCandidate {
  const SoftBasicTriangleGeometryCandidate({
    required this.id,
    required this.name,
    required this.cornerRadius,
    required this.intent,
    this.badge,
  });

  final String id;
  final String name;
  final double cornerRadius;
  final String intent;
  final String? badge;
}

const softBasicTriangleGeometryRound1Candidates =
    <SoftBasicTriangleGeometryCandidate>[
  SoftBasicTriangleGeometryCandidate(
    id: 'SB-T-G1-01',
    name: 'Sharp Soft',
    cornerRadius: 2.0,
    intent: '정삼각형 직선감을 가장 강하게 유지하고 꼭짓점의 날카로움만 최소한으로 완화.',
    badge: '2px',
  ),
  SoftBasicTriangleGeometryCandidate(
    id: 'SB-T-G1-02',
    name: 'Light Round',
    cornerRadius: 3.0,
    intent: '정삼각형 인상은 그대로 두고 꼭짓점 끝만 가볍게 둥글린 균형안.',
    badge: '3px',
  ),
  SoftBasicTriangleGeometryCandidate(
    id: 'SB-T-G1-03',
    name: 'Current Soft',
    cornerRadius: 4.0,
    intent: '현재 Soft Basic Triangle Master 기준. 직선 구간을 충분히 남긴 소프트 코너.',
    badge: 'CURRENT',
  ),
  SoftBasicTriangleGeometryCandidate(
    id: 'SB-T-G1-04',
    name: 'Max Soft',
    cornerRadius: 5.0,
    intent: '정삼각형으로 읽히는 범위에서 코너 라운드를 가장 강하게 준 상한 확인안.',
    badge: '5px',
  ),
];

enum SoftBasicTriangleApproach {
  current,
  glossCap,
  dualSpec,
  edgeSweep,
  bevelRim,
  domeVolume,
  bottomBounce,
  sculptedHybrid,
}

class SoftBasicTriangleMaterialCandidate {
  const SoftBasicTriangleMaterialCandidate({
    required this.id,
    required this.name,
    required this.intent,
    required this.approach,
    this.badge,
  });

  final String id;
  final String name;
  final String intent;
  final SoftBasicTriangleApproach approach;
  final String? badge;
}

const softBasicTriangleFinalCandidates = <SoftBasicTriangleMaterialCandidate>[
  SoftBasicTriangleMaterialCandidate(
    id: 'SB-T-D1-00',
    name: 'Current Transfer',
    intent: '현재 Triangle에 이식된 Soft Basic 표현. 다른 접근법과의 차이를 보기 위한 기준안.',
    approach: SoftBasicTriangleApproach.current,
    badge: 'BASE',
  ),
  SoftBasicTriangleMaterialCandidate(
    id: 'SB-T-D1-01',
    name: 'Gloss Cap',
    intent: '좌상단에 넓고 길쭉한 반사면을 얹고 Form Shadow를 받쳐 목업처럼 볼륨을 즉시 읽히게 하는 방식.',
    approach: SoftBasicTriangleApproach.glossCap,
    badge: 'GLOSS',
  ),
  SoftBasicTriangleMaterialCandidate(
    id: 'SB-T-D1-02',
    name: 'Dual Spec',
    intent: '넓은 Soft Spec과 짧고 선명한 Core Spec을 분리해 광택이 강한 입체감을 만드는 방식.',
    approach: SoftBasicTriangleApproach.dualSpec,
    badge: 'SPEC',
  ),
  SoftBasicTriangleMaterialCandidate(
    id: 'SB-T-D1-03',
    name: 'Edge Sweep',
    intent: '삼각형 좌상단 변을 따라 길게 흐르는 곡선 하이라이트로 면 방향과 실루엣을 동시에 살리는 방식.',
    approach: SoftBasicTriangleApproach.edgeSweep,
    badge: 'EDGE',
  ),
  SoftBasicTriangleMaterialCandidate(
    id: 'SB-T-D1-04',
    name: 'Soft Bevel Rim',
    intent: '밝은 좌상단 Rim과 어두운 우하단 Rim을 짝으로 사용해 둥근 모서리와 두께감을 만드는 방식.',
    approach: SoftBasicTriangleApproach.bevelRim,
    badge: 'BEVEL',
  ),
  SoftBasicTriangleMaterialCandidate(
    id: 'SB-T-D1-05',
    name: 'Dome Volume',
    intent: '하이라이트 한 줄보다 넓은 중앙 면광과 하단 Form Shadow로 삼각형 전체가 볼록하게 솟아 보이게 하는 방식.',
    approach: SoftBasicTriangleApproach.domeVolume,
    badge: 'DOME',
  ),
  SoftBasicTriangleMaterialCandidate(
    id: 'SB-T-D1-06',
    name: 'Bottom Bounce',
    intent: '상단 Spec은 절제하고 하단 반사광과 우하단 음영의 대비로 말랑한 부피를 만드는 방식.',
    approach: SoftBasicTriangleApproach.bottomBounce,
    badge: 'BOUNCE',
  ),
  SoftBasicTriangleMaterialCandidate(
    id: 'SB-T-D1-07',
    name: 'Sculpted Hybrid',
    intent: 'Gloss Cap + 국소 Core + Form Shadow + Bottom Bounce를 함께 사용해 목표 목업의 Soft Volume을 가장 적극적으로 재현한 조합안.',
    approach: SoftBasicTriangleApproach.sculptedHybrid,
    badge: 'REFINED',
  ),
];

