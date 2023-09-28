import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/layout.dart' as root_layout;
import 'package:kou_macos/src/routes/page.dart' as root;
import 'package:kou_macos/src/routes/tencent_cloud/page.dart' as tencent_cloud;

// 将来天应从目录结构自动生成
ToRouter createRouter() {
  To rootRoute = To(dir: "/", page: root.page, layout: root_layout.layout, children: [
    To(dir: "tencent_cloud",  page: tencent_cloud.page),
  ]);
  return ToRouter(root: rootRoute);
}
