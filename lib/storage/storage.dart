import 'dart:io' show Platform;
import 'android.dart';
import 'base.dart';
import 'windows.dart';

class Storage {
  static final _instance = _getInstance();

  static BaseStorage _getInstance() {
    if (Platform.isAndroid) {
      return AndroidStorage();
    } else if (Platform.isWindows) {
      return WindowsStorage();
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  static BaseStorage get instance => _instance;
}



