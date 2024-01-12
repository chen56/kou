import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/page.dart';

import '[machine]/page.dart';

class ToMachines extends StrongTypeRoute {
  ToMachines({required super.parent}) : super(uri: parent!.uriJoin("machines"));

  ToMachine machine({required String machine}) => ToMachine(parent: this, machine: machine);

  factory ToMachines.parse(MatchTo to) {
    ToRoot parent = ToRoot.parse(to);
    return parent.machines;
  }

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/machine page");
  }

  @override
  Uri get uri => parent!.uriJoin("machines");
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/machine page");
}
