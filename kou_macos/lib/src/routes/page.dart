// ignore_for_file: non_constant_identifier_names,camel_case_types
import 'package:flutter/cupertino.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machine/page.dart';

class RootRoute extends RouteInstance {
  RootRoute() : super(parent: null, uri: Uri.parse("/"));

  VMRoute get machine => VMRoute(parent: this, uri: Uri.parse("/apps"));

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/  root page");
  }
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/  root page");
}
