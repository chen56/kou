// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes.dart';

Widget page(BuildContext context, RouteState state) => Text("page $state");

Widget notFound(BuildContext context, RouteState state) => const Text("404 not found");

void main() {
  group("strong type route use", () {
    test('route.uri', () {
      expect(rootRoute.uri.toString(), equals("/"));
      expect(rootRoute.machines.uri.toString(), equals("/machines"));
      expect(rootRoute.machines.machine(machine: "machine1").uri.toString(), equals("/machines/machine1"));
    });
  });
  group("strong type route parse", () {
    test('route.uri', () {});
  });
}
