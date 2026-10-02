import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'shape_spec/shape_spec_registry.dart';

class RasterShapeBootstrap extends StatefulWidget {
  const RasterShapeBootstrap({
    super.key,
    required this.child,
    this.backgroundColor = appBackground,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  State<RasterShapeBootstrap> createState() => _RasterShapeBootstrapState();
}

class _RasterShapeBootstrapState extends State<RasterShapeBootstrap> {
  late final Future<void> _future =
      ShapeSpecRegistry.instance.loadRasterShapes();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: widget.backgroundColor,
            body: const Center(
              child: CircularProgressIndicator(
                color: brandPurple,
                strokeWidth: 2.4,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: widget.backgroundColor,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectableText(
                  'Raster shape load failed:\n\n${snapshot.error}',
                ),
              ),
            ),
          );
        }

        return widget.child;
      },
    );
  }
}
