import 'dart:io';

import 'package:file/file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/common/ui.dart';
import 'package:kou_macos/src/conf.dart';
import 'package:kou_macos/src/routes/machines/[machine]/page.dart';
import 'package:kou_macos/src/routes/machines/page.dart';
import 'package:kou_macos/src/routes/page.dart';
import 'package:window_size/window_size.dart' as window_size;

ToRouter createRouter() {
  To root = To("/", content: RootPage.content, layout: RootPage.layout, page: RootPage.page, children: [
    To("machines", content: MachinesPage.content, children: [
      To("[machine]", content: MachinePage.content),
    ]),
  ]);
  return ToRouter(root: root);
}

ToRouter router = createRouter();

class KouSystem {
  final Directory dataDir;
  final KouConf conf;

  KouSystem._({required this.dataDir, required this.conf});

  static Future<KouSystem> load({required Directory dataDir}) async {
    await dataDir.create(recursive: true);

    var confFile = dataDir.childFile("conf.json");
    return KouSystem._(dataDir: dataDir, conf: await KouConf.load(confFile));
  }
}

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: "mainNavigator");

  const App({super.key, required this.title, required this.system});

  final String title;
  final KouSystem system;

  @override
  State<App> createState() => _AppState();

  static void initWindow({required String title}) {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final double minWindowWidth = WindowClass.m.widthFrom;
      final double windowWidth = WindowClass.xl.widthFrom;
      const double windowHeight = 600;

      window_size.setWindowTitle(title);
      window_size.setWindowMinSize(Size(minWindowWidth, windowHeight));
      window_size.getCurrentScreen().then((screen) {
        window_size.setWindowFrame(Rect.fromCenter(
          center: screen!.frame.center,
          width: windowWidth,
          height: windowHeight,
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
