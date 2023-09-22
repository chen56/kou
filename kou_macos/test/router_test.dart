// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kou_macos/src/common/router.dart';

LayoutMixin layout(BuildContext context) {
  return const TestRootLayout();
}

class TestRootLayout extends StatelessWidget with LayoutMixin {
  const TestRootLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Row(children: [Text("layout root")]));
  }
}

void main() {
  testWidgets('router test', (WidgetTester tester) async {
    var router = KRouter(
        root: KRoute(name: "/", layout: layout, page: (context, state) => const Text("/"), routes: [
      KRoute(name: "users", page: (context, state) => const Text("/users")),
      KRoute(name: "user", routes: [
        KRoute(name: "[user_id]", page: (context, state) => const Text("/user/1")),
      ]),
      KRoute(name: "settings", page: (context, state) => const Text("/settings")),
    ]));

    print(router.root.toString(deep: true));

    // expect("/", router.match("/").path);
  });
}
