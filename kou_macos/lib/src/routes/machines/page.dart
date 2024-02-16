import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';

import '[machine]/page.dart';

class MachinesPage extends ToPage {
  MachinesPage();

  MachinePage machine({required String machine}) => MachinePage(machine: machine);

  factory MachinesPage.parse(ToLocation to) {
    return MachinesPage();
  }

  @override
  Uri get uri => Uri.parse("/machines");

  @override
  Widget build(BuildContext context) {
    return const Text("/machine page");
  }
}

final class MachinesHandler with ToHandler {
  MachinesHandler() : super();

  @override
  String get uriTemplate => "/machines";

  @override
  Widget build(BuildContext context, ToLocation location) {
    return Text("$uriTemplate : ${location.uri}");
  }
}
