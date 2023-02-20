import "dart:io";
import "package:path/path.dart" as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:logger/logger.dart';

import "base.dart";

class AndroidStorage implements BaseStorage {
  bool withPermission = false;
  @override
  List<String> externalStoragePath = [];
  @override
  String initStoragePath = '/storage';

  AndroidStorage() {
    grantPermission();
  }

  @override
  Future<bool> grantPermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        withPermission = true;
      }
    } else {
      withPermission = true;
    }
    if (withPermission) {
      externalStoragePath = await ExternalPath.getExternalStorageDirectories();
    }
    return withPermission;
  }

  @override
  Future<List<FileSystemEntity>> dirFiles(String folderPath, [List<String> extensions = const []]) async {
    if (folderPath == '/storage') {
      return Future.value(externalStoragePath.map((storagePath) => Directory(storagePath)).toList());
    }
    Directory folder = Directory(folderPath);
    if (!await folder.exists()) {
      throw FileSystemException ('folder does not exist', folderPath);
    }

    List<FileSystemEntity> fileList = [];
    try {
      fileList = await folder.list(recursive: false).toList();
    } on FileSystemException catch (e) {
      Logger().w('读取路径出错：$e');
    }
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
    if (path.contains('storage') && !withPermission) {
      // throw FileSystemException('no storage permissions.', path);
    }
    return File(path);
  }

  @override
  List<String> getExternalStoragePath() {
    return externalStoragePath;
  }
}
