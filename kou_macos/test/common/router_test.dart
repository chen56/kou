// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kou_macos/src/common/to_router.dart';
import 'package:path/path.dart' as path;

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
    page(BuildContext context, RouteState state) => const Text("/");
    var router = ToRouter(
        root: To("/", page: page, children: [
      To("settings", page: page, children: [
        To("profile", page: page, children: [
          To("emails", page: page),
        ]),
        To("[dynamic]", page: page),
      ]),
      To("[user]", page: page, children: [
        To("[repository]", page: page, children: [
          To("issues", page: page),
          To("tree", /* no page */ children: [
            To("[branch]", page: page, children: [
              To("[...file]", page: page, children: [
                To("history", page: page),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]));

    void match(String path, {required ({String matched, Map<String, String> params}) expected}) {
      var match = router.match(path);
      expect(match.to.path, equals(expected.matched));
      expect(match.params, equals(expected.params));
    }

    test('static', () {
      match("/", expected: (matched: "/", params: {}));

      match("/settings", expected: (matched: "/settings", params: {}));
      match("/settings/", expected: (matched: "/settings/[dynamic]", params: {"dynamic": ""}));

      match("/settings/profile", expected: (matched: "/settings/profile", params: {}));
      match("/settings/profile/", expected: (matched: "/settings/profile", params: {}));

      match("/settings/profile/emails", expected: (matched: "/settings/profile/emails", params: {}));
      match("/settings/profile/emails/", expected: (matched: "/settings/profile/emails", params: {}));
    });

    test('dynamic', () {
      /// dynamic
      match("/chen56/note", expected: (matched: "/[user]/[repository]", params: {"user": "chen56", "repository": "note"}));
      match("/flutter", expected: (matched: "/[user]", params: {"user": "flutter"}));
      match("/flutter/flutter",
          expected: (matched: "/[user]/[repository]", params: {"user": "flutter", "repository": "flutter"}));
      match("/flutter/packages",
          expected: (matched: "/[user]/[repository]", params: {"user": "flutter", "repository": "packages"}));
      match("/flutter/packages/issues",
          expected: (matched: "/[user]/[repository]/issues", params: {"user": "flutter", "repository": "packages"}));
    });

    test('dynamicAll', () {
      match("/flutter/packages/tree/master/b/c.dart", expected: (
        matched: "/[user]/[repository]/tree/[branch]/[...file]",
        params: {"user": "flutter", "repository": "packages", "file": "b/c.dart"}
      ));
    });

    test('priority', () {
      /// static 目录名 优先级高于 dynamic 目录名，同级中既有动态又有静态目录名时，优先匹配static
      match("/settings/profile", expected: (matched: "/settings/profile", params: {}));
      match("/settings/dynamic_x", expected: (matched: "/settings/[dynamic]", params: {"dynamic": "dynamic_x"}));
    });

    test('404 no_page_found', () {
      // no page not found
      // match("/flutter/packages/tree",
      //     expected: (matched: "/[user]/[repository]", params: {"user": "flutter", "repository": "packages"}));
    });
  });
  //
  // group("ToPathSegment.parse", () {
  //   test('ok', () {
  //     var tests = [
  //       (node: "a", expected: (_paramName: "a", _paramType: ToNodeType.static)),
  //       (node: "[id]", expected: (_paramName: "id", _paramType: ToNodeType.dynamic)),
  //       (node: "[...files]", expected: (_paramName: "files", _paramType: ToNodeType.dynamicAll)),
  //     ];
  //
  //     for (var t in tests) {
  //       var result = ToNode.parse(t.node);
  //       expect(result.part, equals(t.expected._paramName), reason: "test:$t");
  //       expect(result.type, equals(t.expected._paramType), reason: "test:$t");
  //     }
  //   });
  //
  //   test('error', () {
  //     //error arg
  //     try {
  //       ToNode.parse("[]");
  //       fail("not here");
  //     } catch (e) {
  //       expect(e.toString(), contains("""'name != "[]"': is not true"""));
  //     }
  //
  //     try {
  //       ToNode.parse("[...]");
  //       fail("not here");
  //     } catch (e) {
  //       expect(e.toString(), contains("""'name != "[...]"': is not true"""));
  //     }
  //   });
  // });

  group("ToRouter.go", () {
    test('ok', () {
      expect(Uri.parse("https://a.com").path, equals(""));
      expect(path.join("a", "/"), equals("/"));
      var l = [""];
      expect(l, [""]);

      // var to = router.parse("/");
      // expect(to.path,equals("expected"));
      // expect("/", router.match("/").path);
    });
  });
}
