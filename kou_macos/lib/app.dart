import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes.dart';

class App extends StatefulWidget {
  const App({super.key, required this.title});

  final String title;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final ToRouter router = createRouter();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var app = MaterialApp.router(
      title: 'kou cloud app manage',
      // dart or light follow system preferences
      theme: ThemeData(colorScheme: const ColorScheme.light(), useMaterial3: true),
      darkTheme: ThemeData(colorScheme: const ColorScheme.dark(), useMaterial3: true),
      routerConfig: router.config(initial: rootRoute.uri),
    );
    return app;
  }
}