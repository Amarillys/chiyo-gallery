import 'package:chiyo_gallery/storage/storage.dart';
import 'package:chiyo_gallery/components/file.dart';
import 'package:chiyo_gallery/utils/string_util.dart';

abstract class FileController {
  static final storage = Storage.instance;
  Future<List<MediaFile>> fetchFile({String params = '', String sortType = 'normal'});
  bool canAccess(String path);

  List<MediaFile> sort (List<MediaFile> files, String sortType);

  static int Function(MediaFile, MediaFile)? generateSortFunction(String sortType) {
    switch (sortType) {
      case 'type-up':
        return (MediaFile a, MediaFile b) {
          return b.type.compareTo(a.type);
        };
      case 'type-down':
        return (MediaFile a, MediaFile b) {
          return a.type.compareTo(b.type);
        };
      case 'size-up':
        return (MediaFile a, MediaFile b) {
          if (a.type == ConstStr.directory && b.type == ConstStr.directory) {
            return -a.fileCount.compareTo(b.fileCount);
          }
          return b.size.compareTo(a.size);
        };
      case 'size-down':
        return (MediaFile a, MediaFile b) {
          if (a.type == ConstStr.directory && b.type == ConstStr.directory) {
            return a.fileCount.compareTo(b.fileCount);
          }
          return a.size.compareTo(b.size);
        };
      case 'date-down':
        return (MediaFile a, MediaFile b) {
          return 0 - a.modified.compareTo(b.modified);
        };
      case 'date-up':
        return (MediaFile a, MediaFile b) {
          return a.modified.compareTo(b.modified);
        };
      case 'name-down':
        return (MediaFile a, MediaFile b) {
          if (a.type == 'directory' && b.type != 'directory') {
            return -1;
          } else if (a.type != 'directory' && b.type == 'directory') {
            return 1;
          }
          return -a.path.toUpperCase().compareTo(b.path.toUpperCase());
        };
      case 'name-up':
      default:
        return (MediaFile a, MediaFile b) {
          if (a.type == 'directory' && b.type != 'directory') {
            return -1;
          } else if (a.type != 'directory' && b.type == 'directory') {
            return 1;
          }
          return a.path.toUpperCase().compareTo(b.path.toUpperCase());
        };
    }
  }
}