// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kou_macos/app.dart';

void main() {
  var fs = MemoryFileSystem();

  testWidgets('Kou app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      App(
        title: 'test',
        system: await KouSystem.load(
          dataDir: fs.directory("~/temp").childDirectory("kou_projects"),
        ),
      ),
    );
  });
}
