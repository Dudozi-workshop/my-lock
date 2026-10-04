import 'package:flutter/material.dart';
import 'package:my_lock/lock_engine/models.dart';
import 'package:my_lock/lock_engine/raster_shape_bootstrap.dart';
import 'package:my_lock/lock_engine/shape_painter.dart';
import 'package:my_lock/lock_engine/shape_spec/shape_spec_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShapeSpecRegistry.instance.load();
  runApp(const _StarfishMotionLabApp());
}

class _StarfishMotionLabApp extends StatelessWidget {
  const _StarfishMotionLabApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY LOCK · Starfish Motion QA',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF7257F5)),
      home: const RasterShapeBootstrap(child: _StarfishMotionQa()),
    );
  }
}

class _StarfishMotionQa extends StatelessWidget {
  const _StarfishMotionQa();

  Widget _star(double size, {ShapeTone tone = ShapeTone.coralPink}) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: LockTokenPainter(
          LockToken(shape: ShapeKind.starfish, tone: tone),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F5FA);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            const Text(
              'MY LOCK · Starfish micro-idle Runtime QA',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Motion Candidate v1 · Static Production Master locked',
              style: TextStyle(color: Color(0xFF6D7382), fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              height: 390,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE4E1EA)),
              ),
              child: Center(child: _star(300)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE4E1EA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('58px APP EXACT', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _star(58),
                      _star(58, tone: ShapeTone.deepOcean),
                      _star(58, tone: ShapeTone.aquaMint),
                      _star(58, tone: ShapeTone.lavender),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFBFE8E7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Multi-instance phase offset', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [_star(82), _star(82), _star(82)],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Check: sway가 과하지 않은지 · 58px 실루엣 유지 · breathing이 찌그러짐처럼 보이지 않는지 · 여러 개가 완전히 동시에 움직이지 않는지',
              style: TextStyle(color: Color(0xFF6D7382), fontSize: 11.5, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
