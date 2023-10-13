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

typedef LayoutBuilder = Widget Function(BuildContext context);
typedef PageBuilder = Widget Function(BuildContext context, RouteState state);

class RouteState {}

class ToRouter {
  To root;

  ToRouter({required this.root}) : assert(root.path == "/");

  static ToRouter of(BuildContext context) {
    var result = context.findAncestorWidgetOfExactType<_Navigator>();
    assert(result != null, "应把ToRouter配置到您的App中: MaterialApp.router(routerConfig:ToRouter(...))");
    return result!.router;
  }

  MatchTo matchUri(Uri uri) {
    assert(uri.path.startsWith("/"));
    if (uri.path == "/") return MatchTo._(uri: uri, to: root);

    Map<String, String> params = {};
    return root._match(uri: uri, segments: uri.pathSegments, params: params);
  }

  MatchTo match(String uri) {
    return matchUri(Uri.parse(uri));
  }

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
    this.notFound,
    this.children = const [],
  })  : assert(children.isNotEmpty || page != null),
        assert(part == "/" || !part.contains("/"), "part:'$part' assert fail") {
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
  final PageBuilder? notFound;
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

  MatchTo _match({
    required Uri uri,
    required List<String> segments,
    required Map<String, String> params,
  }) {
    assert(segments.isNotEmpty);

    var [next, ...rest] = segments;

    // 忽略后缀'/'
    // next=="" 代表最后以 '/' 结尾,当前 segments==[""]
    if (_paramType == ToNodeType.static && next == "") {
      return MatchTo._(uri: uri, to: this, params: params);
    }

    To? matchedNext = _matchChild(segment: next);
    if (matchedNext == null) {
      return MatchTo._(uri: uri, to: this, params: params, isNotFound: true);
    }

    if (matchedNext._paramType == ToNodeType.dynamicAll) {
      // /tree/[...file]
      //     /tree/x/y   --> {"file":"x/y"}
      //     /tree/x/y/  --> {"file":"x/y/"}
      // dynamicAll param must be last
      params[matchedNext._paramName] = segments.join("/");
      return MatchTo._(uri: uri, to: matchedNext, params: params);
    } else {
      if (next == "") {
        return MatchTo._(uri: uri, to: this, params: params);
      }
      if (matchedNext._paramType == ToNodeType.dynamic) {
        params[matchedNext._paramName] = next;
      }
    }

    if (rest.isEmpty) {
      return MatchTo._(uri: uri, to: matchedNext, params: params);
    }

    return matchedNext._match(uri: uri, segments: rest, params: params);
  }

  List<To> toList({
    bool includeThis = true,
    bool Function(To path)? where,
    Comparator<To>? sortBy,
  }) {
    where = where ?? (e) => true;
    if (!where(this)) {
      return [];
    }
    List<To> sorted = List.from(children);
    if (sortBy != null) {
      sorted.sort(sortBy);
    }

    var flatChildren = sorted.expand((child) {
      return child.toList(includeThis: true, where: where, sortBy: sortBy);
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
    if (!deep) return "<Route path='$path' children.length=${children.length} />";
    return _toStringDeep(level: 0);
  }

  String _toStringDeep({int level = 0}) {
    if (children.isEmpty) {
      return "${"  " * level}<Route path='$path' />";
    }

    return '''${"  " * level}<Route path='$path' >
${children.map((e) => e._toStringDeep(level: level + 1)).join("\n")}
${"  " * level}</Route>''';
  }
}

class MatchTo {
  final To to;
  final Uri uri;
  final Map<String, String> params;
  final bool isNotFound;

  MatchTo._({required this.uri, required this.to, this.params = const {}, this.isNotFound = false});
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

class _ToRouteInformation {
  final Uri uri;

  _ToRouteInformation({required this.uri});
}

class _RouteInformationParser extends RouteInformationParser<_ToRouteInformation> {
  _RouteInformationParser();

  @override
  Future<_ToRouteInformation> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(_ToRouteInformation(uri: routeInformation.uri));
  }

  @override
  RouteInformation? restoreRouteInformation(_ToRouteInformation configuration) {
    return RouteInformation(uri: configuration.uri);
  }
}

class _RouterDelegate extends RouterDelegate<_ToRouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<_ToRouteInformation> {
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
  Future<void> setNewRoutePath(_ToRouteInformation configuration) {
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
  Future<void> setRestoredRoutePath(_ToRouteInformation configuration) {
    return setNewRoutePath(configuration);
  }

  @override
  _ToRouteInformation? get currentConfiguration {
    if (_pages.isEmpty) return null;
    return _ToRouteInformation(uri: Uri.parse(_pages.last.name ?? "/"));
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
