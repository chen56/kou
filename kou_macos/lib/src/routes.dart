import 'package:kou_macos/src/common/router.dart';
import 'package:kou_macos/src/routes/layout.dart' as layout_;
import 'package:kou_macos/src/routes/page.dart' as page_;
import 'package:kou_macos/src/routes/tencent_cloud/page.dart' as page_tencent_cloud;

// 未来此未见可以自动生成
KRoute createRootRoute() {
  return KRoute(name: "/", layout: layout_.layout, page: page_.page, routes: [
    KRoute(name: "tencent_cloud", page: page_tencent_cloud.page),
  ]);
}
