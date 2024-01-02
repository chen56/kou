// format json
import 'dart:convert';

import 'package:file/file.dart';

JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

/// kou.conf.json
class KouConf {
  final Map<String, MachineConf> machines = {};

  Map<String, dynamic> encode() {
    return {
      "machines": machines.map((key, value) => MapEntry(key, value)),
    };
  }

  KouConf.decode(Map<String, dynamic> json) {
    json["machines"]?.forEach((key, value) {
      machines[key] = MachineConf.decode(value is Map<String, dynamic> ? value : {});
    });
  }

  static Future<KouConf> load(File jsonFile) async {
    if (!await jsonFile.exists()) {
      return KouConf.decode({});
    }

    Map<String, dynamic> json = jsonDecode(await jsonFile.readAsString());
    return KouConf.decode(json);
  }

  Future<KouConf> save(File file) async {
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
