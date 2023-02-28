import "dart:io";
import 'package:open_file/open_file.dart';
import "package:path/path.dart" as p;
import 'package:logger/logger.dart';

import "base.dart";

class WindowsStorage implements BaseStorage {
  bool withPermission = false;
  @override
  List<String> externalStoragePath = [];
  @override
  String initStoragePath = 'c:/';
  @override
  List<String> cannotAccessPath = [];

  WindowsStorage() {
    grantPermission();
  }

  @override
  Future<bool> grantPermission() async {
    externalStoragePath = detectAvailablePartition();
    return true;
  }

  @override
  Future<List<FileSystemEntity>> dirFiles(String folderPath, {List<String> extensions = const [], String sortType = 'normal'}) async {
    Directory folder = Directory(folderPath);
    if (!await folder.exists()) {
      throw FileSystemException ('folder does not exist', folderPath);
    }

    List<FileSystemEntity> fileList = [];
    var stream = folder.list(recursive: false)
      .handleError((err) => Logger().w('cannot access: $err'), test: (e) => e is FileSystemException);
    
    await for (var entity in stream) {
      fileList.add(entity);
    }
    fileList.sort((a, b) {
      if (a is Directory && b is File) {
        return -1;
      } else if (a is File && b is Directory) {
        return 1;
      }
      return a.path.toUpperCase().compareTo(b.path.toUpperCase());
    });
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
  List<String> getExternalStoragePath() {
    return externalStoragePath;
  }


  @override
  Future<ResultType> openFile(String path) {
    return Future.value(ResultType.done);
  }

  @override
  String convertStoragePathForDisplay(String path) {
    return path.toUpperCase();
  }

  List<String> detectAvailablePartition() {
    final List<String> partitions = [];
    final List<String> diskSignal = List.generate(26, (index) => String.fromCharCode('a'.codeUnitAt(0) + index));
    for (var i = 0; i < diskSignal.length; ++i) {
      final partitionPath = '${diskSignal[i]}:/';
      final partition = Directory(partitionPath);
      if (partition.existsSync()) {
        partitions.add(partitionPath);
      }
    }
    return partitions;
  }
}
