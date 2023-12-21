import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machine/apps/[app]/page.dart';

class AppsRoute extends RouteInstance {
  const AppsRoute({required super.parent, required super.uri});

  AppRoute app(String appName) => AppRoute(parent: this, uri: parent!.uriJoin("apps/$appName"));

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/machine/apps");
  }
}
