import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:kou_macos/app.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  App.initWindow(title: "kou cloud apps");

  var fs = const LocalFileSystem();
  var dataDir = fs.directory((await getApplicationDocumentsDirectory()).path).childDirectory("kou_projects");
  runApp(App(
    title: "kou cloud apps",
    system: await KouSystem.load(
      dataDir: dataDir,
    ),
  ));
}
