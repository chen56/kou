import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/log.dart';
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

typedef LayoutBuilder = Widget Function(BuildContext context, RouteState state, Widget content);
typedef PageBuilder = Widget Function(BuildContext context, RouteState state);

class RouteState {}

class ToRouter {
  To root;

  ToRouter({required this.root}) : assert(root.path == "/");

  static ToRouter of(BuildContext context) {
    var result = context.findAncestorWidgetOfExactType<_RouterScope>();
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

  /// must exist uri
  To getUri(Uri uri){
    To result = root;
    for (var segment in uri.pathSegments.where((e) => e != "")) {
      result = result.children.where((e) => e.part==segment).first;
    }
    return result;
  }

  To get(String uri){
    return getUri(Uri.parse(uri));
  }

  // [PlatformRouteInformationProvider.initialRouteInformation]
  RouterConfig<Object> config({required Uri initial}) {
    return RouterConfig<Object>(
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: RouteInformation(
          uri: initial,
        ),
      ),
      routerDelegate: LoggableRouterDelegate(
          logger: logger,
          delegate: _RouterDelegate(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: "myNavigator"),
            router: this,
          )),
      routeInformationParser: _RouteInformationParser(router: this),
    );
  }
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
    LayoutBuilder? layout,
    this.layoutRetry = LayoutRetry.none,
    PageBuilder? page,
    PageBuilder? notFound,
    this.children = const [],
  })  : assert(children.isNotEmpty || page != null),
        assert(part == "/" || !part.contains("/"), "part:'$part' assert fail"),
        _page = page,
        _layout = layout,
        _notFound = notFound {
    var parsed = _parse(part);
    _paramName = parsed.$1;
    _paramType = parsed.$2;

    for (var route in children) {
      route._parent = this;
    }
  }

  final String part;
  late final String _paramName;
  late final ToNodeType _paramType;

  To? _parent;
  final LayoutBuilder? _layout;
  final PageBuilder? _page;
  final PageBuilder? _notFound;
  final LayoutRetry layoutRetry;
  final List<To> children;

  bool get isRoot => _parent == null;

  String get path => isRoot ? "/" : path_.join(_parent!.path, part);

  List<To> get ancestors => isRoot ? [] : [_parent!, ..._parent!.ancestors];

  List<To> get meAndAncestors => [this, ...ancestors];

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

  Widget buildPageContent(BuildContext context) {
    return _page!(context, RouteState());
  }

  Widget build(BuildContext context) {
    var state = RouteState();
    var content = _page!(context, state);
    for (var to in meAndAncestors) {
      if (to._layout != null) {
        content = to._layout!(context, state, content);
      }
    }
    return content;
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

/// this class only use for store  [router] ,
/// ref: [ToRouter.of]
class _RouterScope extends StatelessWidget {
  const _RouterScope({
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
  final MatchTo matched;

  _ToRouteInformation({required this.matched});

  get uri => matched.uri;
}

class _RouteInformationParser extends RouteInformationParser<_ToRouteInformation> {
  final ToRouter router;

  _RouteInformationParser({required this.router});

  @override
  Future<_ToRouteInformation> parseRouteInformation(RouteInformation routeInformation) {
    MatchTo matchTo = router.matchUri(routeInformation.uri);
    return SynchronousFuture(_ToRouteInformation(matched: matchTo));
  }

  @override
  RouteInformation? restoreRouteInformation(_ToRouteInformation configuration) {
    return RouteInformation(uri: configuration.uri);
  }
}

class _RouterDelegate extends RouterDelegate<_ToRouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<_ToRouteInformation> {
  final ToRouter router;
  final List<_ToRouteInformation> stack;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  _RouterDelegate({
    required this.router,
    required this.navigatorKey,
  }) : stack = [];

  @override
  Future<void> setNewRoutePath(_ToRouteInformation configuration) {
    stack.add(configuration);
    return SynchronousFuture(null);
  }

  @override
  Future<void> setRestoredRoutePath(_ToRouteInformation configuration) {
    return setNewRoutePath(configuration);
  }

  @override
  _ToRouteInformation? get currentConfiguration {
    return stack.isEmpty ? null : stack.last;
  }

  Widget _build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        if (stack.isEmpty) {
          return true;
        }
        stack.removeLast();
        notifyListeners();
        return true;
      },
      pages: stack
          .map((e) => MaterialPage(key: ValueKey(pageKeyGen++), child: e.matched.to.build(context)))
          .toList(),
    );
  }

  static int pageKeyGen = 0;

  @override
  Widget build(BuildContext context) {
    return _RouterScope(
      builder: _build,
      router: router,
    );
  }
}
