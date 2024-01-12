import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machines/page.dart';

class ToMachine extends StrongTypeRoute {
  final String machine;

  ToMachine({required super.parent, required this.machine}) : super(uri: parent!.uriJoin(machine));

  factory ToMachine.parse(MatchTo to) {
    String? machine = to.params["machine"];
    assert(machine != null, "machine arg should not be null");

    ToMachines parent = ToMachines.parse(to);
    return parent.machine(machine: machine!);
  }

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/machine page");
  }
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/machine page");
}
