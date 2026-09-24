import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'models.dart';

const _bodyAsset = 'assets/shapes/dolphin/dolphin_body.png';
const _mouthAsset = 'assets/shapes/dolphin/dolphin_mouth_accent.png';
const _bellyAsset = 'assets/shapes/dolphin/dolphin_belly_accent.png';

class DolphinMaskRenderer extends StatelessWidget {
  const DolphinMaskRenderer({
    super.key,
    required this.tone,
    required this.texture,
    this.showBody = true,
    this.showMouthAccent = true,
    this.showBellyAccent = true,
    this.showEye = false,
  });

  final ShapeTone tone;
  final ShapeTexture texture;
  final bool showBody;
  final bool showMouthAccent;
  final bool showBellyAccent;
  final bool showEye;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(tone);
    final bodyGradient = _bodyGradient(texture, colors.$1, colors.$2);
    final mouth = _lightAccent(colors.$1, 0.78);
    final belly = _lightAccent(colors.$1, 0.62);

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        if (showBody) ...[
          Opacity(
            opacity: texture == ShapeTexture.matte ? 0.10 : 0.20,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 2.2, sigmaY: 2.2),
              child: _solidMask(
                asset: _bodyAsset,
                color: Colors.white,
              ),
            ),
          ),
          _gradientMask(asset: _bodyAsset, gradient: bodyGradient),
        ],
        if (showBellyAccent)
          _solidMask(
            asset: _bellyAsset,
            color: belly.withValues(alpha: _accentAlpha(texture, false)),
          ),
        if (showMouthAccent)
          _solidMask(
            asset: _mouthAsset,
            color: mouth.withValues(alpha: _accentAlpha(texture, true)),
          ),
        if (showBody && texture != ShapeTexture.matte)
          _specularHighlight(texture),
        if (showBody && showEye)
          const Align(
            alignment: Alignment(0.46, -0.13),
            child: FractionallySizedBox(
              widthFactor: 0.032,
              heightFactor: 0.032,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF11131A),
                  shape: BoxShape.circle,
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.34,
                  heightFactor: 0.34,
                  alignment: Alignment(-0.35, -0.35),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _specularHighlight(ShapeTexture texture) {
    final opacity = switch (texture) {
      ShapeTexture.glass => 0.76,
      ShapeTexture.chrome => 0.66,
      ShapeTexture.metal => 0.40,
      ShapeTexture.jelly => 0.56,
      ShapeTexture.hologram => 0.42,
      ShapeTexture.glossy => 0.52,
      ShapeTexture.matte => 0.0,
    };

    return IgnorePointer(
      child: Align(
        alignment: const Alignment(-0.34, -0.47),
        child: FractionallySizedBox(
          widthFactor: 0.18,
          heightFactor: 0.075,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withValues(alpha: opacity),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _solidMask({
  required String asset,
  required Color color,
}) {
  return ColorFiltered(
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    child: Image.asset(
      asset,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      gaplessPlayback: true,
    ),
  );
}

Widget _gradientMask({
  required String asset,
  required Gradient gradient,
}) {
  return ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: gradient.createShader,
    child: Image.asset(
      asset,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      gaplessPlayback: true,
    ),
  );
}

Gradient _bodyGradient(
  ShapeTexture texture,
  Color light,
  Color dark,
) {
  switch (texture) {
    case ShapeTexture.glossy:
      return RadialGradient(
        center: const Alignment(-0.40, -0.50),
        radius: 1.20,
        colors: [
          Colors.white.withValues(alpha: 0.96),
          light,
          dark,
        ],
        stops: const [0.0, 0.40, 1.0],
      );
    case ShapeTexture.jelly:
      return RadialGradient(
        center: const Alignment(-0.34, -0.45),
        radius: 1.16,
        colors: [
          Colors.white.withValues(alpha: 0.88),
          light.withValues(alpha: 0.90),
          dark.withValues(alpha: 0.94),
        ],
        stops: const [0.0, 0.42, 1.0],
      );
    case ShapeTexture.glass:
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Color.lerp(light, Colors.white, 0.44)!,
          light,
          Color.lerp(light, dark, 0.60)!,
          dark,
        ],
        stops: const [0.0, 0.18, 0.43, 0.72, 1.0],
      );
    case ShapeTexture.metal:
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          light,
          const Color(0xFFF2F3F7),
          Color.lerp(light, dark, 0.45)!,
          dark,
        ],
        stops: const [0.0, 0.34, 0.61, 1.0],
      );
    case ShapeTexture.chrome:
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          light,
          const Color(0xFF565866),
          Colors.white,
          dark,
        ],
        stops: const [0.0, 0.18, 0.48, 0.64, 1.0],
      );
    case ShapeTexture.hologram:
      return const SweepGradient(
        colors: [
          Color(0xFFFF87CD),
          Color(0xFF8BD8FF),
          Color(0xFF9EF3D2),
          Color(0xFFFFE27A),
          Color(0xFFC69CFF),
          Color(0xFFFF87CD),
        ],
      );
    case ShapeTexture.matte:
      return LinearGradient(colors: [light, light]);
  }
}

double _accentAlpha(ShapeTexture texture, bool mouth) {
  return switch (texture) {
    ShapeTexture.glossy => mouth ? 0.94 : 0.84,
    ShapeTexture.jelly => mouth ? 0.78 : 0.70,
    ShapeTexture.glass => mouth ? 0.72 : 0.62,
    ShapeTexture.matte => mouth ? 0.92 : 0.84,
    ShapeTexture.metal => mouth ? 0.74 : 0.66,
    ShapeTexture.chrome => mouth ? 0.66 : 0.58,
    ShapeTexture.hologram => mouth ? 0.60 : 0.50,
  };
}

Color _lightAccent(Color base, double amount) =>
    Color.lerp(base, Colors.white, amount)!;

(Color, Color) _toneColors(ShapeTone tone) {
  switch (tone) {
    case ShapeTone.pink:
      return (const Color(0xFFFF8FD1), const Color(0xFFE656AB));
    case ShapeTone.blue:
      return (const Color(0xFF79BFFF), const Color(0xFF3F6FEA));
    case ShapeTone.yellow:
      return (const Color(0xFFFFDA72), const Color(0xFFF0A632));
    case ShapeTone.purple:
      return (const Color(0xFFC7A4FF), const Color(0xFF7447D9));
    case ShapeTone.mint:
      return (const Color(0xFF9EF3D2), const Color(0xFF2FAF89));
    case ShapeTone.black:
      return (const Color(0xFF5A5A64), const Color(0xFF17171D));
    case ShapeTone.white:
      return (const Color(0xFFFFFFFF), const Color(0xFFD9D9E2));
  }
}
