import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';
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

class ToMachine2 extends TypedRoute {
  ToMachine2({required this.parent}) : super("[machine]");

  factory ToMachine2.parse(PageSpec parent, ToLocation to) {
    String? machine = to.params["machine"];
    assert(machine != null, "machine arg should not be null");

    return (parent as ToMachines2).machine;
  }

  @override
  final ToMachines2 parent;

  @override
  Widget build(BuildContext context) {
    return const Text("/machine page : ");
  }
}
