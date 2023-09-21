
import 'package:flutter/widgets.dart';

mixin LayoutMixin on Widget{

}

mixin RoutePageMixin on Widget {

}


class PageMeta {
  WidgetBuilder builder;

  PageMeta({required this.builder});
}

class RouteMeta {
  RouteMeta({ LayoutMixin? layout, List<RouteMeta>? routes, required String path, PageMeta? page});
}
