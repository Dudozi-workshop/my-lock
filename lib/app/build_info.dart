import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BuildInfo {
  const BuildInfo._();

  static const String previewVersion = String.fromEnvironment(
    'PREVIEW_VERSION',
    defaultValue: '000',
  );

  static String get display => 'PREVIEW $previewVersion';
}

class BuildStamp extends StatelessWidget {
  const BuildStamp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    return IgnorePointer(
      child: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xCC26232C),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              child: Text(
                BuildInfo.display,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
