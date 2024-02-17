import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/log.dart';
import 'package:path/path.dart' as path_;

/*
ref: https://github.com/react-navigation/react-navigation


## 用例：聊天窗口在
  手机屏：push新page
  桌面屏：层级展示（没有push新page）
  旷世难题：通过route 的tree配置，而不是push等接口来决定是否增加page栈
### 方案1:
/
  main layout:MainWindowLayout
    chat layout:ChatsLayout page:chatsPage(空页面)  // windows:默认， mobile:/pushUpPage/main/chat/1 ,
      [user_id] page: chatPage
    通讯录
    发现
    我
  pushUpPage newRouteBehaviour:pop  // 切换新路由，pop弹出有返回按钮的页面
    main
      chat
        [user_id]  ref-> /main/chat/user_id

### 方案2:
/
  main layout:MainWindowLayout
    chat layout:ChatsLayout page:chatsPage(空页面)  // windows:默认， mobile:/pushUpPage/main/chat/1 ,
      [user_id] page:chatPage , layoutRetry:LayoutRetry.up   // fallStrategy: 页面踏空策略，如果页面没有被上游layout处理，则用此此略push一个新page
    通讯录
    发现
    我
 */

typedef PageBuilder = Widget Function(ToLocation location);
typedef LayoutBuilder = Widget Function(BuildContext context, ToLocation location, Widget content);

class NotFoundError extends ArgumentError {
  NotFoundError({required Uri invalidValue, String name = "uri", String message = "Not Found"})
      : super.value(invalidValue, name, message);
}

extension UriExt on Uri {
  /// Creates a new `Uri` based on this one, but with some parts replaced.
  Uri join(String child) => replace(pathSegments: ["", ...pathSegments, child]);
}

class ToRouter {
  final To root;

  ToRouter({required this.root}) : assert(root.uriTemplate == "/");

  static ToRouter of(BuildContext context) {
    var result = context.findAncestorWidgetOfExactType<_RouterScope>();
    assert(result != null, "应把ToRouter配置到您的App中: MaterialApp.router(routerConfig:ToRouter(...))");
    return result!.router;
  }

  ToLocation matchUri(Uri uri) {
    assert(uri.path.startsWith("/"));
    if (uri.path == "/") return ToLocation._(uri: uri, to: root);

    Map<String, String> params = {};
    return root._match(uri: uri, segments: uri.pathSegments, params: params);
  }

  ToLocation match(String uri) {
    return matchUri(Uri.parse(uri));
  }

  // [PlatformRouteInformationProvider.initialRouteInformation]
  RouterConfig<Object> toRouterConfig({required Uri initial, required GlobalKey<NavigatorState> navigatorKey}) {
    return RouterConfig<Object>(
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: RouteInformation(
          uri: initial,
        ),
      ),
      routerDelegate: LoggableRouterDelegate(
          logger: logger,
          delegate: _RouterDelegate(
            navigatorKey: navigatorKey,
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

enum ToType {
  /// 正常路径片段: /settings
  static,

  /// 动态参数  /user/[id]  :
  ///     /user/1 -> id==1
  dynamic,

  /// 动态参数  /file/[...path]  :
  ///     /file/a.txt  ->  path==a.txt
  ///     /file/a/b/c.txt -> path==a/b/c.txt
  dynamicAll;

  static ToType parse(String name) {
    return ToType.static;
  }
}

/// static type route instance
mixin ToPageMixin on Widget {
  Uri get uri;
}

/// To == go_router.GoRoute
/// 官方的go_router内部略显复杂，且没有我们想要的layout等功能，所以自定一个简化版的to_router
class To {
  final String part;
  late final String _name;
  late final ToType _type;

  To? _parent;

  final LayoutRetry layoutRetry;
  final List<To> children;
  final PageBuilder? page;
  final LayoutBuilder? layout;

  To(
    this.part, {
    this.page,
    this.layout,
    this.layoutRetry = LayoutRetry.none,
    this.children = const [],
  }) : assert(part == "/" || !part.contains("/"), "part:'$part' should be '/' or legal directory name") {
    var parsed = _parse(part);
    _name = parsed.$1;
    _type = parsed.$2;

    for (var route in children) {
      route._parent = this;
    }
  }

  bool get isRoot => _parent == null;

  String get uriTemplate => isRoot ? "/" : path_.join(_parent!.uriTemplate, part);

  List<To> get ancestors => isRoot ? [] : [_parent!, ..._parent!.ancestors];

  To child(String part) {
    return children.singleWhere((e) => e.part == part);
  }

  To? _matchChild({required String segment}) {
    To? matched = children.where((e) => e._type == ToType.static).where((e) => segment == e._name).firstOrNull;
    if (matched != null) return matched;
    matched = children.where((e) => e._type == ToType.dynamic || e._type == ToType.dynamicAll).firstOrNull;
    if (matched != null) return matched;
    return null;
  }

  ToLocation _match({
    required Uri uri,
    required List<String> segments,
    required Map<String, String> params,
  }) {
    assert(segments.isNotEmpty);

    var [next, ...rest] = segments;

    // 忽略后缀'/'
    // next=="" 代表最后以 '/' 结尾,当前 segments==[""]
    if (_type == ToType.static && next == "") {
      return ToLocation._(uri: uri, to: this, params: params);
    }

    To? matchedNext = _matchChild(segment: next);
    if (matchedNext == null) {
      throw NotFoundError(invalidValue: uri);
    }

    if (matchedNext._type == ToType.dynamicAll) {
      // /tree/[...file]
      //     /tree/x/y   --> {"file":"x/y"}
      //     /tree/x/y/  --> {"file":"x/y/"}
      // dynamicAll param must be last
      params[matchedNext._name] = segments.join("/");
      return ToLocation._(uri: uri, to: matchedNext, params: params);
    } else {
      if (next == "") {
        return ToLocation._(uri: uri, to: this, params: params);
      }
      if (matchedNext._type == ToType.dynamic) {
        params[matchedNext._name] = next;
      }
    }

    if (rest.isEmpty) {
      return ToLocation._(uri: uri, to: matchedNext, params: params);
    }

    return matchedNext._match(uri: uri, segments: rest, params: params);
  }

  /// tree to list
  /// /a
  ///   - /a/1
  ///   - /a/2
  ///
  /// a.toList(includeThis:true)
  ///          => [/a,/a/1,/a/2]
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
  static (String, ToType) _parse(String pattern) {
    assert(pattern.isNotEmpty);

    if (pattern[0] != "[" || pattern[pattern.length - 1] != "]") {
      return (pattern, ToType.static);
    }

    assert(pattern != "[]");
    assert(pattern != "[...]");

    // name 现在是[...xxx]或[xx]

    final removeBrackets = pattern.substring(1, pattern.length - 1);

    if (removeBrackets.startsWith("...")) {
      return (removeBrackets.substring(3), ToType.dynamicAll);
    } else {
      return (removeBrackets, ToType.dynamic);
    }
  }

  @override
  String toString({bool deep = false}) {
    if (!deep) return "<Route path='$uriTemplate' children.length=${children.length} />";
    return _toStringDeep(level: 0);
  }

  String _toStringDeep({int level = 0}) {
    if (children.isEmpty) {
      return "${"  " * level}<Route path='$uriTemplate' />";
    }

    return '''${"  " * level}<Route path='$uriTemplate' >
${children.map((e) => e._toStringDeep(level: level + 1)).join("\n")}
${"  " * level}</Route>''';
  }
}

class ToLocation {
  final To to;
  final Uri uri;
  final Map<String, String> params;

  ToLocation._({
    required this.uri,
    required this.to,
    this.params = const {},
  });
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

class _RouteInfo {
  static int pageKeyGen = 0;

  final ToLocation location;

  _RouteInfo({required this.location});

  get uri => location.uri;

  Page<dynamic> build(BuildContext context) {
    var to = location.to;
    if (to.page == null) {
      throw NotFoundError(invalidValue: location.uri);
    }
    Widget content = to.page!(location);
    for (var x in [to, ...to.ancestors]) {
      if (x.layout != null) {
        content = x.layout!(context, location, content);
      }
    }
    return MaterialPage(key: ValueKey(pageKeyGen++), child: content);
  }

  @override
  String toString() {
    return "uri:'${location.uri}'";
  }
}

class _RouteInformationParser extends RouteInformationParser<_RouteInfo> {
  final ToRouter router;

  _RouteInformationParser({required this.router});

  @override
  Future<_RouteInfo> parseRouteInformation(RouteInformation routeInformation) {
    ToLocation location = router.matchUri(routeInformation.uri);
    return SynchronousFuture(_RouteInfo(location: location));
  }

  @override
  RouteInformation? restoreRouteInformation(_RouteInfo configuration) {
    return RouteInformation(uri: configuration.uri);
  }
}

class _RouterDelegate extends RouterDelegate<_RouteInfo>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<_RouteInfo> {
  final ToRouter router;
  final List<_RouteInfo> stack;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  _RouterDelegate({
    required this.router,
    required this.navigatorKey,
  }) : stack = [];

  @override
  Future<void> setNewRoutePath(_RouteInfo configuration) {
    stack.add(configuration);
    return SynchronousFuture(null);
  }

  @override
  Future<void> setRestoredRoutePath(_RouteInfo configuration) {
    return setNewRoutePath(configuration);
  }

  @override
  _RouteInfo? get currentConfiguration {
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
      pages: stack.map((e) => e.build(context)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _RouterScope(
      builder: _build,
      router: router,
    );
  }
}
