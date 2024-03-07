import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:kou_macos/app.dart';
import 'package:kou_macos/src/core/core.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  App.initWindow(title: "title");

  var fs = const LocalFileSystem();
  var dataDir = fs
      .directory((await getApplicationDocumentsDirectory()).path)
      .childDirectory("kou_workspaces")
      .childDirectory("workspace_0");
  runApp(App(
    title: "kou cloud apps",
    system: await KouSystem.load(
      dataDir: dataDir,
    ),
  ));
}
