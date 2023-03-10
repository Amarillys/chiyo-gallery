import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:chiyo_gallery/utils/task_queue.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:logger/logger.dart';
import "package:path/path.dart" as p;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path_util;
import 'package:flutter_isolate/flutter_isolate.dart';

import 'package:chiyo_gallery/components/file.dart';
import 'package:chiyo_gallery/utils/config.dart';

class ConvertParams {
  final String srcPath;
  String dstPath;
  final int? minSide;
  int width;
  int height;
  final int quality;

  Map<String, dynamic> toMap() {
    return {
      'srcPath': srcPath,
      'dstPath': dstPath,
      'width': width,
      'height': height,
      'quality': quality,
      'minSide': minSide
    };
  }

  ConvertParams(this.srcPath, {this.dstPath = '', this.minSide, this.width = 0, this.height = 0, this.quality = 75});
}

class ImageUtil {
  static final List<String> thumbnailExt = ['.bmp', '.jpg', '.png', '.avif', '.jfif', '.jpeg', '.heic', '.webp', 'tiff'];

  static bool shouldHaveThumbnails(String type) {
    final matchResult = thumbnailExt.firstWhereOrNull((ext) => type == ext);
    if (matchResult != null && matchResult.isNotEmpty) {
      return true;
    }
    return false;
  }

  static Future<File?> generateThumbnail(String filePath) async {
    final int thumbnailWidth = GlobalConfig.get(ConfigMap.thumbnailWidth).toInt();
    final extension = p.extension(filePath);
    final convertParams = ConvertParams(filePath, minSide: thumbnailWidth);
    final fileStat = await File(filePath).stat();
    Uint8List? thumbnailFiles;

    if (Platform.isAndroid || Platform.isIOS) {
      switch (extension) {
        case '.avif':
          await TaskQueue.addOrWait();
          // flutter_iso use reflection to load plugin(only android and iOS)
          thumbnailFiles = await flutterCompute(convertAvifToJPG, convertParams.toMap());
          TaskQueue.sub();
          break;
        default:
          thumbnailFiles = await convertMobileImageFaster(convertParams.toMap());
          break;
      }
    } else {
      switch (extension) {
        case '.avif':
          // flutter_isolate library do not support desktop, do in root isolate.
          thumbnailFiles = await convertAvifToJPG(convertParams.toMap());
          break;
        case '.heic':
          // use native decoder(dependent on ui library, cannot run in other isolate)
          thumbnailFiles = await convertImageUseNative(convertParams.toMap());
          break;
        default:
          await TaskQueue.addOrWait();
          thumbnailFiles = await compute(convertOtherImage, convertParams.toMap());
          TaskQueue.sub();
          break;
      }
    }

    if (thumbnailFiles != null) {
      return DefaultCacheManager().putFile(
          filePath, thumbnailFiles,
          eTag: '${fileStat.size}-${fileStat.modified}');
    } else {
      return null;
    }
  }

  @pragma('vm:entry-point')
  static Future<Uint8List?> convertAvifToJPG(Map<String, dynamic> params) async {
    return await ImageUtil.avifFileToJPG(params);
  }

  static Future<Uint8List?> convertMobileImageFaster(Map<String, dynamic> params) async {
    return await FlutterImageCompress.compressWithFile(params['srcPath'], minHeight: params['minSide'], minWidth: params['minSide']);
  }

  @pragma('vm:entry-point')
  static Future<Uint8List?> convertOtherImage(Map<String, dynamic> params) async {
    Uint8List? thumbnailFiles;
    final extension = p.extension(params['srcPath']);
    final Map<String, Future<img.Image?> Function(String)> decodeFunctionMap = {
      '.bmp': img.decodeBmpFile,
      '.gif': img.decodeGifFile,
      '.jpeg': img.decodeJpgFile,
      '.jpg': img.decodeJpgFile,
      '.png': img.decodePngFile,
      '.webp': img.decodeWebPFile,
      '.tga': img.decodeTgaFile
    };
    final Function? decodeFunction = decodeFunctionMap[extension];
    if (decodeFunction == null) {
      return null;
    }

    img.Image? thumbnailImage;
    try {
      thumbnailImage = await decodeFunction(params['srcPath']);
      thumbnailImage ??= await img.decodeImageFile(params['srcPath']);
      if (thumbnailImage != null) {
        thumbnailFiles = encodeImageToJpgBytes(thumbnailImage, minSide: params['minSide']!);
      } else {
        return null;
      }
    } on Exception catch (e) {
      Logger().e(e);
      return null;
    }
    return thumbnailFiles;
  }

  static Future<Uint8List?> convertImageUseNative(Map<String, dynamic> params) async {
    WidgetsFlutterBinding.ensureInitialized();
    Uint8List? thumbnailFiles;
    // final heicImageWidget = Image.file(File());
    final imageBytes = await File(params['srcPath']).readAsBytes();
    final codec = await instantiateImageCodec(imageBytes);
    final image = (await codec.getNextFrame()).image;
    final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
    final bytes = byteData!.buffer.asUint8List();
    if (bytes.isEmpty) {
      return null;
    }

    thumbnailFiles = encodeImageToJpgBytes(img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: bytes.buffer,
        numChannels: 4), minSide: 300, quality: 75);

    // imageStream.removeListener(imageStreamListener);
    image.dispose();
    return thumbnailFiles;
  }

  static bool isImageFile(String filePath) {
    final type = path_util.extension(filePath).toLowerCase();
    return ImageUtil.shouldHaveThumbnails(type);
  }

  static Future<File?> getThumbFile(String imagePath) async {
    return (await DefaultCacheManager().getFileFromCache(imagePath))?.file;
  }

  static Future<File?> generateNormalThumbnails(MediaFile image) async {
      File? thumbCache = await ImageUtil.getThumbFile(image.path);
      thumbCache ??= await ImageUtil.generateThumbnail(image.path);
      return thumbCache;
  }

  static Color mapColorFromString(String colorStr, [double overOpacity = 1]) {
    switch (colorStr) {
      case 'blue':
        return Colors.blue.withOpacity(overOpacity);
      case 'pink':
        return Colors.pink.withOpacity(overOpacity);
      default:
        return Color.fromRGBO(int.parse(colorStr.substring(0, 2), radix: 16),
            int.parse(colorStr.substring(2, 4), radix: 16),
            int.parse(colorStr.substring(4, 6), radix: 16),
            int.parse(colorStr.substring(6, 8), radix: 16) / 256.0 * overOpacity);
    }
  }

  static Future<Uint8List> avifFileToJPG(Map<String, dynamic> params) async {
    const double hashScale = 1.0;
    final hashCode = Object.hash(params['srcPath'], hashScale);
    final Uint8List bytes = await File(params['srcPath']).readAsBytes();

    final codec = AvifCodec(
        key: hashCode,
        avifBytes: bytes
    );

    await codec.ready();

    final firstFrame = await codec.getNextFrame();
    var originalWidth = firstFrame.image.width;
    var originalHeight = firstFrame.image.height;
    if (params['width'] == 0) {
      params['width'] = originalWidth;
    }
    if (params['height'] == 0) {
      params['height'] = originalHeight;
    }
    codec.dispose();
    // TO-DO: optimize image size
    final imageBytes =
    (await firstFrame.image.toByteData(format: ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
    firstFrame.image.dispose();
    final encodedImg = encodeImageToJpgBytes(img.Image.fromBytes(
        width: originalWidth,
        height: originalHeight,
        bytes: imageBytes.buffer,
        numChannels: 4), quality: params['quality']);
    if (params['dstPath'] != '') {
      File(params['dstPath']).writeAsBytes(encodedImg);
    }
    return Future.value(encodedImg);
  }

  static Uint8List encodeImageToJpgBytes(img.Image image, { int dstWidth = 0, int dstHeight = 0, int minSide = 0, int quality = 75 }) {
    if (minSide > 0) {
      if (image.width > image.height) {
        dstHeight = minSide;
        dstWidth = (minSide * (image.width / image.height)).toInt();
      } else {
        dstWidth = minSide;
        dstHeight = (minSide * (image.height / image.width)).toInt();
      }
    }
    final resizedImg = img.copyResize(image, width: (minSide == 0 && dstWidth == 0) ? image.width : dstWidth,
        height: (minSide == 0 && dstHeight == 0) ? image.height : dstHeight);
    return img.encodeJpg(resizedImg, quality: quality);
  }
}
