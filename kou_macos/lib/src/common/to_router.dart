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

  ToRouter({required this.root});

  static ToRouter of(BuildContext context) {
    var result = context.findAncestorWidgetOfExactType<_Navigator>();
    assert(result != null, "应把ToRouter配置到您的App中: MaterialApp.router(routerConfig:ToRouter(...))");
    return result!.router;
  }

//   MatchTo matchUri(Uri uri) {
//   if(uri.path=="/") return root;
//
//   To node = root;
//   var pathSegments= uri.pathSegments;
//   // node.
//
// }
// To match(String uri) {
//    return matchUri(Uri.parse(uri));
// }

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
  normal,

  /// 动态参数  /user/[id]  :
  ///     /user/1 -> id==1
  dynamic,

  /// 动态参数  /file/[...path]  :
  ///     /file/a.txt  ->  path==a.txt
  ///     /file/a/b/c.txt -> path==a/b/c.txt
  dynamicAll;

  static ToNodeType parse(String name) {
    return ToNodeType.normal;
  }
}

class ToNode {
  final String part;
  final ToNodeType type;

  ToNode({required this.part, required this.type});

  /// parse("user")       -->  ToPart(name:"user",type:ToNodeType.normal)
  /// parse("[id]")       -->  ToPart(name:"id",  type:ToNodeType.dynamic)
  /// parse("[...path]")  -->  ToPart(name:"path",type:ToNodeType.dynamicAll)
  static ToNode parse(String name) {
    assert(name.isNotEmpty);

    if (name[0] != "[" || name[name.length - 1] != "]") {
      return ToNode(part: name, type: ToNodeType.normal);
    }

    assert(name != "[]");
    assert(name != "[...]");

    // name 现在是[...xxx]或[xx]

    final removeBrackets = name.substring(1, name.length - 1);

    if (removeBrackets.startsWith("...")) {
      return ToNode(part: removeBrackets.substring(3), type: ToNodeType.dynamicAll);
    } else {
      return ToNode(part: removeBrackets, type: ToNodeType.dynamic);
    }
  }

  @override
  bool operator ==(Object other) => other is ToNode && other.runtimeType == runtimeType && other.part == part && other.type == type;

  @override
  int get hashCode => Object.hash(part, type);

  String toPartString() {
    return switch (type) {
      ToNodeType.dynamic => "[$part]",
      ToNodeType.dynamicAll => "[...$part]",
      _ => part,
    };
  }

  @override
  String toString() {
    return toPartString();
  }
}

/// To == go_router.GoRoute
/// 官方的go_router内部略显复杂，且没有我们想要的layout等功能，所以自定一个简化版的to_router
class To {
  To({
    required String dir,
    this.layout,
    this.layoutRetry = LayoutRetry.none,
    this.page,
    this.children = const [],
  })  : assert(children.isNotEmpty || page != null),
        assert(dir == "/" || !dir.contains("/")),
        node = ToNode.parse(dir) {
    for (var route in children) {
      route.parent = this;
    }
  }

  final ToNode node;

  late final To? parent;
  final LayoutBuilder? layout;
  final PageBuilder? page;
  final LayoutRetry layoutRetry;
  List<To> children;

  bool get isRoot => parent == null;

  String get path => isRoot ? "/" : path_.join(parent!.path, node.part);

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

  @override
  String toString({bool deep = false}) {
    if (!deep) return "<Route path='$node' routes=[${children.length}]/>";
    return _toStringDeep(level: 0);
  }

  String _toStringDeep({int level = 0}) {
    if (children.isEmpty) {
      return "${"  " * level}<Route name='$node'/>";
    }

    return '''${"  " * level}<Route name='$node'>
${children.map((e) => e._toStringDeep(level: level + 1)).join("\n")}
${"  " * level}</Route>''';
  }
}

class MatchTo {}

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

class _RouterDelegate extends RouterDelegate<RouteInformation> with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
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
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: "myNavigator");

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
