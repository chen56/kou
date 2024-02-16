// ignore_for_file: non_constant_identifier_names,camel_case_types

import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machines/[machine]/page.dart';
import 'package:kou_macos/src/routes/machines/page.dart';
import 'package:kou_macos/src/routes/page.dart';

final rootRoute = ToRoot();

ToRouter createRouter() {
  To root = To("/", page: ToRoot.parse, layout: ToRoot.layout, children: [
    To("machines", page: ToMachines.parse, children: [
      To("[machine]", page: ToMachine.parse),
    ]),
  ]);
  return ToRouter(root: root);
}

Routes routes = Routes();

class Routes {
  static List<ToHandler> _handlers = List.empty(growable: true);

  late final To rootTo;
  late final ToRouter router;

  final root = _def(ToRoot2());
  final machines = _def(ToMachines2());
  final machines_machine = _def(ToMachine2());

  Routes() {
    rootTo = To.fromHandlers(_handlers);
    router = ToRouter(root: rootTo);

    // reset static var
    _handlers = List.empty(growable: true);
  }

  static R _def<R extends ToHandler>(R handler) {
    _handlers.add(handler);
    return handler;
  }
}
