// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:younpc/src/routes/machines/%5Bmachine%5D/page.dart';
import 'package:younpc/src/routes/machines/page.dart';
import 'package:younpc/src/routes/page.dart';

void main() {
  group("static type route use", () {
    test('route.uri', () {
      expect(RootPage().uri.toString(), equals("/"));
      expect(MachinesPage().uri.toString(), equals("/machines"));
      expect(MachinePage(machine: "machine1").uri.toString(), equals("/machines/machine1"));
    });
  });
}
