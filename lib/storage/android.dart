import "dart:io";
import "package:path/path.dart" as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:logger/logger.dart';
import 'package:toast/toast.dart';
import 'package:open_file/open_file.dart';

import "base.dart";
import 'package:chiyo_gallery/utils/config.dart';

class AndroidStorage implements BaseStorage {
  bool withPermission = false;
  @override
  List<String> externalStoragePath = [];
  @override
  String initStoragePath = '/storage';
  @override
  List<String> cannotAccessPath = [];

  bool getRooted = false;

  AndroidStorage() {
    grantPermission();
    // TO-DO: check or grant root
    if (!getRooted) {
      cannotAccessPath = ['/', '../', '/storage/emulated'];
    }
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
    } else {
      Toast.show('获取不到权限');
    }
    return withPermission;
  }

  @override
  Future<List<FileSystemEntity>> dirFiles(String folderPath, {List<String> extensions = const []}) async {
    if (folderPath == '/storage' || folderPath == '/storage/') {
      return Future.value(externalStoragePath
          .map((storagePath) => Directory(storagePath))
          .toList());
    }
    Directory folder = Directory(folderPath);
    if (!await folder.exists()) {
      throw FileSystemException('folder does not exist', folderPath);
    }

    List<FileSystemEntity> fileList = [];
    try {
      fileList = await folder.list(recursive: false).toList();
    } on FileSystemException catch (e) {
      Logger().w('读取路径出错：$e');
    }

    bool showHidden = GlobalConfig.get(ConfigMap.showHidden);
    if (!showHidden) {
      fileList = fileList.where((element) => !p.basename(element.path).startsWith('.')).toList();
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

  @override
  Future<ResultType> openFile(String path) async {
    return (await OpenFile.open(path)).type;
  }

  @override
  String convertStoragePathForDisplay(String path) {
    if (path == '/storage/emulated/0') {
      return 'internalStorage';
    } else {
      return 'externalStorage';
    }
  }

  @override
  String dealPrefixPath(String firstPath) {
    return firstPath;
  }
}
