import 'package:collection/collection.dart';

class ImageUtil {
  static final List<String> thumbnailExt = ['.jpg', '.png', '.avif'];

  static bool shouldHaveThumbnails(String type) {
    final matchResult = thumbnailExt.firstWhereOrNull((ext) => type == ext);
    if (matchResult != null && matchResult.isNotEmpty) {
      return true;
    }
    return false;
  }

  static Future<String> generateThumbnail(String filePath) async {
    return Future.value(filePath);
  }
}