
import 'package:younpc/src/common/to_router.dart';
import 'package:younpc/src/routes/layout.dart';
import 'package:younpc/src/routes/machines/%5Bmachine%5D/page.dart';
import 'package:younpc/src/routes/machines/page.dart';
import 'package:younpc/src/routes/page.dart';

ToRouter _createRouter() {
  To root = To("/", body: RootPage.fromURI, layout: RootLayout.layout, page: RootPage.page, children: [
    To("machines", body: MachinesPage.fromURI, children: [
      To("[machine]", body: MachinePage.fromURI),
    ]),
  ]);
  return ToRouter(root: root);
}

ToRouter router = _createRouter();