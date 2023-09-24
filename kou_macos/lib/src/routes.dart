import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/layout.dart' as layout_;
import 'package:kou_macos/src/routes/page.dart' as page_;
import 'package:kou_macos/src/routes/tencent_cloud/page.dart' as page_tencent_cloud;

// 将来天应从目录结构自动生成
ToConfig createGoConfig() {
  To root = To(name: "/", page: page_.page, layout: layout_.layout, children: [
    To(name: "/", page: page_.page, children: [
      To(name: "tencent_cloud", layout: layout_.layout, page: page_tencent_cloud.page),
    ])
  ]);
  return ToConfig(root: root);
}
