import 'package:file/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:younpc/src/core/conf.dart';

class You {
  final Directory dataDir;
  final RootConf conf;

  You._({required this.dataDir, required this.conf});

  static Future<You> load({required Directory dataDir}) async {
    await dataDir.create(recursive: true);
    debugPrint(dataDir.toString());
    var confFile = dataDir.childFile("conf.json");
    return You._(dataDir: dataDir, conf: await RootConf.load(confFile));
  }
}
