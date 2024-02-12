import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes.dart';
import 'package:kou_macos/src/routes/page.dart';

import '[machine]/page.dart';

class ToMachines extends PageSpec {
  ToMachines({required this.parent});

  ToMachine machine({required String machine}) => ToMachine(parent: this, machine: machine);

  factory ToMachines.parse(PageSpec parent, ToLocation to) {
    return (parent as ToRoot).machines;
  }

  @override
  final ToRoot parent;

  @override
  Uri get uri => parent.uri.join("machines");

  @override
  Widget build(BuildContext context) {
    return const Text("/machine page");
  }
}

class ToMachines2 extends MyRouteBase {
  static const String key = "machines";

  ToMachines2({super.children}) : super(part: key);

  factory ToMachines2.parse(PageSpec parent, ToLocation to) {
    return (parent as ToRoot2).machines;
  }

  ToMachine2 get machine => child(ToMachine2.key) as ToMachine2;

  @override
  Widget build(BuildContext context, ToLocation location) {
    return Text("$key : ${location.uri}");
  }
}
