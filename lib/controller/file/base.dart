
import 'package:chiyo_gallery/storage/storage.dart';
import 'package:chiyo_gallery/components/file.dart';

abstract class FileController {
  static final storage = Storage.instance;
  Future<List<MediaFile>> fetchFile({String params = '', String sortType = 'normal'});
  bool canAccess(String path);
}