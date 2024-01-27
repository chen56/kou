import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';
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
