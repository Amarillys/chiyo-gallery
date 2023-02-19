import "dart:io";
import "package:chiyo_gallery/storage/base.dart";
import "package:path/path.dart" as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:chiyo_gallery/utils/config.dart';

class AndroidStorage implements BaseStorage {
  static final _config = Config();
  bool withPermission = false;
  @override
  String externalStoragePath = '/storage';

  AndroidStorage() {
    grantPermission();
  }

  @override
  Future<bool> grantPermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        withPermission = true;
      }
    } else {
      withPermission = true;
    }
    if (withPermission) {
      var externalStorages = await ExternalPath.getExternalStorageDirectories();
      if (externalStorages.length > 1) {
        externalStoragePath = '${externalStorages[1]}/sekai/image/doll/raifufu6129';
      } else {
        externalStoragePath = externalStorages[0];
      }
    }
    _config.setInitPath(externalStoragePath);
    return withPermission;
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
    if (path.contains('storage') && !withPermission) {
      // throw FileSystemException('no storage permissions.', path);
    }
    return File(path);
  }

  @override
  String getExternalStoragePath() {
    return externalStoragePath;
  }
}
