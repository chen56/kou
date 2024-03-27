import 'package:flutter/widgets.dart';
import 'package:younpc/src/common/to_router.dart';

import '[machine]/page.dart';

class MachinesPage extends StatelessWidget with PageMixin {
  MachinesPage({super.key});

  MachinePage machine({required String machine}) => MachinePage(machine: machine);

  factory MachinesPage.fromURI(Location to) {
    return MachinesPage();
  }

  @override
  String get uriTemplate => "/machines]";

  @override
  Uri get uri => Uri.parse("/machines");

  @override
  Widget build(BuildContext context) {
    return const Text("/machine page");
  }
}
