import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/lock_engine/shape_geometry.dart';

void main() {
  runApp(const ShapeLabApp());
}

class ShapeLabApp extends StatelessWidget {
  const ShapeLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LOCK Shape Lab',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF5C6CF2),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const ShapeLabPage(),
    );
  }
}

class ShapeLabPage extends StatefulWidget {
  const ShapeLabPage({super.key});

  @override
  State<ShapeLabPage> createState() => _ShapeLabPageState();
}

class _ShapeLabPageState extends State<ShapeLabPage>
    with SingleTickerProviderStateMixin {
  ShapeKind shape = ShapeKind.dolphin;
  ShapeTone tone = ShapeTone.blue;
  ShapeTexture texture = ShapeTexture.glossy;
  bool darkBackground = false;
  bool draftMode = true;

  double overallScale = 1.0;
  double scaleX = 1.0;
  double scaleY = 1.0;
  double offsetX = 0.0;
  double offsetY = 0.0;

  double forehead = 0.0;
  double snout = 0.0;
  double bodyDepth = 1.0;
  double tailScale = 1.0;
  bool accentEnabled = true;
  double accentSize = 1.0;
  double accentY = 0.0;
  double accentLightness = 0.48;
  late final AnimationController _effectController;

  @override
  void initState() {
    super.initState();
    _effectController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _effectController.dispose();
    super.dispose();
  }

  bool get _isColorEffectPreview =>
      tone == ShapeTone.dawnDew || tone == ShapeTone.fireflyLight;

  void resetDraft() {
    setState(() {
      overallScale = 1.0;
      scaleX = 1.0;
      scaleY = 1.0;
      offsetX = 0.0;
      offsetY = 0.0;
      forehead = 0.0;
      snout = 0.0;
      bodyDepth = 1.0;
      tailScale = 1.0;
      accentEnabled = true;
      accentSize = 1.0;
      accentY = 0.0;
      accentLightness = 0.48;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageColor = darkBackground
        ? const Color(0xFF11131A)
        : const Color(0xFFF5F6FA);
    final cardColor = darkBackground
        ? const Color(0xFF1B1E28)
        : Colors.white;
    final textColor = darkBackground ? Colors.white : const Color(0xFF171923);
    final muted = darkBackground
        ? const Color(0xFFAEB4C3)
        : const Color(0xFF6D7382);

    final transform = _DraftTransform(
      enabled: draftMode,
      overallScale: overallScale,
      scaleX: scaleX,
      scaleY: scaleY,
      offsetX: offsetX,
      offsetY: offsetY,
    );

    final draftBlueprint = draftMode && shape == ShapeKind.dolphin
        ? _buildDolphinDraftBlueprint(
            forehead: forehead,
            snout: snout,
            bodyDepth: bodyDepth,
            tailScale: tailScale,
            accentEnabled: accentEnabled,
            accentSize: accentSize,
            accentY: accentY,
          )
        : null;

    final silhouetteOnlyBlueprint = shape == ShapeKind.dolphin
        ? _buildDolphinDraftBlueprint(
            forehead: forehead,
            snout: snout,
            bodyDepth: bodyDepth,
            tailScale: tailScale,
            accentEnabled: false,
            accentSize: accentSize,
            accentY: accentY,
          )
        : null;

    final accentMapBlueprint = shape == ShapeKind.dolphin
        ? _buildDolphinDraftBlueprint(
            forehead: forehead,
            snout: snout,
            bodyDepth: bodyDepth,
            tailScale: tailScale,
            accentEnabled: true,
            accentSize: accentSize,
            accentY: accentY,
          )
        : null;

    Future<void> copyDraftSpec() async {
      final spec = <String, Object>{
        'shape': shape.name,
        'tone': tone.name,
        'surface': texture.name,
        'accentMap': 'dolphin-v1',
        'accentEnabled': accentEnabled,
        'accentSize': double.parse(accentSize.toStringAsFixed(3)),
        'accentY': double.parse(accentY.toStringAsFixed(2)),
        'accentLightness': double.parse(accentLightness.toStringAsFixed(3)),
        'forehead': double.parse(forehead.toStringAsFixed(2)),
        'snout': double.parse(snout.toStringAsFixed(2)),
        'bodyDepth': double.parse(bodyDepth.toStringAsFixed(3)),
        'tailScale': double.parse(tailScale.toStringAsFixed(3)),
        'overallScale': double.parse(overallScale.toStringAsFixed(3)),
        'scaleX': double.parse(scaleX.toStringAsFixed(3)),
        'scaleY': double.parse(scaleY.toStringAsFixed(3)),
        'offsetX': double.parse(offsetX.toStringAsFixed(2)),
        'offsetY': double.parse(offsetY.toStringAsFixed(2)),
      };
      await Clipboard.setData(ClipboardData(text: spec.toString()));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft 설정값을 복사했어요.')),
      );
    }

    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MY LOCK Shape Lab',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '본앱과 동일한 LockTokenPainter를 직접 사용',
                              style: TextStyle(color: muted, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      _ModeBadge(
                        label: draftMode ? 'DRAFT' : 'APP EXACT',
                        draft: draftMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  _Panel(
                    color: cardColor,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _DropdownField<ShapeKind>(
                          label: '도형',
                          value: shape,
                          values: ShapeKind.values,
                          text: (value) => value.label,
                          onChanged: (value) => setState(() => shape = value),
                        ),
                        _DropdownField<ShapeTone>(
                          label: '색상',
                          value: tone,
                          values: ShapeTone.values,
                          text: (value) => value.label,
                          onChanged: (value) => setState(() => tone = value),
                        ),
                        _DropdownField<ShapeTexture>(
                          label: '재질',
                          value: texture,
                          values: ShapeTexture.values,
                          text: (value) => value.label,
                          onChanged: (value) => setState(() => texture = value),
                        ),
                        _ToggleField(
                          label: '어두운 배경',
                          value: darkBackground,
                          onChanged: (value) =>
                              setState(() => darkBackground = value),
                        ),
                        _ToggleField(
                          label: '편집모드',
                          value: draftMode,
                          onChanged: (value) =>
                              setState(() => draftMode = value),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _Panel(
                    color: cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Color Effect PoC · APP EXACT',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '실제 LockTokenPainter · Glossy · 58×58 · 원/세모/네모',
                          style: TextStyle(color: muted, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _effectController,
                          builder: (context, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (final kind in const [
                                  ShapeKind.circle,
                                  ShapeKind.triangle,
                                  ShapeKind.square,
                                ])
                                  Column(
                                    children: [
                                      SizedBox.square(
                                        dimension: 116,
                                        child: Center(
                                          child: Transform.scale(
                                            scale: 2,
                                            child: SizedBox.square(
                                              dimension: 58,
                                              child: _AnimatedColorToken(
                                                shape: kind,
                                                tone: tone,
                                                background: pageColor,
                                                phase: _effectController.value,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        kind.label,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isColorEffectPreview
                              ? tone == ShapeTone.dawnDew
                                  ? '새벽이슬: 굴절광 밴드 + 이슬 하이라이트가 Shape 내부에서 이동'
                                  : '반딧불빛: 작은 황금 발광점이 Shape 내부에서 독립적으로 이동·점멸'
                              : '색상에서 새벽이슬 또는 반딧불빛을 선택하면 애니메이션을 비교할 수 있습니다.',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 720;
                      final largePreview = _Panel(
                        color: cardColor,
                        child: Column(
                          children: [
                            Text(
                              '4× 확대 · 동일 58×58 렌더',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox.square(
                              dimension: 280,
                              child: Center(
                                child: Transform.scale(
                                  scale: 4,
                                  child: SizedBox.square(
                                    dimension: 58,
                                    child: _TokenPreview(
                                      shape: shape,
                                      tone: tone,
                                      texture: texture,
                                      background: pageColor,
                                      transform: transform,
                                      blueprintOverride: draftBlueprint,
                                      accentLightness: accentLightness,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      final exactPreview = _Panel(
                        color: cardColor,
                        child: Column(
                          children: [
                            Text(
                              '실사용 크기',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox.square(
                              dimension: 58,
                              child: _TokenPreview(
                                shape: shape,
                                tone: tone,
                                texture: texture,
                                background: pageColor,
                                transform: transform,
                                blueprintOverride: draftBlueprint,
                                accentLightness: accentLightness,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '58 × 58',
                              style: TextStyle(color: muted, fontSize: 13),
                            ),
                          ],
                        ),
                      );

                      if (narrow) {
                        return Column(
                          children: [
                            largePreview,
                            const SizedBox(height: 16),
                            exactPreview,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 2, child: largePreview),
                          const SizedBox(width: 16),
                          Expanded(child: exactPreview),
                        ],
                      );
                    },
                  ),

                  if (shape == ShapeKind.dolphin) ...[
                    const SizedBox(height: 16),
                    _Panel(
                      color: cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Accent Map 비교',
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '외곽은 동일하게 유지하고 내부 Accent 영역만 켜고 끕니다.',
                                      style: TextStyle(color: muted, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: draftMode ? copyDraftSpec : null,
                                icon: const Icon(Icons.copy_all_outlined, size: 18),
                                label: const Text('Draft 복사'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, inner) {
                              final width = inner.maxWidth;
                              final itemWidth =
                                  width < 520 ? width : (width - 12) / 2;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: itemWidth,
                                    child: _VariantCard(
                                      title: 'Silhouette',
                                      subtitle: '외곽만 확인',
                                      selected: draftMode && !accentEnabled,
                                      onTap: draftMode
                                          ? () => setState(
                                                () => accentEnabled = false,
                                              )
                                          : null,
                                      child: _TokenPreview(
                                        shape: shape,
                                        tone: tone,
                                        texture: texture,
                                        background: pageColor,
                                        transform: transform,
                                        blueprintOverride:
                                            silhouetteOnlyBlueprint,
                                        accentLightness: accentLightness,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _VariantCard(
                                      title: 'Accent Map',
                                      subtitle: '입 · 배 · 앞/뒤 지느러미',
                                      selected: draftMode && accentEnabled,
                                      onTap: draftMode
                                          ? () => setState(
                                                () => accentEnabled = true,
                                              )
                                          : null,
                                      child: _TokenPreview(
                                        shape: shape,
                                        tone: tone,
                                        texture: texture,
                                        background: pageColor,
                                        transform: transform,
                                        blueprintOverride: accentMapBlueprint,
                                        accentLightness: accentLightness,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  _Panel(
                    color: cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '동일 슬롯 비교',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _CompareToken(
                              label: 'Circle',
                              shape: ShapeKind.circle,
                              tone: tone,
                              texture: texture,
                              background: pageColor,
                            ),
                            _CompareToken(
                              label: 'Star',
                              shape: ShapeKind.star,
                              tone: tone,
                              texture: texture,
                              background: pageColor,
                            ),
                            _CompareToken(
                              label: shape.label,
                              shape: shape,
                              tone: tone,
                              texture: texture,
                              background: pageColor,
                              transform: transform,
                              blueprintOverride: draftBlueprint,
                              accentLightness: accentLightness,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (shape == ShapeKind.dolphin && draftMode) ...[
                    const SizedBox(height: 16),
                    _Panel(
                      color: cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Compare',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '같은 Draft Shape를 색상·재질만 바꿔 바로 비교',
                            style: TextStyle(color: muted, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Basic Tones',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 24,
                            runSpacing: 16,
                            children: [
                              for (final compareTone in const [
                                ShapeTone.pink,
                                ShapeTone.blue,
                                ShapeTone.yellow,
                              ])
                                _CompareToken(
                                  label: compareTone.label,
                                  shape: shape,
                                  tone: compareTone,
                                  texture: texture,
                                  background: pageColor,
                                  transform: transform,
                                  blueprintOverride: draftBlueprint,
                                  accentLightness: accentLightness,
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Surfaces',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 20,
                            runSpacing: 16,
                            children: [
                              for (final compareTexture in const [
                                ShapeTexture.glossy,
                                ShapeTexture.jelly,
                                ShapeTexture.glass,
                                ShapeTexture.matte,
                                ShapeTexture.metal,
                                ShapeTexture.hologram,
                              ])
                                _CompareToken(
                                  label: compareTexture.label,
                                  shape: shape,
                                  tone: tone,
                                  texture: compareTexture,
                                  background: pageColor,
                                  transform: transform,
                                  blueprintOverride: draftBlueprint,
                                  accentLightness: accentLightness,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (shape == ShapeKind.dolphin) ...[
                    const SizedBox(height: 16),
                    _Panel(
                      color: cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dolphin Accent Map',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            draftMode
                                ? '입 · 배 · 앞지느러미 · 뒷지느러미를 하나의 몸체 안에서 구분. 입은 별도 테두리를 사용하지 않음.'
                                : 'Draft를 켜면 Accent Map을 조정할 수 있음.',
                            style: TextStyle(color: muted, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Accent Map'),
                            subtitle: const Text(
                              '선택 색상에서 파생된 내부 구조와 깊이 표현',
                            ),
                            value: accentEnabled,
                            onChanged: draftMode
                                ? (value) =>
                                    setState(() => accentEnabled = value)
                                : null,
                          ),
                          _LabSlider(
                            label: '배 크기',
                            value: accentSize,
                            min: 0.70,
                            max: 1.30,
                            enabled: draftMode && accentEnabled,
                            onChanged: (value) =>
                                setState(() => accentSize = value),
                          ),
                          _LabSlider(
                            label: '배 위치',
                            value: accentY,
                            min: -6,
                            max: 6,
                            enabled: draftMode && accentEnabled,
                            decimals: 1,
                            onChanged: (value) =>
                                setState(() => accentY = value),
                          ),
                          _LabSlider(
                            label: 'Accent 밝기',
                            value: accentLightness,
                            min: 0.18,
                            max: 0.72,
                            enabled: draftMode && accentEnabled,
                            onChanged: (value) =>
                                setState(() => accentLightness = value),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  _Panel(
                    color: cardColor,
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      initiallyExpanded: false,
                      title: Text(
                        'Advanced Geometry',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        draftMode
                            ? '필요할 때만 여는 보조 조정값'
                            : 'Draft를 켜면 사용 가능',
                        style: TextStyle(color: muted, fontSize: 13),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: draftMode ? resetDraft : null,
                            child: const Text('Reset'),
                          ),
                          const Icon(Icons.expand_more),
                        ],
                      ),
                      children: [
                        if (shape == ShapeKind.dolphin) ...[
                          _LabSlider(
                            label: '이마',
                            value: forehead,
                            min: -5,
                            max: 5,
                            enabled: draftMode,
                            decimals: 1,
                            onChanged: (value) =>
                                setState(() => forehead = value),
                          ),
                          _LabSlider(
                            label: '주둥이',
                            value: snout,
                            min: -6,
                            max: 6,
                            enabled: draftMode,
                            decimals: 1,
                            onChanged: (value) => setState(() => snout = value),
                          ),
                          _LabSlider(
                            label: '몸통',
                            value: bodyDepth,
                            min: 0.82,
                            max: 1.18,
                            enabled: draftMode,
                            onChanged: (value) =>
                                setState(() => bodyDepth = value),
                          ),
                          _LabSlider(
                            label: '꼬리',
                            value: tailScale,
                            min: 0.78,
                            max: 1.25,
                            enabled: draftMode,
                            onChanged: (value) =>
                                setState(() => tailScale = value),
                          ),
                          const Divider(height: 24),
                        ],
                        _LabSlider(
                          label: 'Overall',
                          value: overallScale,
                          min: 0.80,
                          max: 1.20,
                          enabled: draftMode,
                          onChanged: (value) =>
                              setState(() => overallScale = value),
                        ),
                        _LabSlider(
                          label: 'Width',
                          value: scaleX,
                          min: 0.80,
                          max: 1.20,
                          enabled: draftMode,
                          onChanged: (value) =>
                              setState(() => scaleX = value),
                        ),
                        _LabSlider(
                          label: 'Height',
                          value: scaleY,
                          min: 0.80,
                          max: 1.20,
                          enabled: draftMode,
                          onChanged: (value) =>
                              setState(() => scaleY = value),
                        ),
                        _LabSlider(
                          label: 'X',
                          value: offsetX,
                          min: -8,
                          max: 8,
                          enabled: draftMode,
                          decimals: 1,
                          onChanged: (value) =>
                              setState(() => offsetX = value),
                        ),
                        _LabSlider(
                          label: 'Y',
                          value: offsetY,
                          min: -8,
                          max: 8,
                          enabled: draftMode,
                          decimals: 1,
                          onChanged: (value) =>
                              setState(() => offsetY = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Shape Lab은 Overlay·권한·잠금 로직을 로드하지 않는 독립 경량 엔트리포인트입니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 12),
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


ShapeBlueprint _buildDolphinDraftBlueprint({
  required double forehead,
  required double snout,
  required double bodyDepth,
  required double tailScale,
  required bool accentEnabled,
  required double accentSize,
  required double accentY,
}) {
  final source = shapeBlueprintFor(ShapeKind.dolphin)!;

  Offset tune(Offset point) {
    var x = point.dx;
    var y = point.dy;

    // Head is on the left side of the approved trace. Apply the same
    // deformation to body and Accent Map so internal regions stay registered.
    if (x <= 48 && y <= 39) {
      final influence = ((48 - x) / 40).clamp(0.0, 1.0);
      y -= forehead * influence;
    }

    if (x <= 27 && y >= 36 && y <= 53) {
      final influence = ((27 - x) / 19).clamp(0.0, 1.0);
      x -= snout * influence;
    }

    if (x >= 30 && x <= 76 && y >= 46) {
      y = 50 + (y - 50) * bodyDepth;
    }

    if (x >= 75) {
      x = 75 + (x - 75) * tailScale;
      y = 56 + (y - 56) * tailScale;
    }

    return Offset(x, y);
  }

  final parts = <ShapeTracePart>[];

  for (final sourcePart in source.parts) {
    final isAccentPart =
        sourcePart.role.isLightAccent || sourcePart.role.isDepthAccent;
    if (isAccentPart && !accentEnabled) continue;

    var points = sourcePart.points.map(tune).toList(growable: false);

    // Belly sizing/position is intentionally local. Mouth and fin regions
    // remain locked to the approved map while the belly can still be tuned.
    if (sourcePart.role == ShapePartRole.bellyAccent && points.isNotEmpty) {
      final center = points.fold<Offset>(
            Offset.zero,
            (sum, point) => sum + point,
          ) /
          points.length.toDouble();
      points = points
          .map(
            (point) => Offset(
              center.dx + (point.dx - center.dx) * accentSize,
              center.dy +
                  (point.dy - center.dy) * accentSize +
                  accentY,
            ),
          )
          .toList(growable: false);
    }

    parts.add(
      ShapeTracePart(
        role: sourcePart.role,
        points: points,
        smooth: sourcePart.smooth,
      ),
    );
  }

  return ShapeBlueprint(
    kind: ShapeKind.dolphin,
    viewBox: source.viewBox,
    designCenter: source.designCenter,
    referenceRadius: source.referenceRadius,
    opticalBounds: source.opticalBounds,
    parts: parts,
  );
}

class _DraftTransform {
  const _DraftTransform({
    required this.enabled,
    required this.overallScale,
    required this.scaleX,
    required this.scaleY,
    required this.offsetX,
    required this.offsetY,
  });

  final bool enabled;
  final double overallScale;
  final double scaleX;
  final double scaleY;
  final double offsetX;
  final double offsetY;
}


class _AnimatedColorToken extends StatelessWidget {
  const _AnimatedColorToken({
    required this.shape,
    required this.tone,
    required this.background,
    required this.phase,
  });

  final ShapeKind shape;
  final ShapeTone tone;
  final Color background;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: CustomPaint(
        painter: LockTokenPainter(
          LockToken(shape: shape, tone: tone),
          texture: ShapeTexture.glossy,
          effectPhase: phase,
        ),
      ),
    );
  }
}

class _TokenPreview extends StatelessWidget {
  const _TokenPreview({
    required this.shape,
    required this.tone,
    required this.texture,
    required this.background,
    required this.transform,
    this.blueprintOverride,
    this.accentLightness = 0.48,
  });

  final ShapeKind shape;
  final ShapeTone tone;
  final ShapeTexture texture;
  final Color background;
  final _DraftTransform transform;
  final ShapeBlueprint? blueprintOverride;
  final double accentLightness;

  @override
  Widget build(BuildContext context) {
    final token = LockToken(shape: shape, tone: tone);
    return ColoredBox(
      color: background,
      child: CustomPaint(
        painter: _ShapeLabPainter(
          token: token,
          texture: texture,
          transform: transform,
          blueprintOverride: blueprintOverride,
          accentLightness: accentLightness,
        ),
      ),
    );
  }
}

class _ShapeLabPainter extends CustomPainter {
  const _ShapeLabPainter({
    required this.token,
    required this.texture,
    required this.transform,
    this.blueprintOverride,
    this.accentLightness = 0.48,
  });

  final LockToken token;
  final ShapeTexture texture;
  final _DraftTransform transform;
  final ShapeBlueprint? blueprintOverride;
  final double accentLightness;

  @override
  void paint(Canvas canvas, Size size) {
    final delegate = LockTokenPainter(
      token,
      texture: texture,
      blueprintOverride: blueprintOverride,
      accentLightness: accentLightness,
    );
    if (!transform.enabled) {
      delegate.paint(canvas, size);
      return;
    }

    final center = size.center(Offset.zero);
    canvas.save();
    canvas.translate(
      center.dx + transform.offsetX,
      center.dy + transform.offsetY,
    );
    canvas.scale(
      transform.overallScale * transform.scaleX,
      transform.overallScale * transform.scaleY,
    );
    canvas.translate(-center.dx, -center.dy);
    delegate.paint(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShapeLabPainter oldDelegate) {
    return oldDelegate.token.id != token.id ||
        oldDelegate.texture != texture ||
        oldDelegate.transform.enabled != transform.enabled ||
        oldDelegate.transform.overallScale != transform.overallScale ||
        oldDelegate.transform.scaleX != transform.scaleX ||
        oldDelegate.transform.scaleY != transform.scaleY ||
        oldDelegate.transform.offsetX != transform.offsetX ||
        oldDelegate.transform.offsetY != transform.offsetY ||
        oldDelegate.blueprintOverride != blueprintOverride ||
        oldDelegate.accentLightness != accentLightness;
  }
}

class _CompareToken extends StatelessWidget {
  const _CompareToken({
    required this.label,
    required this.shape,
    required this.tone,
    required this.texture,
    required this.background,
    this.transform = const _DraftTransform(
      enabled: false,
      overallScale: 1,
      scaleX: 1,
      scaleY: 1,
      offsetX: 0,
      offsetY: 0,
    ),
    this.blueprintOverride,
    this.accentLightness = 0.48,
  });

  final String label;
  final ShapeKind shape;
  final ShapeTone tone;
  final ShapeTexture texture;
  final Color background;
  final _DraftTransform transform;
  final ShapeBlueprint? blueprintOverride;
  final double accentLightness;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox.square(
          dimension: 58,
          child: _TokenPreview(
            shape: shape,
            tone: tone,
            texture: texture,
            background: background,
            transform: transform,
            blueprintOverride: blueprintOverride,
            accentLightness: accentLightness,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.child,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.40)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? scheme.primary : const Color(0x247B8190),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              SizedBox.square(
                dimension: 116,
                child: Center(
                  child: Transform.scale(scale: 2, child: child),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1A7B8190)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.label, required this.draft});

  final String label;
  final bool draft;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: draft ? const Color(0xFFFFEAC2) : const Color(0xFFDFF7E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: TextStyle(
            color: draft ? const Color(0xFF8E5D00) : const Color(0xFF18794E),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.values,
    required this.text,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) text;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 185,
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: values
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(text(item)),
              ),
            )
            .toList(growable: false),
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
      ),
    );
  }
}

class _ToggleField extends StatelessWidget {
  const _ToggleField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(label, style: const TextStyle(fontSize: 13)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _LabSlider extends StatelessWidget {
  const _LabSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
    this.decimals = 2,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: enabled ? onChanged : null,
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(
            value.toStringAsFixed(decimals),
            textAlign: TextAlign.right,
            style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
          ),
        ),
      ],
    );
  }
}
