import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machine/apps/page.dart';

class VMRoute extends RouteInstance {
  const VMRoute({required super.parent, required super.uri});

  AppsRoute get apps => AppsRoute(parent: this, uri: uriJoin("apps"));

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/machine page");
  }
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/machine page");
}
