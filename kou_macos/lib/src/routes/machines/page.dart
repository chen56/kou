import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';

import '[machine]/page.dart';

class MachinesPage extends StatelessWidget with PageMixin {
  MachinesPage({super.key});

  MachinePage machine({required String machine}) => MachinePage(machine: machine);

  factory MachinesPage.content(Location to) {
    return MachinesPage();
  }

  @override
  Uri get uri => Uri.parse("/machines");

  @override
  Widget build(BuildContext context) {
    return const Text("/machine page");
  }
}
