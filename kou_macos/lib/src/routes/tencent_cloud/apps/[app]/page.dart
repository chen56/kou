import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';

// AppRoute appRoute(RouteInstance parent) {
//   return (String appName) => RouteInstance(uri: Uri.parse("uri$parent.name"));
// }

// typedef AppRoute = RouteInstance Function(String appName);
class AppRoute extends RouteInstance {
  AppRoute({required RouteInstance parent, required String appName}) : super(uri: parent.uriJoin("apps/$appName"));

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/tencent_cloud/apps/app page");
  }
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/tencent_cloud page");
}
