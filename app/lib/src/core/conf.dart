// format json
import 'dart:convert';

import 'package:file/file.dart';

JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

/*
config example:
{
  "version" : "1.0",
  "tencentcloudstack/tencentcloud": [
    {
      "secret_id"  : "my-secret-id",
      "secret_key" : "my-secret-key",
      "vm" :[
        {
          "instance_id":"xxx",
        },
      ]
    }
  ]
}
*/

/// younpc.conf.json
class RootConf {
  final Map<String, MachineConf> machines = {};

  Map<String, dynamic> encode() {
    return {
      "machines": machines.map((key, value) => MapEntry(key, value)),
    };
  }

  RootConf.decode(Map<String, dynamic> json) {
    json["machines"]?.forEach((key, value) {
      machines[key] = MachineConf.decode(value is Map<String, dynamic> ? value : {});
    });
  }

  static Future<RootConf> load(File jsonFile) async {
    if (!await jsonFile.exists()) {
      return RootConf.decode({});
    }

    Map<String, dynamic> json = jsonDecode(await jsonFile.readAsString());
    return RootConf.decode(json);
  }

  Future<RootConf> save(File file) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(_encoder.convert(encode()));
    return this;
  }
}

class MachineConf {
  late String name;

  MachineConf({required this.name});

  Map<String, dynamic> encode() {
    return {
      "name": name,
    };
  }

  MachineConf.decode(Map<String, dynamic> json)
      : this(
          name: json["name"] ?? "",
        );
}
