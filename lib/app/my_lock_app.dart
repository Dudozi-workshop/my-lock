import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/qa/background_composition_lab_screen.dart';
import '../features/qa/sea_turtle_app_integration_qa_screen.dart';
import '../features/qa/sea_turtle_body_with_rear_runtime_qa_screen.dart';
import '../features/qa/sea_turtle_front_flipper_runtime_qa_screen.dart';
import '../features/qa/sea_turtle_front_flipper_far_runtime_qa_screen.dart';
import '../features/qa/sea_turtle_shell_runtime_qa_screen.dart';
import '../features/qa/sea_turtle_underbelly_runtime_qa_screen.dart';
import '../features/qa/sea_turtle_whole_runtime_qa_screen.dart';
import '../features/qa/sea_turtle_production_runtime_qa_screen.dart';
import '../features/qa/sea_turtle_swim_runtime_qa_screen.dart';
import '../features/shell/root_shell.dart';
import '../lock_engine/raster_shape_bootstrap.dart';
import 'build_info.dart';
import 'theme.dart';

class MyLockApp extends StatelessWidget {
  const MyLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    final qa = Uri.base.queryParameters['qa'];
    final showShellRuntimeQa = kIsWeb && qa == 'sea-turtle-shell-runtime';
    final showFrontFlipperQa = kIsWeb && qa == 'front-flipper-outer';
    final showFrontFlipperFarQa = kIsWeb && qa == 'front-flipper-far';
    final showBodyWithRearQa = kIsWeb && qa == 'sea-turtle-body-with-rear';
    final showUnderbellyQa = kIsWeb && qa == 'sea-turtle-underbelly';
    final showWholeTurtleQa = kIsWeb && qa == 'sea-turtle-whole';
    final showSeaTurtleProductionQa =
        kIsWeb && qa == 'sea-turtle-production';
    final showSeaTurtleAppIntegrationQa =
        kIsWeb && (qa == 'sea-turtle-app-integration' || qa == 'sea-turtle-runtime-v3');
    final showSeaTurtleSwimQa = kIsWeb && qa == 'sea-turtle-swim-v1';
    final showBackgroundCompositionLab =
        kIsWeb && qa == 'background-composition';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LOCK',
      theme: buildMyLockTheme(),
      builder: (context, child) => Stack(
        children: [
          Positioned.fill(child: child ?? const SizedBox.shrink()),
          const Positioned.fill(child: BuildStamp()),
        ],
      ),
      home: RasterShapeBootstrap(
        child: showBackgroundCompositionLab
            ? const BackgroundCompositionLabScreen()
            : showSeaTurtleSwimQa
                ? const SeaTurtleSwimRuntimeQaScreen()
                : showSeaTurtleAppIntegrationQa
                ? const SeaTurtleAppIntegrationQaScreen()
            : showSeaTurtleProductionQa
                ? const SeaTurtleProductionRuntimeQaScreen()
                : showWholeTurtleQa
                ? const SeaTurtleWholeRuntimeQaScreen()
                : showShellRuntimeQa
                    ? const SeaTurtleShellRuntimeQaScreen()
                    : showFrontFlipperQa
                        ? const SeaTurtleFrontFlipperRuntimeQaScreen()
                        : showFrontFlipperFarQa
                            ? const SeaTurtleFrontFlipperFarRuntimeQaScreen()
                            : showBodyWithRearQa
                                ? const SeaTurtleBodyWithRearRuntimeQaScreen()
                                : showUnderbellyQa
                                    ? const SeaTurtleUnderbellyRuntimeQaScreen()
                                    : const RootShell(),
      ),
    );
  }
}
