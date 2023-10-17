// ignore_for_file: non_constant_identifier_names

import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/layout.widget.dart' as root_layout;
import 'package:kou_macos/src/routes/page.dart' as root;
import 'package:kou_macos/src/routes/tencent_cloud/page.dart' as tencent_cloud;
ToRouter router=createRouter();

ToRouter createRouter() {
  To rootRoute = To("/", page: root.page, layout: root_layout.layout, children: [
    To("tencent_cloud", page: tencent_cloud.page),
  ]);
  return ToRouter(root: rootRoute);
}



class Tos{
  static final To root = router.get("/");
  static final To tencent_cloud = router.get("/tencent_cloud");
}