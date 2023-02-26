import 'dart:io';
import 'package:path/path.dart' as path_util;

import '../utils/image_util.dart';

class MediaFile {
  late File file;
  File? thumbnailFile;
  late bool shouldHaveThumbnails;
  String type = '';
  String path = '';
  String icon = '';
  int size = 0;
  late DateTime modified;

  MediaFile(String filePath)  {
    path = filePath;

    file = File(filePath);
    type = path_util.extension(filePath).toLowerCase();
    shouldHaveThumbnails = ImageUtil.shouldHaveThumbnails(type);
    final stat = file.statSync();
    if (stat.type == FileSystemEntityType.file) {
      size = stat.size;
    }
    modified = stat.modified;
  }
}
