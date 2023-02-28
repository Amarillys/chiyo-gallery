import 'dart:io';
import 'package:path/path.dart' as path_util;
import 'package:logger/logger.dart';

import 'package:chiyo_gallery/utils/image_util.dart';

class MediaFile {
  late File file;
  File? thumbnailFile;
  late bool shouldHaveThumbnails;
  String type = '';
  String path = '';
  String icon = '';
  int size = 0;
  int fileCount = 0;
  late DateTime modified;

  MediaFile(String filePath)  {
    path = filePath;

    file = File(filePath);
    type = path_util.extension(filePath).toLowerCase();
    shouldHaveThumbnails = ImageUtil.shouldHaveThumbnails(type);
    final stat = file.statSync();
    if (stat.type == FileSystemEntityType.file) {
      size = stat.size;
    } else if (stat.type == FileSystemEntityType.directory) {
      type = 'directory';
    }
    modified = stat.modified;
  }

  Future<int> getFileCount() async {
    if (type == 'directory') {
      var stream =  Directory(path).list().handleError((err) => Logger().w('cannot access: $err'),
         test: (e) => e is FileSystemException);
      await for (var entity in stream) {
        fileCount++;
      }
      return fileCount;
    }
    return 0;
  }

}
