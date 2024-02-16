import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/conf.dart';
import 'package:kou_macos/src/routes/machines/[machine]/page.dart';
import 'package:kou_macos/src/routes/machines/page.dart';
import 'package:kou_macos/src/routes/page.dart';

ToRouter createRouter() {
  To root = To("/", page: RootPage.parse, layout: RootPage.layout, children: [
    To("machines", page: MachinesPage.parse, children: [
      To("[machine]", page: MachinePage.parse),
    ]),
  ]);
  return ToRouter(root: root);
}

ToRouter router = createRouter();

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
