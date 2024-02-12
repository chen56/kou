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

typedef ToLayoutBuilder = Widget Function(BuildContext context, ToLocation state, Widget content);
typedef PageBuilder = Widget Function(BuildContext context, ToLocation location);
typedef PageSpecBuilder = PageSpec Function(PageSpec parent, ToLocation location);

class NotFound extends ArgumentError {
  NotFound({required Uri invalidValue, String name = "uri", String message = "Not Found"})
      : super.value(invalidValue, name, message);
}

ToLayoutBuilder _emptyLayoutBuilder = (BuildContext context, ToLocation location, Widget content) {
  return content;
};

extension UriExt on Uri {
  /// Creates a new `Uri` based on this one, but with some parts replaced.
  Uri join(String child) => replace(pathSegments: ["", ...pathSegments, child]);
}

class ToRouter {
  final To root;
  final PageSpec _rootPageSpec;

  ToRouter({required this.root, required PageSpec rootToPage})
      : assert(root.path == "/"),
        _rootPageSpec = rootToPage;

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

  R parse<R extends PageSpec>(String uri) {
    return parseUri(Uri.parse(uri));
  }

  R parseUri<R extends PageSpec>(Uri uri) {
    var matchTo = matchUri(uri);
    return matchTo.to._toPageSpec(_rootPageSpec, matchTo) as R;
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

enum PathSegmentType {
  /// 正常路径片段: /settings
  static,

  /// 动态参数  /user/[id]  :
  ///     /user/1 -> id==1
  dynamic,

  /// 动态参数  /file/[...path]  :
  ///     /file/a.txt  ->  path==a.txt
  ///     /file/a/b/c.txt -> path==a/b/c.txt
  dynamicAll;

  static PathSegmentType parse(String name) {
    return PathSegmentType.static;
  }
}

@Deprecated("temp stub use")
class TODORemove extends PageSpec {
  TODORemove();

  factory TODORemove.parse(PageSpec parent, ToLocation to) {
    return TODORemove();
  }

  @override
  Uri get uri => Uri.parse("/");

  @override
  Widget build(BuildContext context) {
    return const Text("/  root page");
  }

  @override
  TODORemove get parent => this;
}

/// static type route instance
abstract class PageSpec {
  PageSpec get parent;

  Uri get uri;

  Widget build(BuildContext context);
}

/// To == go_router.GoRoute
/// 官方的go_router内部略显复杂，且没有我们想要的layout等功能，所以自定一个简化版的to_router
class To {
  To(this.part,
      {ToLayoutBuilder? layout,
      this.layoutRetry = LayoutRetry.none,
      required this.pageSpecBuilder,
      PageBuilder? notFound,
      this.children = const []})
      : assert(part == "/" || !part.contains("/"), "part:'$part' assert fail"),
        _layout = layout ?? _emptyLayoutBuilder {
    var parsed = _parse(part);
    _paramName = parsed.$1;
    _paramType = parsed.$2;

    for (var route in children) {
      route._parent = this;
    }
  }

  final String part;
  late final String _paramName;
  late final PathSegmentType _paramType;

  To? _parent;
  final PageSpecBuilder pageSpecBuilder;
  final ToLayoutBuilder _layout;

  final LayoutRetry layoutRetry;
  late final List<To> children;

  ToLayoutBuilder get layout => _layout;

  bool get isRoot => _parent == null;

  String get path => isRoot ? "/" : path_.join(_parent!.path, part);

  List<To> get ancestors => isRoot ? [] : [_parent!, ..._parent!.ancestors];

  List<To> get listToRoot => [this, ...ancestors];

  To child(String part) {
    return children.singleWhere((e) => e.part == part);
  }

  To? _matchChild({required String segment}) {
    To? matched =
        children.where((e) => e._paramType == PathSegmentType.static).where((e) => segment == e._paramName).firstOrNull;
    if (matched != null) return matched;
    matched = children
        .where((e) => e._paramType == PathSegmentType.dynamic || e._paramType == PathSegmentType.dynamicAll)
        .firstOrNull;
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
    if (_paramType == PathSegmentType.static && next == "") {
      return ToLocation._(uri: uri, to: this, params: params);
    }

    To? matchedNext = _matchChild(segment: next);
    if (matchedNext == null) {
      // throw NotFound(invalidValue: uri);
      // todo remove :
      return ToLocation._(uri: uri, to: this, params: params, isNotFound: true);
    }

    if (matchedNext._paramType == PathSegmentType.dynamicAll) {
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
      if (matchedNext._paramType == PathSegmentType.dynamic) {
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
  static (String, PathSegmentType) _parse(String pattern) {
    assert(pattern.isNotEmpty);

    if (pattern[0] != "[" || pattern[pattern.length - 1] != "]") {
      return (pattern, PathSegmentType.static);
    }

    assert(pattern != "[]");
    assert(pattern != "[...]");

    // name 现在是[...xxx]或[xx]

    final removeBrackets = pattern.substring(1, pattern.length - 1);

    if (removeBrackets.startsWith("...")) {
      return (removeBrackets.substring(3), PathSegmentType.dynamicAll);
    } else {
      return (removeBrackets, PathSegmentType.dynamic);
    }
  }

  @protected
  Widget build(BuildContext context, ToLocation location) {
    return const Text("");
  }

  // Widget buildLayout(BuildContext context, RouteParam state, Widget content) {}

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

  PageSpec _toPageSpec(PageSpec rootPageSpec, ToLocation matchTo) {
    if (isRoot) {
      return pageSpecBuilder(rootPageSpec, matchTo);
    }
    var parentStaticType = _parent!._toPageSpec(rootPageSpec, matchTo);
    return pageSpecBuilder(parentStaticType, matchTo);
  }
}

class ToLocation {
  final To to;
  final Uri uri;
  final Map<String, String> params;
  final bool isNotFound; // todo change to NotFoundException;

  ToLocation._({
    required this.uri,
    required this.to,
    this.params = const {},
    this.isNotFound = false,
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

class RouteParam {
  static int pageKeyGen = 0;

  final ToLocation location;
  final PageSpec pageSpec;

  RouteParam({required this.location, required this.pageSpec});

  get uri => location.uri;

  Page<dynamic> build(BuildContext context) {
    var content = location.to.build(context, location);
    for (var x in location.to.listToRoot) {
      if (x.layout != _emptyLayoutBuilder) {
        content = x.layout(context, location, content);
      }
    }
    return MaterialPage(key: ValueKey(pageKeyGen++), child: content);
  }

  @override
  String toString() {
    return "uri:'${location.uri}'";
  }
}

class _RouteInformationParser extends RouteInformationParser<RouteParam> {
  final ToRouter router;

  _RouteInformationParser({required this.router});

  @override
  Future<RouteParam> parseRouteInformation(RouteInformation routeInformation) {
    // todo Simplify parse pageSpec
    ToLocation location = router.matchUri(routeInformation.uri);
    PageSpec pageSpec = location.to._toPageSpec(router._rootPageSpec, location);
    return SynchronousFuture(RouteParam(location: location, pageSpec: pageSpec));
  }

  @override
  RouteInformation? restoreRouteInformation(RouteParam configuration) {
    return RouteInformation(uri: configuration.uri);
  }
}

class _RouterDelegate extends RouterDelegate<RouteParam>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteParam> {
  final ToRouter router;
  final List<RouteParam> stack;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  _RouterDelegate({
    required this.router,
    required this.navigatorKey,
  }) : stack = [];

  @override
  Future<void> setNewRoutePath(RouteParam configuration) {
    stack.add(configuration);
    return SynchronousFuture(null);
  }

  @override
  Future<void> setRestoredRoutePath(RouteParam configuration) {
    return setNewRoutePath(configuration);
  }

  @override
  RouteParam? get currentConfiguration {
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
