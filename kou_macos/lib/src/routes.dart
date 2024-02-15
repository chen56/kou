// ignore_for_file: non_constant_identifier_names,camel_case_types

import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machines/[machine]/page.dart';
import 'package:kou_macos/src/routes/machines/page.dart';
import 'package:kou_macos/src/routes/page.dart';

final rootRoute = ToRoot();

Routes routes = Routes.create();

class Routes {
  static List<ToHandler> _handlers = List.empty(growable: true);

  final root = def(ToRoot2());
  final ToMachines2 machines = def(ToMachines2());
  final ToMachine2 machines_machine = def(ToMachine2());
  late To rootTo;
  late ToRouter router;

  Routes.create() {
    rootTo = To.fromHandlers(_handlers);
    router = ToRouter(root: rootTo);

    // reset static var
    _handlers = List.empty(growable: true);
  }

  static R def<R extends ToHandler>(R handler) {
    _handlers.add(handler);
    return handler;
  }
}
