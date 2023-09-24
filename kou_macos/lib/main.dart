import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kou_macos/app.dart';
import 'package:kou_macos/src/common/ui.dart';
import 'package:window_size/window_size.dart' as window_size;

void main() {
  void initWindow() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final double windowWidth = WindowClass.m.widthFrom;
      const double windowHeight = 800;

      WidgetsFlutterBinding.ensureInitialized();
      window_size.setWindowTitle('我扣应用商店');
      window_size.setWindowMinSize(Size(windowWidth, windowHeight));
      window_size.getCurrentScreen().then((screen) {
        window_size.setWindowFrame(Rect.fromCenter(
          center: screen!.frame.center,
          width: WindowClass.xl.widthFrom,
          height: windowHeight,
        ));
      });
    }
  }

  initWindow();
  runApp(const App(title:"kou cloud apps"));
}
