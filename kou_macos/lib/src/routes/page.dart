// ignore_for_file: non_constant_identifier_names,camel_case_types
import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes.dart';
import 'package:kou_macos/src/routes/machines/page.dart';

class ToRoot extends PageSpec {
  ToRoot();

  factory ToRoot.parse(PageSpec parent, ToLocation to) {
    return ToRoot();
  }

  ToMachines get machines => ToMachines(parent: this);

  @override
  Uri get uri => Uri.parse("/");

  @override
  Widget build(BuildContext context) {
    return const Text("/  root page");
  }

  @override
  ToRoot get parent => this;
}

class ToRoot2 extends MyRouteBase {
  static const String key = "/";

  ToRoot2({super.children}) : super(part: key);

  ToMachines2 get machines => child(ToMachines2.key) as ToMachines2;

  @override
  ToLayoutBuilder get layout => (BuildContext context, ToLocation location, Widget content) {
        return _RootLayout(content: content);
      };

  @override
  Widget build(BuildContext context, ToLocation location) {
    return Text("$key : ${location.uri}");
  }
}

@immutable
class _RootLayout extends StatelessWidget {
  final Widget content;

  const _RootLayout({required this.content});

  @override
  Widget build(BuildContext context) {
    Widget link(String title, Uri uri, IconData icon) {
      return MaterialButton(
          minWidth: double.infinity, // fill drawer space
          height: 46,
          onPressed: () {
            // context.to(Tos.root);
          },
          // ...children...
          child: Align(alignment: Alignment.centerLeft, child: Text(title)));
    }

    var scaffold = Scaffold(
      primary: true,
      // content...
      appBar: AppBar(toolbarHeight: 30, title: const Text("widget.title")),
      floatingActionButton: FloatingActionButton(onPressed: () {}, tooltip: 'Increment', child: const Icon(Icons.add)),
      body: Row(
        children: [
          Drawer(
            width: 220,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                link("︎︎︎▶ dashboard", rootRoute.uri, Icons.abc),
                for (var machine in ["machine1", "machine2"])
                  link("︎︎︎▶ vm1-腾讯云香港", rootRoute.machines.machine(machine: machine).uri, Icons.abc),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 0.01),
          Expanded(
            child: content,
          ),
        ],
      ),
    );
    return scaffold;
  }
}
