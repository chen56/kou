import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/page.dart';
import 'package:kou_macos/src/routes/tencent_cloud/apps/page.dart';

class TencentCloud extends RouteInstance {
  TencentCloud({required RootPage parent}) : super(uri: parent.uriJoin("tencent_cloud"));

  AppsRoute get apps => AppsRoute(parent: this);

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/tencent_cloud page");
  }
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/tencent_cloud page");
}
