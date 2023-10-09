import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_;

/*
## 用例：聊天窗口在
  手机屏：push新page
  桌面屏：层级展示（没有push新page）
### 方案1:
/
  main layout:MainWindowLayout
    chat layout: ChatsLayout page:chatsPage(空页面)  // windows:  默认， mobile :/pushUpPage/main/chat/1 ,
      [user_id] page: chatPage
    通讯录
    发现
    我
  pushUpPage
    main
      chat
        [user_id]  ref-> /main/chat/user_id

### 方案2:
/
  main layout:MainWindowLayout
    chat layout: ChatsLayout page:chatsPage(空页面)  // windows:  默认， mobile :/pushUpPage/main/chat/1 ,
      [user_id] page: chatPage , layoutRetry: LayoutRetry.up   // fallStrategy: 页面踏空策略，如果页面没有被上游layout处理，则用此此略push一个新page
    通讯录
    发现
    我
 */

mixin LayoutMixin on Widget {}

typedef LayoutBuilder = LayoutMixin Function(BuildContext context);

mixin RoutePageMixin on Widget {}

typedef PageBuilder = Widget Function(BuildContext context, RouteState state);

class RouteState {}

class ToRouter {
  To root;
  static final To defaultNotFound =
      To("/404", page: (context, state) => const Text("404 not found"));

  ToRouter({required this.root}) : assert(root.part == "/");

  static ToRouter of(BuildContext context) {
    var result = context.findAncestorWidgetOfExactType<_Navigator>();
    assert(result != null, "应把ToRouter配置到您的App中: MaterialApp.router(routerConfig:ToRouter(...))");
    return result!.router;
  }
  MatchTo matchUri(Uri uri) {
    if (uri.path == "/") return MatchTo(uri: uri, to: root);

    Map<String, String> params = {};
    return root._match(uri: uri, segments: uri.pathSegments, params: params);
  }

  MatchTo matchUriV1(Uri uri) {
    if (uri.path == "/") return MatchTo(uri: uri, to: root);

    To? matched = root;
    Map<String, String> params = {};

    var segments = uri.pathSegments.iterator;
    assert(segments.moveNext());

    while (true) {
      matched = matched!._matchChild(segment: segments.current);
      if (matched == null) {
        return MatchTo(uri: uri, to: defaultNotFound, params: params);
      }
      if (matched._paramType == ToNodeType.static) {
        if (!segments.moveNext()) break;
        continue;
      } else if (matched._paramType == ToNodeType.dynamic) {
        params[matched._paramName] = segments.current;
        if (!segments.moveNext()) break;
        continue;
      } else if (matched._paramType == ToNodeType.dynamicAll) {
        // /settings/[...key]/reset
        // /settings/x/reset
        params[matched._paramName] = !params.containsKey(matched._paramName)
            ? segments.current
            : path_.join(params[matched._paramName]!, segments.current);
      } else {
        throw AssertionError("not here _paramType:${matched._paramType}");
      }
    }
    return MatchTo(uri: uri, to: matched, params: params);
  }

  MatchTo match(String uri) {
    return matchUri(Uri.parse(uri));
  }

// To match(Uri uri) {
//   if (uri.path == "/") return root;
//   To current = root;
//   if (current.children.length == 1 && current.children.first.pathSegemntType == PathSegment.dynamic)
//     for (var s in uri.pathSegments) {
//       testFunction([1, 2]);
//     }
// }

// static RouterConfig<RouteInformation> config() {
//   return RouterConfig(
//     routeInformationProvider: PlatformRouteInformationProvider(
//       initialRouteInformation: RouteInformation(
//         uri: Uri.parse("/"),
//       ),
//     ),
//     routerDelegate: LoggableRouterDelegate(
//         logger: logger,
//         delegate: _MyRouterDelegate(
//           initial: navigable.initial,
//           navigable: navigable,
//         )),
//     routeInformationParser: _Parser(),
//   );
// }
}

/// Layout失败重试策略
enum LayoutRetry {
  /// 失败后, 直接放弃layout，push 此页面自己的内容
  none,

  /// 失败后, 再尝试用上层layout处理
  up;
}

enum ToNodeType {
  /// 正常路径片段: /settings
  static,

  /// 动态参数  /user/[id]  :
  ///     /user/1 -> id==1
  dynamic,

  /// 动态参数  /file/[...path]  :
  ///     /file/a.txt  ->  path==a.txt
  ///     /file/a/b/c.txt -> path==a/b/c.txt
  dynamicAll;

  static ToNodeType parse(String name) {
    return ToNodeType.static;
  }
}

/// To == go_router.GoRoute
/// 官方的go_router内部略显复杂，且没有我们想要的layout等功能，所以自定一个简化版的to_router
class To {
  To(
    this.part, {
    this.layout,
    this.layoutRetry = LayoutRetry.none,
    this.page,
    this.children = const [],
  })  : assert(children.isNotEmpty || page != null),
        assert(part == "/" || !part.contains("/")) {
    var parsed = _parse(part);
    _paramName = parsed.$1;
    _paramType = parsed.$2;

    for (var route in children) {
      route.parent = this;
    }
  }

  final String part;
  late final String _paramName;
  late final ToNodeType _paramType;

  To? parent;
  final LayoutBuilder? layout;
  final PageBuilder? page;
  final LayoutRetry layoutRetry;
  List<To> children;

  bool get isRoot => parent == null;

  String get path => isRoot ? "/" : path_.join(parent!.path, part);

  To? _matchChild({required String segment}) {
    To? matched = children
        .where((e) => e._paramType == ToNodeType.static)
        .where((e) => segment == e._paramName)
        .firstOrNull;
    if (matched != null) return matched;
    matched = children
        .where((e) => e._paramType == ToNodeType.dynamic || e._paramType == ToNodeType.dynamicAll)
        .firstOrNull;
    if (matched != null) return matched;
    return null;
  }

  MatchTo _match(
      {required Uri uri, required List<String> segments, required Map<String, String> params}) {
    assert(segments.isNotEmpty);

    To? matched = _matchChild(segment: segments[0]);
    if (matched == null) {
      return MatchTo(uri: uri, to: ToRouter.defaultNotFound, params: params);
    }

    if (matched._paramType == ToNodeType.dynamic) {
      params[matched._paramName] = segments[0];
    } else if (matched._paramType == ToNodeType.dynamicAll) {
      // /[...file]/history
      // /x/y.dart/history
      params[matched._paramName] = !params.containsKey(matched._paramName)
          ? segments[0]
          : path_.join(params[matched._paramName]!, segments[0]);
    } else {
      throw AssertionError("not here _paramType:${matched._paramType}");
    }

    if (segments.length == 1) {
      return MatchTo(uri: uri, to: matched, params: params);
    }

    return matched._match(uri: uri, segments: segments.sublist(1), params: params);
  }

  List<To> toList({
    bool includeThis = true,
    bool Function(To path)? test,
    Comparator<To>? sortBy,
  }) {
    test = test ?? (e) => true;
    if (!test(this)) {
      return [];
    }
    List<To> sorted = List.from(children);
    if (sortBy != null) {
      sorted.sort(sortBy);
    }

    var flatChildren = sorted.expand((child) {
      return child.toList(includeThis: true, test: test, sortBy: sortBy);
    }).toList();
    return includeThis ? [this, ...flatChildren] : flatChildren;
  }

  /// parse("user")       -->  (name:"user",type:ToNodeType.normal)
  /// parse("[id]")       -->  (name:"id",  type:ToNodeType.dynamic)
  /// parse("[...path]")  -->  (name:"path",type:ToNodeType.dynamicAll)
  static (String, ToNodeType) _parse(String pattern) {
    assert(pattern.isNotEmpty);

    if (pattern[0] != "[" || pattern[pattern.length - 1] != "]") {
      return (pattern, ToNodeType.static);
    }

    assert(pattern != "[]");
    assert(pattern != "[...]");

    // name 现在是[...xxx]或[xx]

    final removeBrackets = pattern.substring(1, pattern.length - 1);

    if (removeBrackets.startsWith("...")) {
      return (removeBrackets.substring(3), ToNodeType.dynamicAll);
    } else {
      return (removeBrackets, ToNodeType.dynamic);
    }
  }

  @override
  String toString({bool deep = false}) {
    if (!deep) return "<Route part='$part' children.length=${children.length} />";
    return _toStringDeep(level: 0);
  }

  String _toStringDeep({int level = 0}) {
    if (children.isEmpty) {
      return "${"  " * level}<Route part='$part'/>";
    }

    return '''${"  " * level}<Route part='$part'>
${children.map((e) => e._toStringDeep(level: level + 1)).join("\n")}
${"  " * level}</Route>''';
  }
}

class MatchTo {
  final To to;
  final Uri uri;
  final Map<String, String> params;

  MatchTo({required this.uri, required this.to, this.params = const {}});
}

/// 主要用于存储 [router]，便于[ToRouter.of]
class _Navigator extends StatelessWidget {
  const _Navigator({
    required this.router,
    required this.builder,
  });

  final ToRouter router;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

class ToUri {
  final Uri uri;

  ToUri({required this.uri});
}

class _RouteInformationParser extends RouteInformationParser<ToUri> {
  _RouteInformationParser();

  @override
  Future<ToUri> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(ToUri(uri: routeInformation.uri));
  }

  @override
  RouteInformation? restoreRouteInformation(ToUri configuration) {
    return RouteInformation(uri: configuration.uri);
  }
}

class _RouterDelegate extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  _RouterDelegate({
    required this.router,
    required Temp_Screen initial,
    required Temp_Navigable navigable,
  })  : _pages = List.from([initial._page], growable: true),
        _navigable = navigable;

  final ToRouter router;
  final List<_Page> _pages;
  final Temp_Navigable _navigable;

  @override
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: "myNavigator");

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) {
    _push(configuration.uri.toString());
    return SynchronousFuture(null);
  }

  Future<R?> _push<R>(String location) {
    Temp_Screen screen = _navigable.switchTo(location);
    _Page page = screen._page;
//把completer的完成指责放权给各Screen后，框架需监听其完成后删除Page
//并在onPopPage后
    page.completer.future.whenComplete(() {
      _pages.remove(page);
      notifyListeners();
    });
    _pages.add(page);
    notifyListeners();
    return page.completer.future as Future<R?>;
  }

  @override
  Future<void> setRestoredRoutePath(RouteInformation configuration) {
    return setNewRoutePath(configuration);
  }

  @override
  RouteInformation? get currentConfiguration {
    if (_pages.isEmpty) return null;
    return RouteInformation(uri: Uri.parse(_pages.last.name ?? "/"));
  }

  Widget _build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        if (_pages.isEmpty) {
          return true;
        }
        var page = _pages.removeLast();
//把completer的完成指责放权给各Screen自己后，
//如果由系统back button触发onPopPage，框架应使completer完成，要不会泄露Future
        if (!page.completer.isCompleted) {
          page.completer.complete(null);
        }
        notifyListeners();
        return true;
      },
//!!! toList()非常重要! 如果传入的pages是同一个ref，flutter会认为无变化
      pages: _pages.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Navigator(
      builder: _build,
      router: router,
    );
  }
}

/// A: Screen参数类型，R: push返回值类型
class _Page<R> extends MaterialPage<R> {
  _Page({required super.name, required super.child}) : super(key: ValueKey(keyGen++));

  @protected
  final Completer<R?> completer = Completer();

  static int keyGen = 0;
}

/// A: Screen参数类型，R: push返回值类型
mixin Temp_Screen<R> on Widget {
  @protected
  late final _Page<R> _page = _Page(name: location, child: this);

  @protected
  String get location;

  @protected
  Uri get uri => Uri.parse(location);

  // @protected
  // Future<R?> push(BuildContext context) {
  //   return _ToNavigator.of(context).push<R>(location.toString());
  // }

  @override
  String toStringShort() {
    return "Screen(${_page.name})";
  }
}

/// navigator_v2.dart 是更初级的包，用此类隔离其他包的依赖性
mixin Temp_Navigable {
  Temp_Screen get initial;

  Temp_Screen switchTo(String location);
}
