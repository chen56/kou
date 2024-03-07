import 'package:file/file.dart';
import 'package:kou_macos/src/core/conf.dart';

class KouSystem {
  final Directory dataDir;
  final KouConf conf;

  KouSystem._({required this.dataDir, required this.conf});

  static Future<KouSystem> load({required Directory dataDir}) async {
    await dataDir.create(recursive: true);

    var confFile = dataDir.childFile("conf.json");
    return KouSystem._(dataDir: dataDir, conf: await KouConf.load(confFile));
  }
}
