import "dart:io";
import 'package:open_file/open_file.dart';

abstract class BaseStorage {
  late String initStoragePath;
  late List<String> externalStoragePath;
  late List<String> cannotAccessPath;

  Future<List<FileSystemEntity>> dirFiles(String folderPath,
      {List<String> extensions = const []});

  File readFileSync(String path);

  List<String> getExternalStoragePath();

  Future<bool> grantPermission();

  Future<ResultType> openFile(String path);

  String convertStoragePathForDisplay(String path);

  String dealPrefixPath(String firstPath);
}
