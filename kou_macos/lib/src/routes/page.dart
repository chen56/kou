// ignore_for_file: non_constant_identifier_names,camel_case_types
import 'package:flutter/cupertino.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machines/page.dart';

class ToRoot extends StrongTypeRoute {
  ToRoot() : super(parent: null, uri: Uri.parse("/"));

  ToMachines get machines => ToMachines(parent: this);

  @override
  Widget page(BuildContext context, RouteState state) {
    return const Text("/  root page");
  }

  factory ToRoot.parse(MatchTo to) {
    return ToRoot();
  }
}

Widget page(BuildContext context, RouteState state) {
  return const Text("/  root page");
}
