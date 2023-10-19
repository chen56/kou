import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';

AppRoute appRoute(RouteInstance parent) {
  return (String appName) => RouteInstance(uri: Uri.parse("uri$parent.name"));
}

typedef AppRoute = RouteInstance Function(String appName);

Widget page(BuildContext context, RouteState state) {
  return const Text("/tencent_cloud page");
}
