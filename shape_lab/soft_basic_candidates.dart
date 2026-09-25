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

const softBasicCircleRound2Candidates = <SoftBasicCandidate>[
  SoftBasicCandidate(
    id: 'SB-C-R2-01',
    name: 'Current 007',
    intent: '현재 Production Circle 기준안. Round 2 비교 기준.',
    state: SoftBasicCandidateState.candidate,
    badge: 'CURRENT',
    overrides: {},
  ),
  SoftBasicCandidate(
    id: 'SB-C-R2-02',
    name: 'Wide Gloss',
    intent: '목업처럼 좌상단 하이라이트 면적을 크게 키운 안.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.28,
        surfaceCenterY: -0.32,
        surfaceRadius: 1.56,
        layerOpacityById: {
          'diffuse_light': 0.48,
          'form_shadow': 0.50,
          'rim_light': 0.085,
          'soft_spec': 0.46,
          'core_spec': 0.92,
        },
        layerTransformById: {
          'soft_spec': ShapeLayerTransform(
            scaleX: 1.28,
            scaleY: 1.34,
            offsetX: -3.5,
            offsetY: -3.0,
          ),
          'core_spec': ShapeLayerTransform(
            scaleX: 1.06,
            scaleY: 1.12,
            offsetX: -2.0,
            offsetY: -2.0,
          ),
          'form_shadow': ShapeLayerTransform(
            scaleX: 1.06,
            scaleY: 1.10,
            offsetX: 1.5,
            offsetY: 2.5,
          ),
        },
        shadowOpacityScale: 1.45,
        shadowElevationScale: 1.35,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-C-R2-03',
    name: 'Deep Candy',
    intent: '중심 색 농도와 우하단 깊이를 강하게 만들어 싼 플랫감을 제거.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.30,
        surfaceCenterY: -0.34,
        surfaceRadius: 1.46,
        layerOpacityById: {
          'diffuse_light': 0.42,
          'form_shadow': 0.62,
          'rim_light': 0.070,
          'soft_spec': 0.38,
          'core_spec': 0.86,
        },
        layerTransformById: {
          'soft_spec': ShapeLayerTransform(
            scaleX: 1.18,
            scaleY: 1.24,
            offsetX: -2.5,
            offsetY: -2.0,
          ),
          'form_shadow': ShapeLayerTransform(
            scaleX: 1.10,
            scaleY: 1.16,
            offsetX: 2.0,
            offsetY: 3.0,
          ),
          'rim_light': ShapeLayerTransform(
            scaleX: 1.04,
            scaleY: 1.06,
            offsetY: 1.5,
          ),
        },
        shadowOpacityScale: 1.60,
        shadowElevationScale: 1.45,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-C-R2-04',
    name: 'Mockup Push',
    intent: '현재 목업의 넓은 광택·강한 볼륨·하단 림을 가장 직접적으로 밀어붙인 안.',
    state: SoftBasicCandidateState.candidate,
    badge: 'TARGET',
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.32,
        surfaceCenterY: -0.36,
        surfaceRadius: 1.42,
        layerOpacityById: {
          'diffuse_light': 0.52,
          'form_shadow': 0.66,
          'rim_light': 0.115,
          'soft_spec': 0.50,
          'core_spec': 0.98,
        },
        layerTransformById: {
          'soft_spec': ShapeLayerTransform(
            scaleX: 1.36,
            scaleY: 1.44,
            offsetX: -4.5,
            offsetY: -4.0,
          ),
          'core_spec': ShapeLayerTransform(
            scaleX: 1.12,
            scaleY: 1.18,
            offsetX: -2.5,
            offsetY: -2.5,
          ),
          'diffuse_light': ShapeLayerTransform(
            scaleX: 1.10,
            scaleY: 1.12,
            offsetX: -1.0,
            offsetY: -1.5,
          ),
          'form_shadow': ShapeLayerTransform(
            scaleX: 1.12,
            scaleY: 1.18,
            offsetX: 2.5,
            offsetY: 3.5,
          ),
          'rim_light': ShapeLayerTransform(
            scaleX: 1.08,
            scaleY: 1.10,
            offsetY: 2.0,
          ),
        },
        shadowOpacityScale: 1.70,
        shadowElevationScale: 1.55,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-C-R2-05',
    name: 'Soft Bloom',
    intent: '광택 경계를 더 부드럽게 넓혀 사랑스러운 볼륨감을 강조.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.26,
        surfaceCenterY: -0.30,
        surfaceRadius: 1.60,
        layerOpacityById: {
          'diffuse_light': 0.56,
          'form_shadow': 0.48,
          'rim_light': 0.090,
          'soft_spec': 0.56,
          'core_spec': 0.78,
        },
        layerTransformById: {
          'soft_spec': ShapeLayerTransform(
            scaleX: 1.48,
            scaleY: 1.50,
            offsetX: -5.0,
            offsetY: -4.0,
          ),
          'core_spec': ShapeLayerTransform(
            scaleX: 0.92,
            scaleY: 0.98,
            offsetX: -1.5,
            offsetY: -1.5,
          ),
          'diffuse_light': ShapeLayerTransform(
            scaleX: 1.14,
            scaleY: 1.16,
            offsetX: -1.5,
            offsetY: -1.5,
          ),
        },
        shadowOpacityScale: 1.35,
        shadowElevationScale: 1.30,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-C-R2-06',
    name: 'Sharp Spark',
    intent: '넓은 광택 안쪽 코어 포인트를 선명하게 살려 생기를 강화.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.30,
        surfaceCenterY: -0.34,
        surfaceRadius: 1.50,
        layerOpacityById: {
          'diffuse_light': 0.46,
          'form_shadow': 0.56,
          'rim_light': 0.095,
          'soft_spec': 0.40,
          'core_spec': 1.00,
        },
        layerTransformById: {
          'soft_spec': ShapeLayerTransform(
            scaleX: 1.28,
            scaleY: 1.32,
            offsetX: -3.5,
            offsetY: -3.0,
          ),
          'core_spec': ShapeLayerTransform(
            scaleX: 1.22,
            scaleY: 1.26,
            offsetX: -2.0,
            offsetY: -2.0,
          ),
          'form_shadow': ShapeLayerTransform(
            scaleX: 1.08,
            scaleY: 1.12,
            offsetX: 1.5,
            offsetY: 3.0,
          ),
        },
        shadowOpacityScale: 1.50,
        shadowElevationScale: 1.40,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-C-R2-07',
    name: 'Bottom Lift',
    intent: '하단 림과 깊이를 키워 목업처럼 외곽 정돈감이 강하게 읽히는 안.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.28,
        surfaceCenterY: -0.32,
        surfaceRadius: 1.48,
        layerOpacityById: {
          'diffuse_light': 0.44,
          'form_shadow': 0.64,
          'rim_light': 0.150,
          'soft_spec': 0.38,
          'core_spec': 0.90,
        },
        layerTransformById: {
          'soft_spec': ShapeLayerTransform(
            scaleX: 1.24,
            scaleY: 1.28,
            offsetX: -3.0,
            offsetY: -2.5,
          ),
          'rim_light': ShapeLayerTransform(
            scaleX: 1.12,
            scaleY: 1.14,
            offsetY: 3.0,
          ),
          'form_shadow': ShapeLayerTransform(
            scaleX: 1.14,
            scaleY: 1.20,
            offsetX: 2.5,
            offsetY: 4.0,
          ),
        },
        shadowOpacityScale: 1.75,
        shadowElevationScale: 1.50,
      ),
    },
  ),
  SoftBasicCandidate(
    id: 'SB-C-R2-08',
    name: 'Sweet Volume',
    intent: '하이라이트·볼륨·림을 모두 강하게 쓰되 가장 부드럽고 귀여운 균형을 목표.',
    state: SoftBasicCandidateState.candidate,
    overrides: {
      ShapeKind.circle: ShapeRenderOverrides(
        surfaceCenterX: -0.31,
        surfaceCenterY: -0.35,
        surfaceRadius: 1.44,
        layerOpacityById: {
          'diffuse_light': 0.50,
          'form_shadow': 0.60,
          'rim_light': 0.125,
          'soft_spec': 0.48,
          'core_spec': 0.94,
        },
        layerTransformById: {
          'soft_spec': ShapeLayerTransform(
            scaleX: 1.34,
            scaleY: 1.40,
            offsetX: -4.0,
            offsetY: -3.5,
          ),
          'core_spec': ShapeLayerTransform(
            scaleX: 1.08,
            scaleY: 1.14,
            offsetX: -2.0,
            offsetY: -2.0,
          ),
          'diffuse_light': ShapeLayerTransform(
            scaleX: 1.10,
            scaleY: 1.12,
            offsetX: -1.0,
            offsetY: -1.0,
          ),
          'form_shadow': ShapeLayerTransform(
            scaleX: 1.10,
            scaleY: 1.16,
            offsetX: 2.0,
            offsetY: 3.5,
          ),
          'rim_light': ShapeLayerTransform(
            scaleX: 1.10,
            scaleY: 1.12,
            offsetY: 2.5,
          ),
        },
        shadowOpacityScale: 1.60,
        shadowElevationScale: 1.45,
      ),
    },
  ),
];
