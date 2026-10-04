import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BuildInfo {
  const BuildInfo._();

  static const String previewVersion = String.fromEnvironment(
    'PREVIEW_VERSION',
    defaultValue: 'MAIN-2026.10.03-R01',
  );

  static const String purpose = String.fromEnvironment(
    'PREVIEW_PURPOSE',
    defaultValue: 'Actual app UI / UX / Runtime verification',
  );

  static const String status = String.fromEnvironment(
    'PREVIEW_STATUS',
    defaultValue: 'Production Preview',
  );

  static String get display => '$previewVersion · $purpose · $status';
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
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
