// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/machines/%5Bmachine%5D/page.dart';
import 'package:kou_macos/src/routes/machines/page.dart';
import 'package:kou_macos/src/routes/page.dart';

class _TestHandler with ToHandler {
  @override
  String uriTemplate;

  _TestHandler(this.uriTemplate);

  @override
  Widget build(BuildContext context, ToLocation location) {
    throw UnimplementedError();
  }
}

void main() {
  group("To.fromHandlers ok", () {
    test('fromHandlers', () {
      var root = To.fromHandlers([
        _TestHandler("/"),
        _TestHandler("/a"),
        _TestHandler("/a/aa"),
        _TestHandler("/b/bb"),
      ]);
      expect(root.toList(includeThis: true).map((e) => e.uriTemplate), ['/', '/a', '/a/aa', '/b', '/b/bb']);
    });
  });

  group("static type route use", () {
    test('route.uri', () {
      expect(RootPage().uri.toString(), equals("/"));
      expect(MachinesPage().uri.toString(), equals("/machines"));
      expect(MachinePage(machine: "machine1").uri.toString(), equals("/machines/machine1"));
    });
  });
}
