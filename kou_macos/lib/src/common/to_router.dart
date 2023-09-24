import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kou_macos/src/common/log.dart';

mixin LayoutMixin on Widget {}

mixin RoutePageMixin on Widget {}

typedef LayoutBuilder = LayoutMixin Function(BuildContext context);

class RouteState {}

typedef PageBuilder = Widget Function(BuildContext context, RouteState state);

class ToConfig{
  To root;
  ToConfig({required this.root});
}

/// Go == Route , Route名字被系统包占用，用Go替代
/// 官方的go_router内部略显复杂，且没有我们想要的layout等功能，所以自定一个简化版的to_router
class To {
  To({
    required this.name,
    this.layout,
    this.page,
    this.children = const [],
  }) {
    for (var route in children) {
      route.parent = this;
    }
  }

  final String name;
  late final To? parent;
  final LayoutBuilder? layout;
  final PageBuilder? page;
  List<To> children;

  To children2(List<To> children) {
    return To(name: name, layout: layout, page: page, children: children);
  }

  To child2(To go) {
    return To(name: name, layout: layout, page: page, children: children);
  }

  To call(List<To> children) {
    return To(name: name, layout: layout, page: page, children: children);
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

  @override
  String toString({bool deep = false}) {
    if (!deep) return "<Route path='$name' routes=[${children.length}]/>";
    return _toStringDeep(level: 0);
  }

  String _toStringDeep({int level = 0}) {
    if (children.isEmpty) {
      return "${"  " * level}<Route name='$name'/>";
    }

    return '''${"  " * level}<Route name='$name'>
${children.map((e) => e._toStringDeep(level: level + 1)).join("\n")}
${"  " * level}</Route>''';
  }
}

class RouteInstance {}

/// navigator_v2 是基础包，不依赖其他业务代码
class ToNavigator extends StatelessWidget {
  const ToNavigator._({
    required GlobalKey<NavigatorState> navigatorKey,
    required List<_Page<dynamic>> pages,
    required dynamic Function() notifyListeners,
    required _MyRouterDelegate routerDelegate,
  })  : _navigatorKey = navigatorKey,
        _notifyListeners = notifyListeners,
        _pages = pages,
        _routerDelegate = routerDelegate;

  final GlobalKey<NavigatorState> _navigatorKey;
  final List<_Page> _pages;
  final Function() _notifyListeners;
  final _MyRouterDelegate _routerDelegate;

  static ToNavigator of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ToNavigator>()!;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
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
        _notifyListeners();
        return true;
      },
      //!!! toList()非常重要! 如果传入的pages是同一个ref，flutter会认为无变化
      pages: _pages.toList(),
    );
  }

  Future<R?> push<R>(String location) {
    return _routerDelegate._push<R>(location);
  }

  static RouterConfig<RouteInformation> config({required Navigable navigable}) {
    return RouterConfig(
      routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(
        uri: navigable.initial.uri,
      )),
      routerDelegate: LoggableRouterDelegate(
          logger: logger,
          delegate: _MyRouterDelegate(
            initial: navigable.initial,
            navigable: navigable,
          )),
      routeInformationParser: _Parser(),
    );
  }
}

class _Parser extends RouteInformationParser<RouteInformation> {
  _Parser();

  @override
  Future<RouteInformation> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(routeInformation);
  }

  @override
  RouteInformation? restoreRouteInformation(RouteInformation configuration) {
    return configuration;
  }
}

class _MyRouterDelegate extends RouterDelegate<RouteInformation> with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  _MyRouterDelegate({
    required Screen initial,
    required Navigable navigable,
  })  : _pages = List.from([initial._page], growable: true),
        _navigable = navigable;

  final List<_Page> _pages;
  final Navigable _navigable;
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: "myNavigator");

  @override
  Widget build(BuildContext context) {
    return ToNavigator._(
      routerDelegate: this,
      navigatorKey: navigatorKey,
      pages: _pages,
      notifyListeners: notifyListeners,
    );
  }

  @override
  Future<void> setNewRoutePath(RouteInformation configuration) {
    _push(configuration.uri.toString());
    return SynchronousFuture(null);
  }

  Future<R?> _push<R>(String location) {
    Screen screen = _navigable.switchTo(location);
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
}

/// A: Screen参数类型，R: push返回值类型
class _Page<R> extends MaterialPage<R> {
  _Page({required super.name, required super.child}) : super(key: ValueKey(keyGen++));

  @protected
  final Completer<R?> completer = Completer();

  static int keyGen = 0;
}

/// A: Screen参数类型，R: push返回值类型
mixin Screen<R> on Widget {
  @protected
  late final _Page<R> _page = _Page(name: location, child: this);

  @protected
  String get location;

  @protected
  Uri get uri => Uri.parse(location);

  @protected
  Future<R?> push(BuildContext context) {
    return ToNavigator.of(context).push<R>(location.toString());
  }

  @override
  String toStringShort() {
    return "Screen(${_page.name})";
  }
}

/// navigator_v2.dart 是更初级的包，用此类隔离其他包的依赖性
mixin Navigable {
  Screen get initial;

  Screen switchTo(String location);
}