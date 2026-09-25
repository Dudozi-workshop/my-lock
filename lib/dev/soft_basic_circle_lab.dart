import 'package:flutter/material.dart';

import '../lock_engine/models.dart';
import '../lock_engine/shape_spec/shape_spec.dart';
import '../lock_engine/shape_spec/shape_spec_registry.dart';

class SoftBasicCircleLabApp extends StatelessWidget {
  const SoftBasicCircleLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soft Basic Circle Lab',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF7157D9),
        scaffoldBackgroundColor: const Color(0xFFF6F4F8),
      ),
      home: const SoftBasicCircleLabPage(),
    );
  }
}

class SoftBasicCircleLabPage extends StatelessWidget {
  const SoftBasicCircleLabPage({super.key});

  static const _variants = <_CircleVariant>[
    _CircleVariant(
      id: 'BASE 007',
      title: 'Current',
      description: '현재 확정 기준. 이후 후보는 이 상태와 체감 차이가 나도록 의도적으로 벌렸습니다.',
      surfaceCenterX: -0.22,
      surfaceCenterY: -0.28,
      surfaceRadius: 1.72,
      diffuse: 0.32,
      formShadow: 0.36,
      rim: 0.045,
      softSpec: 0.20,
      coreSpec: 0.70,
      castShadow: 0.014,
      elevation: 1.10,
    ),
    _CircleVariant(
      id: 'A',
      title: 'Depth Push',
      description: '명암 경계를 더 분명하게. 작은 크기에서도 구형 덩어리감이 바로 읽히는 방향.',
      surfaceCenterX: -0.22,
      surfaceCenterY: -0.30,
      surfaceRadius: 1.58,
      diffuse: 0.42,
      formShadow: 0.50,
      rim: 0.035,
      softSpec: 0.14,
      coreSpec: 0.48,
      castShadow: 0.020,
      elevation: 1.35,
    ),
    _CircleVariant(
      id: 'B',
      title: 'Soft Cushion',
      description: '넓은 광과 완만한 음영. 반짝임보다 말랑한 2D 쿠션감에 집중한 방향.',
      surfaceCenterX: -0.18,
      surfaceCenterY: -0.24,
      surfaceRadius: 1.90,
      diffuse: 0.44,
      formShadow: 0.30,
      rim: 0.035,
      softSpec: 0.30,
      coreSpec: 0.58,
      castShadow: 0.012,
      elevation: 0.90,
    ),
    _CircleVariant(
      id: 'C',
      title: 'Highlight Pop',
      description: '코어 하이라이트와 림을 확실히 올린 방향. 밝고 귀여운 존재감을 우선합니다.',
      surfaceCenterX: -0.28,
      surfaceCenterY: -0.34,
      surfaceRadius: 1.62,
      diffuse: 0.35,
      formShadow: 0.42,
      rim: 0.075,
      softSpec: 0.30,
      coreSpec: 0.88,
      castShadow: 0.022,
      elevation: 1.40,
    ),
    _CircleVariant(
      id: 'D',
      title: 'Matte Soft',
      description: '반짝임을 크게 덜어낸 차분한 방향. 가장 2D에 가깝고 색 자체가 먼저 보입니다.',
      surfaceCenterX: -0.16,
      surfaceCenterY: -0.20,
      surfaceRadius: 2.10,
      diffuse: 0.25,
      formShadow: 0.28,
      rim: 0.010,
      softSpec: 0.11,
      coreSpec: 0.28,
      castShadow: 0.008,
      elevation: 0.70,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoColumns = constraints.maxWidth >= 760;
                      final width = twoColumns
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (final variant in _variants)
                            SizedBox(
                              width: width,
                              child: _VariantCard(variant: variant),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E3EE)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soft Basic · Circle Lab',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'LAB 001 · BASE 007 · 동일 마스크를 유지하고 광량/음영/스펙/표면곡률만 크게 벌려 비교',
            style: TextStyle(
              color: Color(0xFF6E6878),
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '비교 순서: ① 작은 크기에서 입체감이 바로 읽히는지 ② 핑크/블루/옐로우 모두 같은 인상을 유지하는지 ③ 과한 3D 느낌 없이 Soft Basic 감성이 남는지',
            style: TextStyle(
              color: Color(0xFF3D3945),
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({required this.variant});

  final _CircleVariant variant;

  @override
  Widget build(BuildContext context) {
    final isBase = variant.id.startsWith('BASE');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isBase
              ? const Color(0xFF7157D9)
              : const Color(0xFFE8E3EE),
          width: isBase ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: isBase
                      ? const Color(0xFFEEE9FF)
                      : const Color(0xFFF1EFF4),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  variant.id,
                  style: TextStyle(
                    color: isBase
                        ? const Color(0xFF5E43C7)
                        : const Color(0xFF5F5968),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  variant.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            variant.description,
            style: const TextStyle(
              color: Color(0xFF716B79),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0ECF3)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TonePreview(
                label: 'PINK',
                tone: ShapeTone.pink,
                variant: variant,
              ),
              _TonePreview(
                label: 'BLUE',
                tone: ShapeTone.blue,
                variant: variant,
              ),
              _TonePreview(
                label: 'YELLOW',
                tone: ShapeTone.yellow,
                variant: variant,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            variant.metrics,
            style: const TextStyle(
              color: Color(0xFF8A8492),
              fontSize: 10.5,
              height: 1.4,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _TonePreview extends StatelessWidget {
  const _TonePreview({
    required this.label,
    required this.tone,
    required this.variant,
  });

  final String label;
  final ShapeTone tone;
  final _CircleVariant variant;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 112,
          height: 112,
          child: CustomPaint(
            painter: _CircleVariantPainter(
              tone: tone,
              variant: variant,
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8492),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _CircleVariant {
  const _CircleVariant({
    required this.id,
    required this.title,
    required this.description,
    required this.surfaceCenterX,
    required this.surfaceCenterY,
    required this.surfaceRadius,
    required this.diffuse,
    required this.formShadow,
    required this.rim,
    required this.softSpec,
    required this.coreSpec,
    required this.castShadow,
    required this.elevation,
  });

  final String id;
  final String title;
  final String description;
  final double surfaceCenterX;
  final double surfaceCenterY;
  final double surfaceRadius;
  final double diffuse;
  final double formShadow;
  final double rim;
  final double softSpec;
  final double coreSpec;
  final double castShadow;
  final double elevation;

  double opacityFor(String layerId, double fallback) {
    return switch (layerId) {
      'diffuse_light' => diffuse,
      'form_shadow' => formShadow,
      'rim_light' => rim,
      'soft_spec' => softSpec,
      'core_spec' => coreSpec,
      _ => fallback,
    };
  }

  String get metrics =>
      'surface r=${surfaceRadius.toStringAsFixed(2)} · '
      'diffuse=${diffuse.toStringAsFixed(2)} · '
      'shadow=${formShadow.toStringAsFixed(2)} · '
      'rim=${rim.toStringAsFixed(3)} · '
      'soft=${softSpec.toStringAsFixed(2)} · '
      'core=${coreSpec.toStringAsFixed(2)}';
}

class _CircleVariantPainter extends CustomPainter {
  const _CircleVariantPainter({
    required this.tone,
    required this.variant,
  });

  final ShapeTone tone;
  final _CircleVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    final bundle = ShapeSpecRegistry.instance.resolve(
      ShapeStyle.softBasic,
      ShapeKind.circle,
    );
    final canvasSize = bundle.style.canvasSize;
    final radius = size.shortestSide * 0.42;
    final scale = radius * 2 / canvasSize;
    final origin = Offset(
      (size.width - canvasSize * scale) / 2,
      (size.height - canvasSize * scale) / 2,
    );

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale, scale);

    final body = bundle.shape.body;
    final values = body.values;
    final bodyPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(
            (values['cx'] as num).toDouble(),
            (values['cy'] as num).toDouble(),
          ),
          radius: (values['r'] as num).toDouble(),
        ),
      );

    if (variant.castShadow > 0) {
      canvas.save();
      canvas.translate(
        bundle.shape.shadow.offsetX,
        bundle.shape.shadow.offsetY,
      );
      canvas.drawShadow(
        bodyPath,
        Colors.black.withValues(alpha: variant.castShadow),
        variant.elevation,
        true,
      );
      canvas.restore();
    }

    final base = baseColorForTone(tone);
    final rules = bundle.style.colorRules;
    final toneScale = _toneScale(tone);
    final light = adjustTone(
      base,
      lightnessDelta: rules.lightnessUp * toneScale.light,
      saturationDelta: rules.lightSaturationDelta,
    );
    final shade = adjustTone(
      base,
      lightnessDelta: -rules.lightnessDown * toneScale.shade,
      saturationDelta: rules.shadeSaturationDelta,
    );
    final surfaceLight = adjustTone(
      base,
      lightnessDelta: rules.lightnessUp * 0.26 * toneScale.light,
      saturationDelta: rules.lightSaturationDelta,
    );
    final surfaceShade = adjustTone(
      base,
      lightnessDelta: -rules.lightnessDown * 0.22 * toneScale.shade,
      saturationDelta: rules.shadeSaturationDelta * 0.5,
    );

    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          variant.surfaceCenterX,
          variant.surfaceCenterY,
        ),
        radius: variant.surfaceRadius,
        colors: [
          surfaceLight,
          base,
          base,
          surfaceShade,
        ],
        stops: bundle.shape.surface.stops,
      ).createShader(Rect.fromLTWH(0, 0, canvasSize, canvasSize));
    canvas.drawPath(bodyPath, bodyPaint);

    canvas.save();
    canvas.clipPath(bodyPath);
    for (final layer in bundle.shape.layers) {
      if (layer.geometry.kind != 'mask') continue;
      final asset = layer.geometry.values['asset'] as String;
      final image = ShapeSpecRegistry.instance.resolveMask(asset);
      final layerColor = switch (layer.role) {
        ShapeLayerRole.light => light,
        ShapeLayerRole.shade => shade,
        ShapeLayerRole.spec => rules.specColor,
      };
      final opacity = variant.opacityFor(layer.id, layer.opacity);
      final paint = Paint()
        ..filterQuality = FilterQuality.high
        ..blendMode = _blendModeFor(layer.blend)
        ..colorFilter = ColorFilter.mode(
          layerColor.withValues(alpha: opacity),
          BlendMode.srcIn,
        );
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(
          0,
          0,
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        Rect.fromLTWH(0, 0, canvasSize, canvasSize),
        paint,
      );
    }
    canvas.restore();
    canvas.restore();
  }

  ({double light, double shade}) _toneScale(ShapeTone tone) {
    return switch (tone) {
      ShapeTone.pink => (light: 0.88, shade: 1.12),
      ShapeTone.blue => (light: 0.84, shade: 1.00),
      ShapeTone.yellow => (light: 0.68, shade: 1.30),
    };
  }

  BlendMode _blendModeFor(ShapeLayerBlend blend) {
    return switch (blend) {
      ShapeLayerBlend.normal => BlendMode.srcOver,
      ShapeLayerBlend.softLight => BlendMode.softLight,
      ShapeLayerBlend.multiply => BlendMode.multiply,
      ShapeLayerBlend.screen => BlendMode.screen,
    };
  }

  @override
  bool shouldRepaint(covariant _CircleVariantPainter oldDelegate) {
    return oldDelegate.tone != tone || oldDelegate.variant.id != variant.id;
  }
}
