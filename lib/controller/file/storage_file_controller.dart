import 'dart:io';

import 'package:chiyo_gallery/utils/config.dart';
import 'package:chiyo_gallery/controller/file/base.dart';
import 'package:chiyo_gallery/components/file.dart';

class StorageFileController implements FileController {
  bool permissionGranted = false;

  @override
  Future<List<MediaFile>> fetchFile(
      {String params = '', String sortType = 'normal'}) async {
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

    final files = fileToShow.map((f) => MediaFile(f.path));
    if (sortType == 'date-down') {
      files.toList().sort((a, b) {
        return 0 - a.modified.compareTo(b.modified);
      });
    } else if (sortType == 'date-up') {
      files.toList().sort((a, b) {
        return a.modified.compareTo(b.modified);
      });
    }
    return files.toList();
  }

  @override
  bool canAccess(String path) {
    return !FileController.storage.cannotAccessPath.contains(path);
  }
}
