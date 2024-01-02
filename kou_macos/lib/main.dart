import 'dart:io';

import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kou_macos/app.dart';
import 'package:kou_macos/src/common/ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_size/window_size.dart' as window_size;

Future<void> main() async {
  void initWindow({required String title}) {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final double minWindowWidth = WindowClass.m.widthFrom;
      final double windowWidth = WindowClass.xl.widthFrom;
      const double windowHeight = 600;

      WidgetsFlutterBinding.ensureInitialized();
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

  initWindow(title: "kou cloud");

  var fs = const LocalFileSystem();
  var dataDir = fs.directory((await getApplicationDocumentsDirectory()).path).childDirectory("kou_projects");
  runApp(App(
    title: "kou cloud apps",
    system: await KouSystem.load(
      dataDir: dataDir,
    ),
  ));
}