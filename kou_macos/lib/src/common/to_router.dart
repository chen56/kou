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

typedef PageBuilder = ToPage Function(ToLocation location);
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

  /// must exist uri
  To getUri(Uri uri) {
    To result = root;
    for (var segment in uri.pathSegments.where((e) => e != "")) {
      result = result.children.where((e) => e.part == segment).first;
    }
    return result;
  }

  To get(String uri) {
    return getUri(Uri.parse(uri));
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

abstract mixin class ToHandler {
  String get uriTemplate;

  @override
  String toString() => uriTemplate;

  Widget? layout(BuildContext context, ToLocation location, Widget content) => null;

  Widget build(BuildContext context, ToLocation location);
}

class _EmptyHandler with ToHandler {
  const _EmptyHandler();

  @override
  String get uriTemplate => "/_empty_route";

  @override
  Widget build(BuildContext context, ToLocation location) {
    return const Text("...");
  }
}

/// static type route instance
abstract class ToPage {
  Uri get uri;

  Widget build(BuildContext context);
}

@Deprecated("temp stub use")
class TODORemove extends ToPage {
  final ToLocation location;

  TODORemove(this.location);

  factory TODORemove.parse(ToPage parent, ToLocation location) {
    return TODORemove(location);
  }

  @override
  Uri get uri => location.uri;

  @override
  Widget build(BuildContext context) {
    return const Text("...");
  }

}

ToPage _emptyScreen(ToLocation location) {
  return TODORemove(location);
}

/// To == go_router.GoRoute
/// 官方的go_router内部略显复杂，且没有我们想要的layout等功能，所以自定一个简化版的to_router
class To {
  ToHandler handler;
  final String part;
  late final String _paramName;
  late final ToType _paramType;

  To? _parent;

  final LayoutRetry layoutRetry;
  late final List<To> children;
  final PageBuilder pageSpecBuilder;
  final LayoutBuilder? layout;

  To(this.part,
      {this.handler = const _EmptyHandler(),
      PageBuilder? page,
      this.layout,
      this.layoutRetry = LayoutRetry.none,
      List<To>? children})
      : assert(part == "/" || !part.contains("/"), "part:'$part' assert fail"),
        children = children ?? List.empty(growable: true),
        pageSpecBuilder = page ?? _emptyScreen {
    var parsed = _parse(part);
    _paramName = parsed.$1;
    _paramType = parsed.$2;

    for (var route in this.children) {
      route._parent = this;
    }
  }

  static To fromHandlers(List<ToHandler> handlers) {
    To result = To("/");
    for (ToHandler h in handlers) {
      if (h.uriTemplate == "/") {
        result.handler = h;
        continue;
      }

      var parts = h.uriTemplate.split("/").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      var to = result._ensurePath(parts);
      to.handler = h;
    }
    return result;
  }

  To _ensurePath(List<String> parts) {
    if (parts.isEmpty) {
      return this;
    }
    String name = parts[0];
    assert(name != "" && name != "/", "path:$parts, path[0]:'$name' must not be '' and '/' ");
    var findNext = children.where((e) => e.part == name);
    var next = findNext.firstOrNull;
    if (next == null) {
      next = To(name, page: pageSpecBuilder);
      next._parent = this;
      children.add(next);
    }

    return next._ensurePath(parts.sublist(1));
  }

  bool get isRoot => _parent == null;

  String get uriTemplate => isRoot ? "/" : path_.join(_parent!.uriTemplate, part);

  List<To> get ancestors => isRoot ? [] : [_parent!, ..._parent!.ancestors];

  List<To> get listToRoot => [this, ...ancestors];

  To child(String part) {
    return children.singleWhere((e) => e.part == part);
  }

  To? _matchChild({required String segment}) {
    To? matched =
        children.where((e) => e._paramType == ToType.static).where((e) => segment == e._paramName).firstOrNull;
    if (matched != null) return matched;
    matched = children.where((e) => e._paramType == ToType.dynamic || e._paramType == ToType.dynamicAll).firstOrNull;
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
    if (_paramType == ToType.static && next == "") {
      return ToLocation._(uri: uri, to: this, params: params);
    }

    To? matchedNext = _matchChild(segment: next);
    if (matchedNext == null) {
      throw NotFoundError(invalidValue: uri);
    }

    if (matchedNext._paramType == ToType.dynamicAll) {
      // /tree/[...file]
      //     /tree/x/y   --> {"file":"x/y"}
      //     /tree/x/y/  --> {"file":"x/y/"}
      // dynamicAll param must be last
      params[matchedNext._paramName] = segments.join("/");
      return ToLocation._(uri: uri, to: matchedNext, params: params);
    } else {
      if (next == "") {
        return ToLocation._(uri: uri, to: this, params: params);
      }
      if (matchedNext._paramType == ToType.dynamic) {
        params[matchedNext._paramName] = next;
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

class ToRouteInfo {
  static int pageKeyGen = 0;

  final ToLocation location;

  ToRouteInfo({required this.location});

  get uri => location.uri;

  Page<dynamic> build(BuildContext context) {
    var content = location.to.handler.build(context, location);
    for (var x in location.to.listToRoot) {
      Widget? tryLayout = x.handler.layout(context, location, content);
      if (tryLayout != null) {
        content = tryLayout;
      }
    }
    return MaterialPage(key: ValueKey(pageKeyGen++), child: content);
  }

  @override
  String toString() {
    return "uri:'${location.uri}'";
  }
}

class _RouteInformationParser extends RouteInformationParser<ToRouteInfo> {
  final ToRouter router;

  _RouteInformationParser({required this.router});

  @override
  Future<ToRouteInfo> parseRouteInformation(RouteInformation routeInformation) {
    ToLocation location = router.matchUri(routeInformation.uri);
    return SynchronousFuture(ToRouteInfo(location: location));
  }

  @override
  RouteInformation? restoreRouteInformation(ToRouteInfo configuration) {
    return RouteInformation(uri: configuration.uri);
  }
}

class _RouterDelegate extends RouterDelegate<ToRouteInfo>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<ToRouteInfo> {
  final ToRouter router;
  final List<ToRouteInfo> stack;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  _RouterDelegate({
    required this.router,
    required this.navigatorKey,
  }) : stack = [];

  @override
  Future<void> setNewRoutePath(ToRouteInfo configuration) {
    stack.add(configuration);
    return SynchronousFuture(null);
  }

  @override
  Future<void> setRestoredRoutePath(ToRouteInfo configuration) {
    return setNewRoutePath(configuration);
  }

  @override
  ToRouteInfo? get currentConfiguration {
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
