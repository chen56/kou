// ignore_for_file: non_constant_identifier_names,camel_case_types

import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/layout.widget.dart' as root_layout;
import 'package:kou_macos/src/routes/page.dart' as root;
import 'package:kou_macos/src/routes/page.dart';
import 'package:kou_macos/src/routes/tencent_cloud/page.dart' as tencent_cloud;

final rootRoute = Root();

ToRouter createRouter() {
  To rootRoute = To("/", page: root.page, layout: root_layout.layout, children: [
    To("tencent_cloud", page: tencent_cloud.page),
  ]);
  return ToRouter(root: rootRoute);
}