import 'dart:io';
import 'dart:convert';

class ConfigMap {
  static const String baseColor = 'baseColor';
  static const String collections = 'collections';
  static const String descFontColor = 'descFontColor';
  static const String initPath = 'initPath';
  static const String thumbnailWidth = 'thumbnailWidth';
  static const String language = 'language';
  static const String layoutType = 'layoutType';
  static const String showHidden = 'showHidden';
  static const String sortType = 'sortType';
}

class GlobalConfig {
  String? _appDataPath;
  static String? _dataPath;// same with _appDataPath
  static ConfigData? _data;
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
    _data = ConfigData.fromMap(jsonData);
    return _instance!;
  }

  GlobalConfig._internal(this._appDataPath);

  GlobalConfig get instance => _instance!;

  ConfigData get data => _data!;

  static get(String key) {
    return _data![key];
  }

  static set(String key, value) {
    _data![key] = value;
    save();
  }

  static save() {
    final configFile = File(dataPath!);
    var encoder = const JsonEncoder.withIndent("  ");
    configFile.writeAsString(encoder.convert(_data));
  }

  static String? get dataPath => _dataPath;
}

class ConfigData {
  String? baseColor;
  List<String>? collections;
  String? descFontColor;
  String? initPath;
  String language;
  String? _layoutType;
  bool? showHidden;
  double? thumbnailWidth;
  String? sortType;

  ConfigData({ this.baseColor = 'pink',
    this.collections = const [],
    this.descFontColor = '802020B0',
    this.initPath = '',
    this.language = 'zh-CN',
    this.thumbnailWidth = 300,
    String? layoutType = 'list',
    this.showHidden,
    this.sortType
  }): _layoutType = layoutType;

  factory ConfigData.fromMap(Map<String, dynamic> inputMap) {
    inputMap[ConfigMap.collections] ??= [];
    final List<String> inputCollections = inputMap[ConfigMap.collections].map<String>((collection) => collection.toString()).toList();
    inputMap[ConfigMap.baseColor] ??= 'pink';
    inputMap[ConfigMap.descFontColor] ??= '802020B0';
    inputMap[ConfigMap.initPath] ??= '';
    inputMap[ConfigMap.language] ??= 'zh-CN';
    inputMap[ConfigMap.layoutType] ??= 'list';
    inputMap[ConfigMap.showHidden] ??= false;
    inputMap[ConfigMap.thumbnailWidth] ??= 300.0;
    inputMap[ConfigMap.sortType] ??= 'alpha-up';
    return ConfigData(
      baseColor: inputMap[ConfigMap.baseColor],
      collections: inputCollections,
      descFontColor: inputMap[ConfigMap.descFontColor],
      initPath: inputMap[ConfigMap.initPath],
      language: inputMap[ConfigMap.language],
      layoutType: inputMap[ConfigMap.layoutType],
      showHidden: inputMap[ConfigMap.showHidden],
      sortType: inputMap[ConfigMap.sortType],
      thumbnailWidth: inputMap[ConfigMap.thumbnailWidth]
    );
  }

  operator[](String key) {
    switch (key) {
      case ConfigMap.baseColor:
        return baseColor;
      case ConfigMap.collections:
        return collections;
      case ConfigMap.descFontColor:
        return descFontColor;
      case ConfigMap.initPath:
        return initPath;
      case ConfigMap.language:
        return language;
      case ConfigMap.layoutType:
        return _layoutType;
      case ConfigMap.showHidden:
        return showHidden;
      case ConfigMap.sortType:
        return sortType;
      case ConfigMap.thumbnailWidth:
        return thumbnailWidth;
    }
  }

  operator[]=(String key, value) {
    switch (key) {
      case ConfigMap.baseColor:
        baseColor = value;
        break;
      case ConfigMap.collections:
        collections = value;
        break;
      case ConfigMap.descFontColor:
        descFontColor = value;
        break;
      case ConfigMap.initPath:
        initPath = value;
        break;
      case ConfigMap.language:
        language = value;
        break;
      case ConfigMap.layoutType:
        _layoutType = value;
        break;
      case ConfigMap.showHidden:
        showHidden = value;
        break;
      case ConfigMap.sortType:
        sortType = value;
        break;
      case ConfigMap.thumbnailWidth:
        thumbnailWidth = value;
        break;
    }
  }

  String get layoutType => _layoutType!;

  set layoutType(String value) {
    _layoutType = value;
    GlobalConfig.save();
  }

  Map<String, dynamic> toJson() {
    return {
      "baseColor": baseColor,
      "collections": collections,
      "descFontColor": descFontColor,
      "initPath": initPath,
      "language": language,
      "layoutType": _layoutType,
      "showHidden": showHidden,
      "sortType": sortType,
      "thumbnailWidth": thumbnailWidth
    };
  }
}