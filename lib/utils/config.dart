import 'package:chiyo_gallery/storage/storage.dart';

class Config {
  String _initPath = '';

  static final Config _singleton = Config._internal();
  static final storage = Storage.instance;

  factory Config() {
    return _singleton;
  }

  Config._internal() {
    // 初始化配置
    _initPath = storage.externalStoragePath;
  }

  String get initPath => _initPath;

  void setInitPath(String path) {
    _initPath = path;
  }

}