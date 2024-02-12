// ignore_for_file: non_constant_identifier_names,camel_case_types

import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/layout.widget.dart' as root_layout;
import 'package:kou_macos/src/routes/machines/[machine]/page.dart';
import 'package:kou_macos/src/routes/machines/page.dart';
import 'package:kou_macos/src/routes/page.dart';

final rootRoute = ToRoot();

final router2 = createRouter2();
final rootRoute2 = router2.root as ToRoot2;

class MyRouteBase extends To {
  MyRouteBase({
    required String part,
    super.layout,
    super.layoutRetry,
    super.notFound,
    super.children,
  }) : super(part, pageSpecBuilder: TODORemove.parse);
}

ToRouter createRouter() {
  To r = To("/", pageSpecBuilder: ToRoot.parse, layout: root_layout.layout, children: [
    To("machines", pageSpecBuilder: ToMachines.parse, children: [
      To("[machine]", pageSpecBuilder: ToMachine.parse),
    ]),
  ]);
  return ToRouter(root: rootRoute2, rootToPage: rootRoute);
}

ToRouter createRouter2() {
  ToRoot2 r = ToRoot2(children: [
    ToMachines2(children: [
      ToMachine2(),
    ]),
  ]);
  return ToRouter(root: r, rootToPage: rootRoute);
}

Routes routes = Routes.create();

class Routes {
  Routes._();

  factory Routes.create() {
    // init static env

    var result = Routes._();

    // reset static env

    return result;
  }

  static R def<R extends To>(R to) {
    return to;
  }

  final root = def(ToRoot2());
  final ToMachines2 machines = def(ToMachines2());
  final ToMachine2 machines_machine = def(ToMachine2());
}
