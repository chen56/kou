// ignore_for_file: non_constant_identifier_names,camel_case_types
import 'package:flutter/cupertino.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machines/page.dart';

class ToRoot extends StaticTypeRoute {
  ToRoot();

  factory ToRoot.parse(MatchTo to) {
    return ToRoot();
  }

  ToMachines get machines => ToMachines(parent: this);

  @override
  Uri get uri => Uri.parse("/");

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/  root page");
  }

  @override
  ToRoot get parent => this;
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/  root page");
}
