
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'kou cloud app manage',

      // dart or light follow system preferences
      theme: ThemeData(colorScheme: const ColorScheme.light(), useMaterial3: true),
      darkTheme: ThemeData(colorScheme: const ColorScheme.dark(), useMaterial3: true),

      home: const App(title: 'kou cloud app manage'),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key, required this.title});

  final String title;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget link(String title, IconData icon) {
      return ListTile( title: Text(title), selected: false, onTap: () => {});
    }
    // Widget headLink(String title, IconData icon) {
    //   var link2 = TextButton(
    //     style: ButtonStyle(
    //         padding:
    //         MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(2))),
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         // const Icon(
    //         //   Icons.arrow_right,
    //         // ),
    //         // title 被Flexible包裹后，文本太长会自动换行▽
    //         // 换行后左边图标需要CrossAxisAlignment.start 排在文本的第一行
    //         //📜📁📂📄🗓📜 ▸▾▹▿▶︎▷▼▽►🔘◽️▫️◻️◼️⬛️🔹⚉
    //         Flexible(child: Text("◻ ${node.title}")),
    //       ],
    //     ),
    //     onPressed: () {
    //
    //     },
    //   );
    //   // TextButton link = TextButton(onPressed: (){}, child: Text(node.title));
    //   return Padding(
    //     // 缩进模仿树形
    //     padding: EdgeInsets.only(left: 20 * (node.level - 1).toDouble()),
    //     child: link2,
    //   );
    // }

    var content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('You have pushed the button this many times:'),
          Text('$_counter'),
        ],
      ),
    );
    var scaffold = Scaffold(
      primary: true,
      // content...
      appBar: AppBar(toolbarHeight: 30, title: Text(widget.title)),
      floatingActionButton: FloatingActionButton(onPressed: _incrementCounter, tooltip: 'Increment', child: const Icon(Icons.add)),
      body: Row(
        children: [
          Drawer(
            width: 200,
            child: Column(
              children: [
                link("︎︎︎▶ 腾讯云", Icons.abc),
                link("  ︎︎︎▶ 广州", Icons.abc),
                const Spacer(),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: content,
          ),
        ],
      ),
    );
    return scaffold;
  }
}
