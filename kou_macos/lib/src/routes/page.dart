// ignore_for_file: non_constant_identifier_names,camel_case_types
import 'package:flutter/cupertino.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machines/page.dart';

class ToRoot extends PageSpec {
  ToRoot();

  factory ToRoot.parse(PageSpec parent, ToLocation to) {
    return ToRoot();
  }

  ToMachines get machines => ToMachines(parent: this);

  @override
  Uri get uri => Uri.parse("/");

  @override
  Widget build(BuildContext context) {
    return const Text("/  root page");
  }

  @override
  ToRoot get parent => this;
}

class ToRoot2 extends TypedRoute {
  late final ToMachines2 machines;

  ToRoot2() : super("/") {
    machines = add(ToMachines2(parent: this));
  }
}
