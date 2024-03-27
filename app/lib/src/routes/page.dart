// ignore_for_file: non_constant_identifier_names,camel_case_types
import 'package:flutter/material.dart';
import 'package:younpc/src/common/to_router.dart';
import 'package:younpc/src/routes/machines/[machine]/page.dart';

class RootPage extends StatelessWidget with PageMixin {
  RootPage({super.key});

  factory RootPage.content(Location to) {
    return RootPage();
  }

  @override
  Uri get uri => Uri.parse("/");

  static Widget layout(BuildContext context, Location loc, Widget child) {
    return _RootLayout(content: child);
  }

  static Page<dynamic> page(BuildContext context, Location loc, Widget child) =>
      MaterialPage(key: ValueKey(loc.uri.toString()), child: child);

  @override
  Widget build(BuildContext context) {
    return const Text("/  root page");
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
                link("︎︎︎▶ dashboard", RootPage().uri, Icons.abc),
                for (var machine in ["machine1", "machine2"])
                  link("︎︎︎▶ vm1-腾讯云香港", MachinePage(machine: machine).uri, Icons.abc),
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
