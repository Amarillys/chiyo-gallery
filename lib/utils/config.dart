import 'dart:io';
import 'dart:convert';

class ConfigMap {
  static String baseColor = 'base-color';
  static String collections = 'collections';
  static String descFontColor = 'desc-font-Color';
  static String initPath = 'init-path';
  static String thumbnailWidth = 'thumbnail-width';
}

class GlobalConfig {
  String? _appDataPath;
  static String? _dataPath;// same with _appDataPath
  static Map<String, dynamic>? _data;
  static GlobalConfig? _instance;

  factory GlobalConfig(String appDataPath) {
    _instance ??= GlobalConfig._internal(appDataPath);
    _dataPath = '$appDataPath/chiyo-gallery.config.json';

    File configFile = File(_dataPath!);
    if (!configFile.existsSync()) {
      configFile.createSync();
    }

    String jsonString = configFile.readAsStringSync();
    if (jsonString == '') {
      jsonString = '{}';
    }
    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    jsonData[ConfigMap.baseColor] ??= 'pink';
    jsonData[ConfigMap.collections] ??= [];
    jsonData[ConfigMap.descFontColor] ??= '80202020';
    jsonData[ConfigMap.initPath] ??= '';
    jsonData[ConfigMap.thumbnailWidth] ??= 300;
    _data = jsonData;
    return _instance!;
  }

  GlobalConfig._internal(this._appDataPath);

  GlobalConfig get instance => _instance!;

  static get(String key) {
    return _data![key];
  }

  static set(String key, value) {
    _data![key] = value;
    final configFile = File(dataPath!);
    configFile.writeAsString(jsonEncode(_data));
  }

  static String? get dataPath => _dataPath;
}