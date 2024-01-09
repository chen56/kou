import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';

class MachineRoute extends RouteInstance {
  final String machine;

  MachineRoute({required super.parent, required this.machine}) : super(uri: parent.uriJoin(machine));

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/machine page");
  }
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/machine page");
}
