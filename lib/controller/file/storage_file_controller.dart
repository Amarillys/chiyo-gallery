import 'dart:io';

import 'package:chiyo_gallery/utils/config.dart';
import 'package:chiyo_gallery/controller/file/base.dart';
import 'package:chiyo_gallery/components/file.dart';

class StorageFileController implements FileController {
  bool permissionGranted = false;

  @override
  Future<List<MediaFile>> fetchFile(
      {String params = '', String sortType = 'alpha-up'}) async {
    String path = params;
    if (!permissionGranted) {
      await FileController.storage.grantPermission();
    }
    permissionGranted = true;
    if (path == '') {
      path = GlobalConfig.get(ConfigMap.initPath) as String;
      if (path == '') {
        path = FileController.storage.initStoragePath;
      }
    }

    final List<FileSystemEntity> fileToShow =
        await FileController.storage.dirFiles(path);

    return fileToShow.map((f) => MediaFile(f.path)).toList();
  }

  @override
  List<MediaFile> sort(List<MediaFile> files, String sortType) {
    files.sort(FileController.generateSortFunction(sortType));
    return files;
  }

  @override
  bool canAccess(String path) {
    return !FileController.storage.cannotAccessPath.contains(path);
  }
}
