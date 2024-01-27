// ignore_for_file: non_constant_identifier_names,camel_case_types

import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/layout.widget.dart' as root_layout;
import 'package:kou_macos/src/routes/machines/[machine]/page.dart';
import 'package:kou_macos/src/routes/machines/page.dart';
import 'package:kou_macos/src/routes/page.dart';

final rootRoute = ToRoot();

ToRouter createRouter() {
  To r = To("/", pageSpecBuilder: ToRoot.parse, layout: root_layout.layout, children: [
    To("machines", pageSpecBuilder: ToMachines.parse, children: [
      To("[machine]", pageSpecBuilder: ToMachine.parse),
    ]),
  ]);
  return ToRouter(root: r, rootToPage: rootRoute);
}
