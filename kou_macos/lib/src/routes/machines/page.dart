import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/page.dart';

import '[machine]/page.dart';

class MachinesRoute extends RouteInstance<RootRoute> {
  MachinesRoute({required super.parent}) : super(uri: parent.uriJoin("machines"));

  MachineRoute machine({required String machine}) => MachineRoute(parent: this, machine: machine);

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/machine page");
  }
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/machine page");
}
