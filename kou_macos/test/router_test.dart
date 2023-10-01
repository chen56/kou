// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kou_macos/src/common/to_router.dart';

LayoutMixin layout(BuildContext context) {
  return const TestRootLayout();
}

class TestRootLayout extends StatelessWidget with LayoutMixin {
  const TestRootLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Row(children: [Text("layout: /")]));
  }
}

void main() {
  group("ToRouter.parse", () {
    var router = ToRouter(
        root: To(match: "/", children: [
      To(match: "[user]", children: [
        To(match: "[repository]", children: [
          To(match: "issues"),
        ]),
      ]),
      To(match: "settings", children: [
        To(match: "[...setting_key]"),
      ]),
    ]));

    void match(String path, {required ({String allPattern, Map<String, String> params}) expected}) {
      var match = router.match(path);
      expect(match.to.path,equals(expected.allPattern));
      expect(match.params,equals(expected.params));
    }

    test('ok', () {
      /// static 目录名 优先级高于 dynamic 目录名，同级中既有动态又有静态目录名时，优先匹配static
      match("/settings", expected: (allPattern: "/settings", params: {}));

      match("/chen56/note", expected: (allPattern: "/[user]/[repository]", params: {"user": "chen56", "repository": "note"}));
    });
  });

  group("ToPathSegment.parse", () {
    test('ok', () {
      var tests = [
        (node: "a", expected: (part: "a", type: ToNodeType.static)),
        (node: "[id]", expected: (part: "id", type: ToNodeType.dynamic)),
        (node: "[...files]", expected: (part: "files", type: ToNodeType.dynamicAll)),
      ];

      for (var t in tests) {
        var result = ToNode.parse(t.node);
        expect(result.part, equals(t.expected.part), reason: "test:${t}");
        expect(result.type, equals(t.expected.type), reason: "test:${t}");
      }
    });

    test('error', () {
      //error arg
      try {
        ToNode.parse("[]");
        fail("not here");
      } catch (e) {
        expect(e.toString(), contains("""'name != "[]"': is not true"""));
      }

      try {
        ToNode.parse("[...]");
        fail("not here");
      } catch (e) {
        expect(e.toString(), contains("""'name != "[...]"': is not true"""));
      }
    });
  });

  group("ToRouter.go", () {
    var router = ToRouter(
        root: To(match: "/", layout: layout, page: (context, state) => const Text("/"), children: [
      To(match: "users", page: (context, state) => const Text("/users")),
      To(match: "user", children: [
        To(match: "[user_id]", page: (context, state) => const Text("/user/1")),
      ]),
      To(match: "settings", page: (context, state) => const Text("/settings")),
    ]));

    test('ok', () {
      // var to = router.parse("/");
      // expect(to.path,equals("expected"));
      // expect("/", router.match("/").path);
    });
  });
}
