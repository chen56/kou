// ignore_for_file: non_constant_identifier_names,camel_case_types
import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machines/[machine]/page.dart';

class RootPage extends StatelessWidget with ToPageMixin {
  RootPage({super.key});

  factory RootPage.parse(ToLocation to) {
    return RootPage();
  }

  @override
  Uri get uri => Uri.parse("/");

  static Widget layout(BuildContext context, ToLocation location, Widget content) {
    return _RootLayout(content: content);
  }

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
