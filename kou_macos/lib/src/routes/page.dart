// ignore_for_file: non_constant_identifier_names,camel_case_types
import 'package:flutter/cupertino.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machines/page.dart';

class RootRoute extends RouteInstance<Null> {
  RootRoute() : super(parent: null, uri: Uri.parse("/"));

  MachinesRoute get machines => MachinesRoute(parent: this);

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/  root page");
  }

  factory RootRoute.parse(MatchTo to) {
    return RootRoute();
  }
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/  root page");
}
