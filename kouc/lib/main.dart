import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      // dart or light follow system preferences
      theme: ThemeData(colorScheme: const ColorScheme.light(), useMaterial3: true),
      darkTheme: ThemeData(colorScheme: const ColorScheme.dark(), useMaterial3: true),

      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 更好的代码排版，类似html , 把属性和子元素分开
    // Scaffold(
    //   appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    //       title: Text(widget.title)
    //   ),
    //   body: Center( widthFactor:1,heightFactor:1,
    //     child: Column( mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         const Text('You have pushed the button this many times:'),
    //         Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
    //       ],
    //     ),
    //   ),
    //   floatingActionButton: FloatingActionButton(onPressed: _incrementCounter, tooltip: 'Increment',
    //       child: const Icon(Icons.add),
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
