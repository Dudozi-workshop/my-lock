import 'package:flutter/services.dart';

String resolveStyleLabInitialStyle({
  required String fallbackStyleId,
}) {
  final uri = Uri.base;
  if (uri.queryParameters['lab'] != 'style') {
    return fallbackStyleId;
  }
  final styleId = uri.queryParameters['style'];
  if (styleId == null || styleId.isEmpty) {
    return fallbackStyleId;
  }
  return styleId;
}

Future<void> syncStyleLabUrl(String styleId) {
  final nextQuery = Map<String, String>.from(Uri.base.queryParameters)
    ..['lab'] = 'style'
    ..['style'] = styleId;
  final nextUri = Uri.base.replace(queryParameters: nextQuery);
  return SystemNavigator.routeInformationUpdated(
    uri: nextUri,
    replace: true,
  );
}
