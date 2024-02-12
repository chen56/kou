// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:kou_macos/src/routes.dart';
import 'package:kou_macos/src/routes/machines/[machine]/page.dart';

void main() {
  var router = createRouter();
  print(rootRoute2.machines.toString(deep: true));
  group("static type route use", () {
    test('route.uri', () {
      expect(rootRoute.uri.toString(), equals("/"));
      expect(rootRoute.machines.uri.toString(), equals("/machines"));
      expect(rootRoute.machines.machine(machine: "machine1").uri.toString(), equals("/machines/machine1"));
    });
    test('route.uri 2', () {
      expect(rootRoute2.path, equals("/"));
      expect(rootRoute2.machines.path, equals("/machines"));
      expect(rootRoute2.machines.machine.path, equals("/machines/[machine]"));
    });
  });

  group("static type route parse", () {
    test('route.uri', () {
      ToMachine toMachine = router.parse<ToMachine>("/machines/machine1");
      expect("machine1", toMachine.machine);
    });
    test('route.uri 2', () {
      ToMachine toMachine = router.parse<ToMachine>("/machines/machine1");
      expect("machine1", toMachine.machine);
    });
  });
}
