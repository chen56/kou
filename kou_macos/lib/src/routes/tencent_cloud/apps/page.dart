import 'package:kou_macos/src/common/to_router.dart';
import 'package:kou_macos/src/routes/tencent_cloud/apps/[app]/page.dart';

class AppsRoute extends RouteInstance {
  AppsRoute({required RouteInstance parent}) : super(uri: parent.uriJoin("apps"));

  AppRoute get app => appRoute(this);
}
