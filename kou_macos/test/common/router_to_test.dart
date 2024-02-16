// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kou_macos/src/common/to_router.dart';

void main() {
  group("ToRouter.parse ok", () {
    var router = ToRouter(
        root: To("/", children: [
      To("settings", children: [
        To("profile"),
      ]),
      To("[user]", children: [
        To("[repository]", children: [
          To("tree", children: [
            To("[branch]", children: [
              To("[...file]"),
            ]),
          ]),
        ]),
      ]),
    ]));
    // Tos.root.user("chen56").repository("note").tree.branch("main").file("a/b/c.dart");
    // Tos.user_repository_tree_branch_file(user:"chen56",repository:"note",branch:"main",file:"a/b");
    void match(String path, {required ({String location, Map<String, String> params}) expected}) {
      var match = router.match(path);
      expect(match.to.uriTemplate, equals(expected.location));
      expect(match.params, equals(expected.params));
    }

    test('static', () {
      match("/", expected: (location: "/", params: {}));

      match("/settings", expected: (location: "/settings", params: {}));
      // end with '/'
      match("/settings/", expected: (location: "/settings", params: {}));

      match("/settings/profile", expected: (location: "/settings/profile", params: {}));
      // end with '/'
      match("/settings/profile/", expected: (location: "/settings/profile", params: {}));
    });

    test('dynamic', () {
      /// dynamic
      match("/flutter", expected: (location: "/[user]", params: {"user": "flutter"}));
      // end with '/'
      match("/flutter/", expected: (location: "/[user]", params: {"user": "flutter"}));

      match("/flutter/flutter",
          expected: (location: "/[user]/[repository]", params: {"user": "flutter", "repository": "flutter"}));
      match("/flutter/packages",
          expected: (location: "/[user]/[repository]", params: {"user": "flutter", "repository": "packages"}));

      match("/flutter/packages/tree",
          expected: (location: "/[user]/[repository]/tree", params: {"user": "flutter", "repository": "packages"}));

      match("/flutter/packages/tree/main", expected: (
        location: "/[user]/[repository]/tree/[branch]",
        params: {"user": "flutter", "repository": "packages", "branch": "main"}
      ));
    });

    test('dynamicAll', () {
      match("/flutter/packages/tree/main/b/c.dart", expected: (
        location: "/[user]/[repository]/tree/[branch]/[...file]",
        params: {"user": "flutter", "repository": "packages", "branch": "main", "file": "b/c.dart"}
      ));
      // end with '/'
      match("/flutter/packages/tree/main/b/c.dart/", expected: (
        location: "/[user]/[repository]/tree/[branch]/[...file]",
        params: {"user": "flutter", "repository": "packages", "branch": "main", "file": "b/c.dart/"}
      ));
    });

    test('priority', () {
      /// static 目录名 优先级高于 dynamic 目录名，同级中既有动态又有静态目录名时，优先匹配static
      match("/settings", expected: (location: "/settings", params: {}));
      match("/chen56", expected: (location: "/[user]", params: {"user": "chen56"}));
    });
  });
  group("ToRouter.parse 404", () {
    var router = ToRouter(
      root: To("/", children: [
        To("settings", children: [
          To("profile"),
        ]),
      ]),
    );

    void match(String path, {required String matched, required Map<String, String> params}) {
      var match = router.match(path);
      expect(match.to.uriTemplate, equals(matched));
      expect(match.params, equals(params));
    }

    void checkNotFound({required String uri}) {
      try {
        router.match(uri);
        fail("Never");
      } catch (e) {
        check(e).isA<NotFoundError>();
      }
    }

    test('404 no_page_found', () {
      // found
      match("/settings", matched: "/settings", params: {});
      match("/settings/profile", matched: "/settings/profile", params: {});
      // notFound
      checkNotFound(uri: "/no_exists_path");
      checkNotFound(uri: "/settings/no_exists_path");
    });
  });
}
