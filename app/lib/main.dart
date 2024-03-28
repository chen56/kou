import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:younpc/src/app.dart';
import 'package:younpc/src/core/core.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  App.initWindow(title: "title");

  var fs = const LocalFileSystem();
  var dataDir = fs
      .directory((await getApplicationDocumentsDirectory()).path)
      .childDirectory("younpc")
      .childDirectory("workspace_0");
  runApp(App(
    title: "younpc cloud apps",
    you: await You.load(dataDir: dataDir),
  ));
}
