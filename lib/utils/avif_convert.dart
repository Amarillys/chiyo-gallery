import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:image/image.dart' as img;

class AvifConvertor {
  static Future<Uint8List> toJPG(String srcPath,
      {width = 0,
      height = 0,
      String dstPath = '',
      int quality = 80,
      int minSide = 0}) async {
    const int overrideDurationMs = -1;
    const double hashScale = 1.0;
    final hashCode = Object.hash(srcPath, hashScale);
    final Uint8List bytes = await File(srcPath).readAsBytes();

    final codec = AvifCodec(
      key: hashCode,
      avifBytes: bytes,
      overrideDurationMs: overrideDurationMs,
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
    if (minSide > 0) {
      if (width > height) {
        height = minSide;
        width = (minSide * (originalWidth / originalHeight)).toInt();
      } else {
        width = minSide;
        height = (minSide * (originalHeight / originalWidth)).toInt();
      }
    }
    final resizedImg = img.copyResize(
        img.Image.fromBytes(
            width: originalWidth,
            height: originalHeight,
            bytes: imageBytes.buffer,
            numChannels: 4)!,
        width: width,
        height: height);
    final encodedImg = img.encodeJpg(resizedImg, quality: quality);
    if (dstPath != '') {
      File(dstPath).writeAsBytes(encodedImg);
    }
    return Future.value(encodedImg);
  }

/*
  static toPNG(String srcPath, int width, int height, double quality, [String dstPath = '']) async {
    const int overrideDurationMs = -1;
    const double hashScale = 1.0;
    final hashCode = Object.hash(srcPath, hashScale);
    final Uint8List bytes = await File(srcPath).readAsBytes();

    final codec = AvifCodec(
      key: hashCode,
      avifBytes: bytes,
      overrideDurationMs: overrideDurationMs,
    );

    await codec.ready();

    final firstFrame = await codec.getNextFrame();
    final imageByte = await firstFrame.image.toByteData(format: ImageByteFormat.);
    if (dstPath != '') {
      // return img.encodeJpgFile(dstPath, firstFrame.image);
    }
    return firstFrame.image.toByteData(format: ImageByteFormat.png);
  }-*/
}
