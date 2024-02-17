import 'package:flutter/widgets.dart';
import 'package:kou_macos/src/common/to_router.dart';

class MachinePage extends StatelessWidget with PageMixin {
  final String machine;

  MachinePage({super.key, required this.machine});

  factory MachinePage.content(ToLocation to) {
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
