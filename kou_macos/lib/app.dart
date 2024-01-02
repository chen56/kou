import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/conf.dart';
import 'package:kou_macos/src/routes.dart';

class KouSystem {
  final Directory dataDir;
  final KouConf conf;

  KouSystem({required this.dataDir, required this.conf});

  static Future<KouSystem> load({required Directory dataDir}) async {
    var confFile = dataDir.childFile("conf.json");
    return KouSystem(dataDir: dataDir, conf: await KouConf.load(confFile));
  }
}

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: "mainNavigator");

  const App({super.key, required this.title, required this.system});

  final String title;
  final KouSystem system;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final ToRouter router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: widget.title,
      theme: ThemeData(colorScheme: const ColorScheme.light(), useMaterial3: true),
      darkTheme: ThemeData(colorScheme: const ColorScheme.dark(), useMaterial3: true),
      routerConfig: router.config(initial: rootRoute.uri, navigatorKey: App.navigatorKey),
    );
  }
}
