import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_render_overrides.dart';

enum SoftBasicCandidateState {
  candidate,
  shortlist,
  selected,
  partiallyAdopted,
  rejected,
  hold,
}

class SoftBasicCandidate {
  const SoftBasicCandidate({
    required this.id,
    required this.name,
    required this.intent,
    required this.state,
    required this.overrides,
    this.badge,
  });

  final String id;
  final String name;
  final String intent;
  final SoftBasicCandidateState state;
  final Map<ShapeKind, ShapeRenderOverrides> overrides;
  final String? badge;

  ShapeRenderOverrides? forShape(ShapeKind shape) => overrides[shape];
}

const softBasicRound1Candidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-R1-01',
    name: 'Current 007',
    intent: '현재 Production 기준안. 모든 후보의 비교 기준.',
    state: SoftBasicCandidateState.candidate,
    badge: 'CURRENT',
    overrides: {},
  ),
  SoftBasicCandidate(
    id: 'SB-R1-02',
    name: 'Soft Cushion',
    intent: '넓은 면광과 완만한 음영으로 말랑한 2D 쿠션감을 강화.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.18,
        surfaceCenterY: -0.24,
        surfaceRadius: 1.92,
        layerOpacityById: {
          'diffuse_light': 0.44,
          'form_shadow': 0.29,
          'rim_light': 0.025,
          'soft_spec': 0.29,
          'core_spec': 0.54,
        },
        shadowOpacityScale: 0.80,
        shadowElevationScale: 0.85,
      ),
      ShapeKind.square: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 1.35,
          'shade': 0.82,
          'spec': 0.82,
        },
        shadowOpacityScale: 0.75,
        shadowElevationScale: 0.82,
      ),
      ShapeKind.triangle: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 1.32,
          'shade': 0.84,
          'spec': 0.80,
        },
        shadowOpacityScale: 0.75,
        shadowElevationScale: 0.82,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-R1-03',
    name: 'Depth Push',
    intent: 'Form Shadow와 면 대비를 키워 작은 크기에서도 덩어리감을 빠르게 읽히게 함.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.23,
        surfaceCenterY: -0.31,
        surfaceRadius: 1.56,
        layerOpacityById: {
          'diffuse_light': 0.38,
          'form_shadow': 0.52,
          'rim_light': 0.028,
          'soft_spec': 0.14,
          'core_spec': 0.48,
        },
        shadowOpacityScale: 1.35,
        shadowElevationScale: 1.28,
      ),
      ShapeKind.square: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 1.08,
          'shade': 1.62,
          'spec': 0.78,
        },
        shadowOpacityScale: 1.28,
        shadowElevationScale: 1.18,
      ),
      ShapeKind.triangle: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 1.05,
          'shade': 1.62,
          'spec': 0.76,
        },
        shadowOpacityScale: 1.28,
        shadowElevationScale: 1.18,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-R1-04',
    name: 'Highlight Pop',
    intent: 'Core Spec과 국소 하이라이트를 키워 밝고 귀여운 존재감을 강화.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.28,
        surfaceCenterY: -0.34,
        surfaceRadius: 1.64,
        layerOpacityById: {
          'diffuse_light': 0.35,
          'form_shadow': 0.40,
          'rim_light': 0.072,
          'soft_spec': 0.31,
          'core_spec': 0.88,
        },
        shadowOpacityScale: 1.15,
        shadowElevationScale: 1.12,
      ),
      ShapeKind.square: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 1.12,
          'shade': 1.02,
          'spec': 1.42,
        },
        shadowOpacityScale: 1.08,
      ),
      ShapeKind.triangle: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 1.10,
          'shade': 1.04,
          'spec': 1.40,
        },
        shadowOpacityScale: 1.08,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-R1-05',
    name: 'Matte Soft',
    intent: 'Spec과 Rim을 크게 줄여 Base Color가 가장 먼저 읽히는 차분한 2D 방향.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.16,
        surfaceCenterY: -0.20,
        surfaceRadius: 2.12,
        layerOpacityById: {
          'diffuse_light': 0.25,
          'form_shadow': 0.27,
          'rim_light': 0.008,
          'soft_spec': 0.10,
          'core_spec': 0.26,
        },
        shadowOpacityScale: 0.56,
        shadowElevationScale: 0.64,
      ),
      ShapeKind.square: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 0.88,
          'shade': 0.82,
          'spec': 0.42,
        },
        shadowOpacityScale: 0.55,
        shadowElevationScale: 0.68,
      ),
      ShapeKind.triangle: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 0.88,
          'shade': 0.82,
          'spec': 0.40,
        },
        shadowOpacityScale: 0.55,
        shadowElevationScale: 0.68,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-R1-06',
    name: 'Clean Premium',
    intent: '광택과 명암을 모두 절제해 또렷하고 정돈된 프리미엄 2D 인상.',
    state: SoftBasicCandidateState.candidate,
    badge: 'TARGET',
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.22,
        surfaceCenterY: -0.27,
        surfaceRadius: 1.82,
        layerOpacityById: {
          'diffuse_light': 0.34,
          'form_shadow': 0.39,
          'rim_light': 0.028,
          'soft_spec': 0.17,
          'core_spec': 0.58,
        },
        shadowOpacityScale: 0.86,
        shadowElevationScale: 0.92,
      ),
      ShapeKind.square: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 1.02,
          'shade': 1.12,
          'spec': 0.88,
        },
        shadowOpacityScale: 0.82,
        shadowElevationScale: 0.90,
      ),
      ShapeKind.triangle: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 1.00,
          'shade': 1.14,
          'spec': 0.84,
        },
        shadowOpacityScale: 0.82,
        shadowElevationScale: 0.90,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-R1-07',
    name: 'Puffy',
    intent: '밝은 면과 그림자 모두 키워 통통하고 장난감 같은 볼륨감을 탐색.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.24,
        surfaceCenterY: -0.30,
        surfaceRadius: 1.50,
        layerOpacityById: {
          'diffuse_light': 0.48,
          'form_shadow': 0.48,
          'rim_light': 0.055,
          'soft_spec': 0.26,
          'core_spec': 0.74,
        },
        shadowOpacityScale: 1.30,
        shadowElevationScale: 1.35,
      ),
      ShapeKind.square: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 1.42,
          'shade': 1.46,
          'spec': 1.18,
        },
        shadowOpacityScale: 1.30,
        shadowElevationScale: 1.26,
      ),
      ShapeKind.triangle: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 1.38,
          'shade': 1.48,
          'spec': 1.16,
        },
        shadowOpacityScale: 1.30,
        shadowElevationScale: 1.26,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-R1-08',
    name: 'Flat Volume',
    intent: '평면성을 유지하면서 Light/Shade만으로 최소 볼륨을 남기는 경계안.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.12,
        surfaceCenterY: -0.16,
        surfaceRadius: 2.35,
        layerOpacityById: {
          'diffuse_light': 0.20,
          'form_shadow': 0.23,
          'rim_light': 0.0,
          'soft_spec': 0.06,
          'core_spec': 0.18,
        },
        shadowOpacityScale: 0.40,
        shadowElevationScale: 0.55,
      ),
      ShapeKind.square: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 0.72,
          'shade': 0.72,
          'spec': 0.28,
        },
        shadowOpacityScale: 0.40,
        shadowElevationScale: 0.55,
      ),
      ShapeKind.triangle: ShapeRenderOverrides(
        layerOpacityScaleById: {
          'light': 0.72,
          'shade': 0.72,
          'spec': 0.26,
        },
        shadowOpacityScale: 0.40,
        shadowElevationScale: 0.55,
      ),
    },
  ),
];
