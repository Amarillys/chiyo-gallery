import "dart:io";
import "package:chiyo_gallery/storage/base.dart";
import "package:path/path.dart" as p;
import 'package:permission_handler/permission_handler.dart';

class WindowsStorage implements BaseStorage {
  bool withPermission = false;
  @override
  String externalStoragePath = 'D:/';

  WindowsStorage() {
    grantPermission();
  }

  @override
  Future<bool> grantPermission() async {
    return true;
  }

  @override
  Future<List<FileSystemEntity>> dirFiles(String folderPath, [List<String> extensions = const []]) async {
    Directory folder = Directory(folderPath);
    if (!await folder.exists()) {
      throw FileSystemException ('folder does not exist', folderPath);
    }

    List<FileSystemEntity> fileList = await folder.list(recursive: true).toList();
    if (extensions.isEmpty) return fileList;

    return fileList.where((file) {
      if (file is File) {
        String extension = p.extension(file.path).toLowerCase();
        return extensions.contains(extension);
      }
      return false;
    }).toList();
  }

  @override
  File readFileSync(String path) {
    return File(path);
  }

  @override
  String getExternalStoragePath() {
    return 'D:/';
  }
}
