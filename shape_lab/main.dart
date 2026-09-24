import 'package:flutter/material.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';

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

class _ShapeLabPageState extends State<ShapeLabPage> {
  ShapeKind shape = ShapeKind.dolphin;
  ShapeTone tone = ShapeTone.blue;
  ShapeTexture texture = ShapeTexture.glossy;
  bool darkBackground = false;
  bool draftMode = false;

  double overallScale = 1.0;
  double scaleX = 1.0;
  double scaleY = 1.0;
  double offsetX = 0.0;
  double offsetY = 0.0;

  void resetDraft() {
    setState(() {
      overallScale = 1.0;
      scaleX = 1.0;
      scaleY = 1.0;
      offsetX = 0.0;
      offsetY = 0.0;
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
                          label: 'Shape',
                          value: shape,
                          values: ShapeKind.values,
                          text: (value) => value.label,
                          onChanged: (value) => setState(() => shape = value),
                        ),
                        _DropdownField<ShapeTone>(
                          label: 'Tone',
                          value: tone,
                          values: ShapeTone.values,
                          text: (value) => value.label,
                          onChanged: (value) => setState(() => tone = value),
                        ),
                        _DropdownField<ShapeTexture>(
                          label: 'Surface',
                          value: texture,
                          values: ShapeTexture.values,
                          text: (value) => value.label,
                          onChanged: (value) => setState(() => texture = value),
                        ),
                        _ToggleField(
                          label: 'Dark BG',
                          value: darkBackground,
                          onChanged: (value) =>
                              setState(() => darkBackground = value),
                        ),
                        _ToggleField(
                          label: 'Draft',
                          value: draftMode,
                          onChanged: (value) =>
                              setState(() => draftMode = value),
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
                            ),
                          ],
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Draft Geometry',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: draftMode ? resetDraft : null,
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                        Text(
                          draftMode
                              ? '실제 Painter 출력 위에 임시 변환만 적용. 확정 전 앱 코드에는 반영되지 않음.'
                              : 'APP EXACT에서는 변환 없이 실제 Painter 결과만 표시.',
                          style: TextStyle(color: muted, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
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

class _TokenPreview extends StatelessWidget {
  const _TokenPreview({
    required this.shape,
    required this.tone,
    required this.texture,
    required this.background,
    required this.transform,
  });

  final ShapeKind shape;
  final ShapeTone tone;
  final ShapeTexture texture;
  final Color background;
  final _DraftTransform transform;

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
  });

  final LockToken token;
  final ShapeTexture texture;
  final _DraftTransform transform;

  @override
  void paint(Canvas canvas, Size size) {
    final delegate = LockTokenPainter(token, texture: texture);
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
        oldDelegate.transform.offsetY != transform.offsetY;
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
  });

  final String label;
  final ShapeKind shape;
  final ShapeTone tone;
  final ShapeTexture texture;
  final Color background;
  final _DraftTransform transform;

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
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
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
