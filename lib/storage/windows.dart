import "dart:io";
import 'package:open_file/open_file.dart';
import "package:path/path.dart" as p;

import "base.dart";

class WindowsStorage implements BaseStorage {
  bool withPermission = false;
  @override
  List<String> externalStoragePath = [];
  @override
  String initStoragePath = 'c:/';
  @override
  List<String> cannotAccessPath = [];

  WindowsStorage() {
    grantPermission();
  }

  @override
  Future<bool> grantPermission() async {
    return true;
  }

  @override
  Future<List<FileSystemEntity>> dirFiles(String folderPath, {List<String> extensions = const [], String sortType = 'normal'}) async {
    Directory folder = Directory(folderPath);
    if (!await folder.exists()) {
      throw FileSystemException ('folder does not exist', folderPath);
    }

    List<FileSystemEntity> fileList = await folder.list(recursive: true).toList();
    if (extensions.isEmpty) return fileList;

    return fileList.where((file) {
      if (file is File) {
        String extension = p.extension(file.path).toLowerCase();
        return extensions.contains(extension);
      }
      return false;
    }).toList();
  }

  @override
  File readFileSync(String path) {
    return File(path);
  }

  @override
  List<String> getExternalStoragePath() {
    return externalStoragePath;
  }


  @override
  Future<ResultType> openFile(String path) {
    return Future.value(ResultType.done);
  }
}
