

import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/router.dart';

LayoutMixin layout(BuildContext context){
    return const Layout();
}
class Layout extends StatelessWidget with LayoutMixin{
  const Layout({super.key});

  @override
  Widget build(BuildContext context) {
    Widget link(String title, IconData icon) {
      return MaterialButton(
          minWidth: double.infinity, // fill drawer space
          height: 46,
          onPressed: () {},
          // ...children...
          child: Align(alignment: Alignment.centerLeft, child: Text(title)));
    }

    var content = const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // ...children...
        children: <Widget>[
          Text('You have pushed the button this many times:'),
        ],
      ),
    );
    var scaffold = Scaffold(
      primary: true,
      // content...
      appBar: AppBar(toolbarHeight: 30, title: Text("widget.title")),
      floatingActionButton: FloatingActionButton(onPressed: (){}, tooltip: 'Increment', child: const Icon(Icons.add)),
      body: Row(
        children: [
          Drawer(
            width: 220,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                link("︎︎︎▶ dashboard", Icons.abc),
                link("︎︎︎▶ 腾讯云", Icons.abc),
                link("  ︎︎︎▶ 香港", Icons.abc),
                link("  ︎︎︎  ■ df webui", Icons.abc),
                link("  ︎︎︎  ■ out service${DateTime.now()}", Icons.abc),
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
