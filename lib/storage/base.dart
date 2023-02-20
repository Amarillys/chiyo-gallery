import "dart:io";

abstract class BaseStorage {
  late String initStoragePath;
  late List<String> externalStoragePath;
  Future<List<FileSystemEntity>> dirFiles(String path, [List<String> extensions]);
  File readFileSync(String path);
  List<String> getExternalStoragePath();
  Future<bool> grantPermission();
}