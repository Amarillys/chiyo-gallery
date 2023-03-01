import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:global_configs/global_configs.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:logger/logger.dart';
import "package:path/path.dart" as p;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path_util;

import 'package:chiyo_gallery/components/file.dart';

class ImageUtil {
  static final List<String> thumbnailExt = ['.jpg', '.png', '.avif', '.jfif', '.jpeg', '.heic', '.webp'];

  static bool shouldHaveThumbnails(String type) {
    final matchResult = thumbnailExt.firstWhereOrNull((ext) => type == ext);
    if (matchResult != null && matchResult.isNotEmpty) {
      return true;
    }
    return false;
  }

  static Future<File?> generateThumbnail(String filePath) async {
    final int width = int.parse(await GlobalConfigs().get('thumbnail-width'));
    final fileStat = await File(filePath).stat();
    final extension = p.extension(filePath);
    if (extension == '.avif') {
      return DefaultCacheManager().putFile(
          filePath, await ImageUtil.avifFileToJPG(filePath, minSide: width),
          eTag: '${fileStat.size}-${fileStat.modified}');
    } else {
      Uint8List? thumbnailFiles;
      if (Platform.isAndroid || Platform.isIOS) {
        thumbnailFiles = (await FlutterImageCompress.compressWithFile(filePath, minHeight: width, minWidth: width))!;
      } else {
        if (extension == '.heic') {
          final heicImageWidget = Image.file(File(filePath));
          final imageStream = heicImageWidget.image.resolve(const ImageConfiguration());

          Uint8List bytes = Uint8List(0);
          final completer = Completer<List<int>>();
          int decodeWidth = 0, decodeHeight = 0;
          final imageStreamListener = ImageStreamListener((imageInfo, synchronousCall) async {
            final byteData = await imageInfo.image.toByteData(format: ImageByteFormat.rawRgba);
            bytes = byteData!.buffer.asUint8List();
            decodeWidth = imageInfo.image.width;
            decodeHeight = imageInfo.image.height;
            if (!completer.isCompleted) {
              completer.complete(bytes);
            }
          });
          imageStream.addListener(imageStreamListener);

          await completer.future;
          if (bytes.isEmpty) {
            return null;
          }

          thumbnailFiles = encodeImageToJpgBytes(img.Image.fromBytes(
              width: decodeWidth,
              height: decodeHeight,
              bytes: bytes.buffer,
              numChannels: 4), minSide: 300, quality: 75);

          imageStream.removeListener(imageStreamListener);
        } else {
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
            thumbnailImage = await decodeFunction(filePath);
            thumbnailImage ??= await img.decodeImageFile(filePath);
            if (thumbnailImage != null) {
              thumbnailFiles = encodeImageToJpgBytes(thumbnailImage, minSide: width);
            } else {
              return null;
            }
          } on Exception catch (e) {
            Logger().e(e);
            return null;
          }
        }
      }
      return DefaultCacheManager().putFile(
          filePath, thumbnailFiles,
          eTag: '${fileStat.size}-${fileStat.modified}');
    }
    return null;
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

  static Color mapColorFromString(String colorStr) {
    switch (colorStr) {
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.white;
    }
  }

  static Future<Uint8List> avifFileToJPG(String srcPath,
      {width = 0,
        height = 0,
        String dstPath = '',
        int quality = 75,
        int minSide = 0}) async {
    const double hashScale = 1.0;
    final hashCode = Object.hash(srcPath, hashScale);
    final Uint8List bytes = await File(srcPath).readAsBytes();

    final codec = AvifCodec(
        key: hashCode,
        avifBytes: bytes
    );

    await codec.ready();

    final firstFrame = await codec.getNextFrame();
    var originalWidth = firstFrame.image.width;
    var originalHeight = firstFrame.image.height;
    if (width == 0) {
      width = originalWidth;
    }
    if (height == 0) {
      height = originalHeight;
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
        numChannels: 4), quality: quality);
    if (dstPath != '') {
      File(dstPath).writeAsBytes(encodedImg);
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
    final resizedImg =  img.copyResize(image, width: dstWidth == 0 ? image.width : dstWidth, height: dstHeight == 0 ? image.height : dstHeight);
    return img.encodeJpg(resizedImg, quality: quality);
  }
}
