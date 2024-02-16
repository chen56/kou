import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';

class ToMachine extends ToPage {
  final String machine;

  ToMachine({required this.machine});

  factory ToMachine.parse(ToLocation to) {
    String? machine = to.params["machine"];
    assert(machine != null, "machine arg should not be null");

    return ToMachine(machine: machine!);
  }

  @override
  Uri get uri => Uri.parse("/machines/$machine");

  @override
  Widget build(BuildContext context) {
    return Text("/machine page : [$machine]");
  }
}

final class ToMachine2 with ToHandler {
  ToMachine2() : super();

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
