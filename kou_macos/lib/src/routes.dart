import 'package:kou_macos/src/common/router.dart';
import 'package:kou_macos/src/routes/layout.dart' as layout_;
import 'package:kou_macos/src/routes/page.dart' as page_;
import 'package:kou_macos/src/routes/tencent_cloud/page.dart' as page_tencent_cloud;

main() {
  RouteMeta(path: "/", layout: const layout_.Layout(), page: PageMeta(builder: page_.page), routes: [
    RouteMeta(path: "tencent_cloud", page: PageMeta(builder: page_.page)),
    RouteMeta(path: "note", page: PageMeta(builder: page_tencent_cloud.createPage)),
  ]);
}
