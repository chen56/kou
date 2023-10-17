import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes.dart';

Widget layout(BuildContext context,RouteState state, Widget content) {
  return Layout(content: content);
}

class Layout extends StatelessWidget {
  Widget content;

  Layout({super.key, required this.content});

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

    // var content = const Center(
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     // ...children
    //     children: <Widget>[
    //       Text('You have pushed the button this many times:'),
    //     ],
    //   ),
    // );
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
                link("︎︎︎▶ dashboard",Uri.parse("/dashboard"), Icons.abc),
                link("︎︎︎▶ 腾讯云",Uri.parse("/tencent_cloud"), Icons.abc),
                link("  ︎︎︎▶ 香港", Uri.parse("/tencent_cloud"),Icons.abc),
                link("  ︎︎︎  ■ df webui",Uri.parse("/apps/df-webui"), Icons.abc),
                link("  ︎︎︎  ■ out service${DateTime.now()}",Uri.parse("/apps/out"), Icons.abc),
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
