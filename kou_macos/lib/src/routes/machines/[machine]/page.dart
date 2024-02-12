import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes.dart';
import 'package:kou_macos/src/routes/machines/page.dart';

class ToMachine extends PageSpec {
  final String machine;

  ToMachine({required this.parent, required this.machine});

  factory ToMachine.parse(PageSpec parent, ToLocation to) {
    String? machine = to.params["machine"];
    assert(machine != null, "machine arg should not be null");

    return (parent as ToMachines).machine(machine: machine!);
  }

  @override
  final ToMachines parent;

  @override
  Uri get uri => parent.uri.join(machine);

  @override
  Widget build(BuildContext context) {
    return Text("/machine page : [$machine]");
  }
}

class ToMachine2 extends MyRouteBase {
  static const String key = "[machine]";

  ToMachine2() : super(part: key);

  @override
  Widget build(BuildContext context, ToLocation location) {
    return Text("$key : ${location.uri}");
  }

  Uri create({required String machine}) {
    //todo setup uri
    return Uri.parse("/machines/$machine");
  }
}
