import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:younpc/src/core/core.dart';
import 'package:younpc/src/routes.dart';
import 'package:younpc/src/routes/machines/[machine]/page.dart';
import 'package:window_size/window_size.dart' as window_size;

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: "mainNavigator");

  const App({super.key, required this.title, required this.you});

  final String title;
  final You you;

  @override
  State<App> createState() => _AppState();

  // 这函数里的代码改了系统设置, hot reload不起作用，app会卡住，需重启
  static void initWindow({required String title}) {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      window_size.setWindowTitle(title);
      // window_size.setWindowMinSize(const Size(0, 0));
      window_size.getCurrentScreen().then((screen) {
        window_size.setWindowFrame(Rect.fromCenter(
          center: screen!.frame.center,
          width: 600,
          height: 600,
        ));
      });
    }
  }
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: widget.title,
      theme: ThemeData(colorScheme: const ColorScheme.light(), useMaterial3: true),
      darkTheme: ThemeData(colorScheme: const ColorScheme.dark(), useMaterial3: true),
      routerConfig: router.toRouterConfig(
        initial: MachinePage(machine: "machineX").uri,
        navigatorKey: App.navigatorKey,
      ),
    );
  }
}
