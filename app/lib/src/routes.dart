
import 'package:younpc/src/common/to_router.dart';
import 'package:younpc/src/routes/machines/%5Bmachine%5D/page.dart';
import 'package:younpc/src/routes/machines/page.dart';
import 'package:younpc/src/routes/page.dart';

ToRouter _createRouter() {
  To root = To("/", content: RootPage.content, layout: RootPage.layout, page: RootPage.page, children: [
    To("machines", content: MachinesPage.content, children: [
      To("[machine]", content: MachinePage.content),
    ]),
  ]);
  return ToRouter(root: root);
}

ToRouter router = _createRouter();