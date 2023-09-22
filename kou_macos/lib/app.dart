import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/router.dart';
import 'package:kou_macos/src/routes.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final KRoute routeRoot = createRootRoute();

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
    // return MaterialApp.router(
    //   routerConfig: _router,
    // );
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
      return MaterialButton(
          minWidth: double.infinity, // fill drawer space
          height: 46,
          onPressed: () {},
          // ...children...
          child: Align(alignment: Alignment.centerLeft, child: Text(title)));
    }

    var content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // ...children...
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
