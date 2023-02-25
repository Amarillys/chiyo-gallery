import 'dart:io';

import 'package:collection/collection.dart';
import 'package:global_configs/global_configs.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path_util;


import 'package:chiyo_gallery/components/file.dart';
import 'package:chiyo_gallery/utils/avif_convert.dart';

class ImageUtil {
  static final List<String> thumbnailExt = ['.jpg', '.png', '.avif', '.jfif', '.jpeg', '.heic', '.webp'];

  static bool shouldHaveThumbnails(String type) {
    final matchResult = thumbnailExt.firstWhereOrNull((ext) => type == ext);
    if (matchResult != null && matchResult.isNotEmpty) {
      return true;
    }
    return false;
  }

  static Future<File> generateThumbnail(String filePath) async {
    final width = int.parse(await GlobalConfigs().get('thumbnail-width'));
    final fileStat = await File(filePath).stat();
    if (filePath.contains('.avif')) {
      return DefaultCacheManager().putFile(
          filePath, await AvifConvertor.toJPG(filePath, minSide: width),
          eTag: '${fileStat.size}-${fileStat.modified}');
    } else {
      final thumbnailFiles = (await FlutterImageCompress.compressWithFile(filePath, minHeight: width, minWidth: width))!;
      return DefaultCacheManager().putFile(
          filePath, thumbnailFiles,
          eTag: '${fileStat.size}-${fileStat.modified}');
    }
  }

  static bool isImageFile(String filePath) {
    final type = path_util.extension(filePath).toLowerCase();
    return ImageUtil.shouldHaveThumbnails(type);
  }

  static Future<File?> getThumbFile(String imagePath) async {
    return (await DefaultCacheManager().getFileFromCache(imagePath))?.file;
  }


  static Future<File> generateNormalThumbnails(MediaFile image) async {
      File? thumbCache = await ImageUtil.getThumbFile(image.path);
      thumbCache ??= await ImageUtil.generateThumbnail(image.path);
      return Future.value(thumbCache);
  }
}
