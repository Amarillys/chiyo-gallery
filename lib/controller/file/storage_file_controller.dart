import 'dart:io';

import 'package:global_configs/global_configs.dart';

import 'package:chiyo_gallery/controller/file/base.dart';
import 'package:chiyo_gallery/components/file.dart';

class StorageFileController implements FileController {
  bool permissionGranted = false;

  @override
  Future<List<MediaFile>> fetchFile([String params = '']) async {
    String path = params;
    if (!permissionGranted) {
      await FileController.storage.grantPermission();
    }
    permissionGranted = true;
    if (path == '') {
      path = GlobalConfigs().get('initPath');
      if (path == '') {
        path = FileController.storage.initStoragePath;
      }
    }

    final List<FileSystemEntity> fileToShow = await FileController.storage.dirFiles(path);
    return fileToShow.map((f) => MediaFile(f.path)).toList();
  }
}
