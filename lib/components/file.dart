import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_util;

import '../utils/image_util.dart';

class ExtendedFile {
  late File file;
  String thumbnailPath = '';
  late bool shouldHaveThumbnails;
  String type = '';
  String path = '';
  String icon = '';

  ExtendedFile(String filePath)  {
    path = filePath;
    file = File(filePath);
    type = path_util.extension(filePath).toLowerCase();
    shouldHaveThumbnails = ImageUtil.shouldHaveThumbnails(type);
  }

  Future<String> generateThumbnail() async {
    return Future.value(path);
  }
}
