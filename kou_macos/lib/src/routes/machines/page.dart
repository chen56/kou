import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';

import '[machine]/page.dart';

class ToMachines extends ToPage {
  ToMachines();

  ToMachine machine({required String machine}) => ToMachine(machine: machine);

  factory ToMachines.parse(ToLocation to) {
    return ToMachines();
  }

  @override
  Uri get uri => Uri.parse("/machines");

  @override
  Widget build(BuildContext context) {
    return const Text("/machine page");
  }
}

final class ToMachines2 with ToHandler {
  ToMachines2() : super();

  @override
  String get uriTemplate => "/machines";

  @override
  Widget build(BuildContext context, ToLocation location) {
    return Text("$uriTemplate : ${location.uri}");
  }
}
