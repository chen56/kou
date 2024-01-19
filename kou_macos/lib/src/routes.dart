// ignore_for_file: non_constant_identifier_names,camel_case_types

import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/layout.widget.dart' as root_layout;
import 'package:kou_macos/src/routes/machines/[machine]/page.dart' as machine;
import 'package:kou_macos/src/routes/machines/[machine]/page.dart';
import 'package:kou_macos/src/routes/machines/page.dart' as machines;
import 'package:kou_macos/src/routes/machines/page.dart';
import 'package:kou_macos/src/routes/page.dart' as root;
import 'package:kou_macos/src/routes/page.dart';

final rootRoute = ToRoot();

ToRouter createRouter() {
  To r = To("/", page: root.page, parser: ToRoot.parse, layout: root_layout.layout, children: [
    To("machines", page: machines.page, parser: ToMachines.parse, children: [
      To("[machine]", page: machine.page, parser: ToMachine.parse),
    ]),
  ]);
  return ToRouter(root: r, rootToPage: rootRoute);
}