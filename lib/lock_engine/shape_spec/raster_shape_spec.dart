import 'dart:math' as math;
import 'dart:ui' as ui;

/// Runtime framing in texture pixels, independent of ShapeKind.
/// Swim pose variants share the same canonical runtime frame.
class RasterShapeMetadata {
  RasterShapeMetadata.fromJson(Map<String, dynamic> json)
    : shapeId = json['shape_id'] as String,
      runtimeCanvas = _size(json['runtime_canvas'] as List),
      contentBbox = _rect(json['content_bbox'] as List),
      anchor = _offset(json['anchor'] as List),
      displayScale = (json['display_scale'] as num).toDouble(),
      safetyPaddingRatio = (json['safety_padding_ratio'] as num).toDouble(),
      runtimeSourceHash = json['runtime_source_hash'] as String,
      aurora = Map<String, dynamic>.from(json['aurora'] as Map),
      layers = Map<String, dynamic>.from(json['layers'] as Map),
      swim = Map<String, dynamic>.from(
        json['swim'] as Map? ?? const <String, dynamic>{},
      ),
      idle = Map<String, dynamic>.from(
        json['idle'] as Map? ?? const <String, dynamic>{},
      ) {
    final canvas = ui.Offset.zero & runtimeCanvas;
    if (displayScale <= 0 ||
        contentBbox.isEmpty ||
        !canvas.contains(contentBbox.topLeft) ||
        !canvas.contains(contentBbox.bottomRight) ||
        safetyPaddingRatio <= 0 ||
        !canvas.contains(anchor)) {
      throw FormatException('Invalid padded raster metadata: $shapeId');
    }
  }

  final String shapeId;
  final ui.Size runtimeCanvas;
  final ui.Rect contentBbox;
  final ui.Offset anchor;
  final double displayScale;
  final double safetyPaddingRatio;
  final String runtimeSourceHash;
  final Map<String, dynamic> layers;
  final Map<String, dynamic> aurora;
  final Map<String, dynamic> swim;
  final Map<String, dynamic> idle;

  static ui.Size _size(List v) =>
      ui.Size((v[0] as num).toDouble(), (v[1] as num).toDouble());
  static ui.Offset _offset(List v) =>
      ui.Offset((v[0] as num).toDouble(), (v[1] as num).toDouble());
  static ui.Rect _rect(List v) => ui.Rect.fromLTRB(
    (v[0] as num).toDouble(),
    (v[1] as num).toDouble(),
    (v[2] as num).toDouble(),
    (v[3] as num).toDouble(),
  );

  ui.Rect destination(ui.Offset center, double radius) {
    final scale =
        radius *
        2 *
        displayScale /
        math.max(contentBbox.width, contentBbox.height);
    return ui.Rect.fromLTWH(
      center.dx - anchor.dx * scale,
      center.dy - anchor.dy * scale,
      runtimeCanvas.width * scale,
      runtimeCanvas.height * scale,
    );
  }

  String asset(String layer) => (layers[layer] as Map)['asset'] as String;

  List<String> swimAssetParts(String pose, String layer) {
    final poses = swim['poses'] as Map?;
    final poseConfig = poses?[pose] as Map?;
    final poseLayers = poseConfig?['layers'] as Map?;
    final values = poseLayers?[layer] as List?;
    if (values == null) return const <String>[];
    return values.cast<String>();
  }
}

class RasterPoseImages {
  const RasterPoseImages({
    this.master,
    required this.paletteBase,
    required this.fixedFinish,
  });

  final ui.Image? master;
  final ui.Image paletteBase;
  final ui.Image fixedFinish;
}

class RasterShapeSpec {
  const RasterShapeSpec({
    required this.metadata,
    required this.master,
    required this.paletteBase,
    required this.fixedFinish,
    this.swimPoses = const <String, RasterPoseImages>{},
  });

  final RasterShapeMetadata metadata;
  final ui.Image master;
  final ui.Image paletteBase;
  final ui.Image fixedFinish;
  final Map<String, RasterPoseImages> swimPoses;

  RasterPoseImages imagesForPose(String pose) {
    if (pose == 's0') {
      return RasterPoseImages(
        master: master,
        paletteBase: paletteBase,
        fixedFinish: fixedFinish,
      );
    }
    return swimPoses[pose] ??
        RasterPoseImages(
          master: master,
          paletteBase: paletteBase,
          fixedFinish: fixedFinish,
        );
  }
}
