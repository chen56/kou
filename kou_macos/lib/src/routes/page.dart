// ignore_for_file: non_constant_identifier_names,camel_case_types
import 'package:flutter/cupertino.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/tencent_cloud/page.dart';

class Root extends RouteInstance {
  Root() : super(uri: Uri.parse("/"));

  TencentCloud get tencent_cloud => TencentCloud(parent: this);
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/  root page");
}
