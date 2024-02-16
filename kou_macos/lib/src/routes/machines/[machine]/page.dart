import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';

class MachinePage extends ToPage {
  final String machine;

  MachinePage({required this.machine});

  factory MachinePage.parse(ToLocation to) {
    String? machine = to.params["machine"];
    assert(machine != null, "machine arg should not be null");

    return MachinePage(machine: machine!);
  }

  @override
  Uri get uri => Uri.parse("/machines/$machine");

  @override
  Widget build(BuildContext context) {
    return Text("/machine page : [$machine]");
  }
}

final class MachineHandler with ToHandler {
  MachineHandler() : super();

  @override
  String get uriTemplate => "/machines/[machine]";

  @override
  Widget build(BuildContext context, ToLocation location) {
    return Text("$uriTemplate : ${location.uri}");
  }

  Uri create({required String machine}) {
    //todo setup uri
    return Uri.parse("/machines/$machine");
  }
}
