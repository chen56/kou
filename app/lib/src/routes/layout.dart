import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:younpc/src/common/better_widget.dart';
import 'package:younpc/src/common/to_router.dart';
import 'package:younpc/src/routes/machines/[machine]/page.dart';
import 'package:younpc/src/routes/page.dart';
@immutable
class RootLayout extends StatelessWidget {
  final Widget content;

  const RootLayout({super.key, required this.content});

  static Widget layout(BuildContext context, Location loc, Widget child) {
    return RootLayout(content: child);
  }

  @override
  Widget build(BuildContext context) {
    Widget link(String title, Uri uri, IconData icon) {
      return MaterialButton(minWidth: double.infinity, height: 46, onPressed: () => {}, child: Align(alignment: Alignment.centerLeft, child: Text(title)));
    }

    return Scaffold(
      primary: true,
      // content...
      appBar: AppBar(toolbarHeight: 38, title: const Text("widget.title"), actions: [
        IconButton(iconSize:24,icon: const Icon(Icons.settings), onPressed: () {}),
        if (kDebugMode) const Text("debug模式会有个图标"),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: () {}, tooltip: 'Increment', child: const Icon(Icons.add)),
      body: Row(children: [
        Expanded(
          child: const Drawer$(width: 220)(
            ListView(scrollDirection: Axis.vertical, children: [

              link("︎︎︎▶ dashboard", RootPage().uri, Icons.abc),
              for (var machine in ["machine1", "machine2"]) link("︎︎︎▶ vm1-腾讯云香港", MachinePage(machine: machine).uri, Icons.abc),
            ]),
          ),
        ),
        Expanded(child: content)
      ]),
    );
  }
}
