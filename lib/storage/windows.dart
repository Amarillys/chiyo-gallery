import 'dart:io';
import 'dart:core';
import "package:chiyo_gallery/utils/config.dart";
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
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
  
  List<RegExp> filterRules = [];

  WindowsStorage() {
    grantPermission();
    filterRules = [RegExp(r"\.tmp"), RegExp(r"\.sys")];
  }

  @override
  Future<bool> grantPermission() async {
    externalStoragePath = detectAvailablePartition();
    return true;
  }

  @override
  Future<List<FileSystemEntity>> dirFiles(String folderPath, {List<String> extensions = const []}) async {
    Directory folder = Directory(folderPath);
    if (!await folder.exists()) {
      throw FileSystemException ('folder does not exist', folderPath);
    }

    List<FileSystemEntity> fileList = [];
    var stream = folder.list(recursive: false)
      .handleError((err) => Logger().w('cannot access: $err'), test: (e) => e is FileSystemException);
    
    await for (var entity in stream) {
      var allow = true;
      for (var reg in filterRules) {
        if (reg.hasMatch(entity.path)) {
          allow = false;
        }
      }
      if (allow) {
        fileList.add(entity);
      }
    }

    // hide file
    // TO-DO windows: https://pub.dev/documentation/win32/latest/winrt/GetFileAttributes.html
    bool showHidden = GlobalConfig.get(ConfigMap.showHidden);
    if (!showHidden) {
      fileList = fileList.where((element) => !p.basename(element.path).startsWith('.')).toList();
    }
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
    Process.start('cmd', ['/c', 'start', ' ', path]);
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
      try {
        if (partition.existsSync()) {
          partitions.add(partitionPath);
        }
      } catch (e) {
        Logger().e(e);
      }
    }
    return partitions;
  }

  @override
  String dealPrefixPath(String firstPath) {
    final partitionSignalReg = RegExp(r'^\w:\/$');
    if (partitionSignalReg.hasMatch(firstPath)) {
      return firstPath.substring(0, 2).toUpperCase();
    }
    return firstPath;
  }
}
