import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';

class AppRoute extends RouteInstance {
  const AppRoute({required super.parent, required super.uri});

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/machine/apps/app page");
  }
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/machine page");
}
