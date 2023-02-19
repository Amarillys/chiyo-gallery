import "dart:io";

abstract class BaseStorage {
  late String externalStoragePath;
  Future<List<FileSystemEntity>> dirFiles(String path, [List<String> extensions]);
  File readFileSync(String path);
  String getExternalStoragePath();
  Future<bool> grantPermission();
}