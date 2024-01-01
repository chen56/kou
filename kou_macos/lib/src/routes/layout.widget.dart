import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes.dart';

Widget layout(BuildContext context,RouteState state, Widget content) {
  return _RootLayout(content: content);
}

@immutable
class _RootLayout extends StatelessWidget {
  final Widget content;

  const _RootLayout({required this.content});

  @override
  Widget build(BuildContext context) {
    Widget link(String title,Uri uri, IconData icon) {
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
                link("︎︎︎▶ vm1-腾讯云香港", rootRoute.machine.uri, Icons.abc),
                link("  ︎︎ ■ df webui", Uri.parse("/apps/df-webui"), Icons.abc),
                link("  ︎︎︎ ■ out service", Uri.parse("/apps/out"), Icons.abc),
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
