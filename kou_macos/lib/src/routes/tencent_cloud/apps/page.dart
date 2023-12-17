import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/tencent_cloud/apps/[app]/page.dart';

class AppsRoute extends RouteInstance {
  AppsRoute({required RouteInstance parent}) : super(uri: parent.uriJoin("apps"));

  AppRoute app(String appName) => AppRoute(parent: this, appName: appName);

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/tencent_cloud/apps");
  }
}
