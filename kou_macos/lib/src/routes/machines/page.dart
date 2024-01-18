import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/page.dart';

import '[machine]/page.dart';

class ToMachines extends StrongTypeRoute {
  ToMachines({required this.parent});

  ToMachine machine({required String machine}) => ToMachine(parent: this, machine: machine);

  factory ToMachines.parse(MatchTo to) {
    ToRoot parent = ToRoot.parse(to);
    return parent.machines;
  }

  @override
  final ToRoot parent;

  @override
  Uri get uri => parent.uri.join("machines");

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/machine page");
  }
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/machine page");
}
