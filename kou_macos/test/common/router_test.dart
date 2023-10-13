// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kou_macos/src/common/to_router.dart';

Widget page(BuildContext context, RouteState state) => Text("page $state");

Widget notFound(BuildContext context, RouteState state) => const Text("404 not found");

void main() {
  group("ToRouter.parse", () {
    var router = ToRouter(
        root: To("/", page: page, children: [
      To("settings", page: page, children: [
        To("profile", page: page),
      ]),
      To("[user]", page: page, children: [
        To("[repository]", page: page, children: [
          To("tree", /* no page */ children: [
            To("[branch]", page: page, children: [
              To("[...file]", page: page),
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
      // end with '/'
      match("/settings/", expected: (matched: "/settings", params: {}));

      match("/settings/profile", expected: (matched: "/settings/profile", params: {}));
      // end with '/'
      match("/settings/profile/", expected: (matched: "/settings/profile", params: {}));
    });

    test('dynamic', () {
      /// dynamic
      match("/flutter", expected: (matched: "/[user]", params: {"user": "flutter"}));
      // end with '/'
      match("/flutter/", expected: (matched: "/[user]", params: {"user": "flutter"}));

      match("/flutter/flutter",
          expected: (matched: "/[user]/[repository]", params: {"user": "flutter", "repository": "flutter"}));
      match("/flutter/packages",
          expected: (matched: "/[user]/[repository]", params: {"user": "flutter", "repository": "packages"}));

      match("/flutter/packages/tree",
          expected: (matched: "/[user]/[repository]/tree", params: {"user": "flutter", "repository": "packages"}));

      match("/flutter/packages/tree/main", expected: (
        matched: "/[user]/[repository]/tree/[branch]",
        params: {"user": "flutter", "repository": "packages", "branch": "main"}
      ));
    });

    test('dynamicAll', () {
      match("/flutter/packages/tree/main/b/c.dart", expected: (
        matched: "/[user]/[repository]/tree/[branch]/[...file]",
        params: {"user": "flutter", "repository": "packages", "branch": "main", "file": "b/c.dart"}
      ));
      // end with '/'
      match("/flutter/packages/tree/main/b/c.dart/", expected: (
        matched: "/[user]/[repository]/tree/[branch]/[...file]",
        params: {"user": "flutter", "repository": "packages", "branch": "main", "file": "b/c.dart/"}
      ));
    });

    test('priority', () {
      /// static 目录名 优先级高于 dynamic 目录名，同级中既有动态又有静态目录名时，优先匹配static
      match("/settings", expected: (matched: "/settings", params: {}));
      match("/chen56", expected: (matched: "/[user]", params: {"user": "chen56"}));
    });
  });
  group("ToRouter.parse 404", () {
    var router = ToRouter(
      root: To("/", page: page, notFound: notFound, children: [
        To("settings", page: page, notFound: notFound, children: [
          To("profile", page: page),
        ]),
      ]),
    );

    void match(String path, {required String matched, required Map<String, String> params, bool notFound = false}) {
      var match = router.match(path);
      expect(match.to.path, equals(matched));
      expect(match.params, equals(params));
      expect(match.isNotFound, equals(notFound));
    }

    test('404 no_page_found', () {
      // found
      match("/settings", matched: "/settings", params: {}, notFound: false);
      match("/settings/profile", matched: "/settings/profile", params: {}, notFound: false);
      // notFound
      match("/no_exists_path", matched: "/", params: {}, notFound: true);
      match("/settings/no_exists_path", matched: "/settings", params: {}, notFound: true);
    });
  });
}
