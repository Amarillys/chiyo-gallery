import 'dart:io';
import 'package:chiyo_gallery/components/file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import "package:path/path.dart" as p;

import 'package:chiyo_gallery/storage/storage.dart';
import 'package:global_configs/global_configs.dart';

import '../utils/image_util.dart';

class FileBrowser extends StatefulWidget {
  const FileBrowser({super.key});

  @override
  State<StatefulWidget> createState() => ViewerState();
}

class ViewerState extends State<FileBrowser> {
  static final storage = Storage.instance;
  String currentPath = '';
  List<ExtendedFile> files = [];

  @override
  void initState() {
    super.initState();
    loadPath();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!goToParentDirectory()) {
          return true;
        } else {
          return false;
        }
      },
      child: SizedBox(
        height: 500,
        child: ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: setupThumbNailOrIcons(files[index]),
                title: Text(p.basename(files[index].path)),
                onTap: () {
                  loadPath(files[index].path);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  loadPath([String path = '']) async {
    await storage.grantPermission();
    if (path == '') {
      currentPath = GlobalConfigs().get('initPath');
      if (currentPath == '') {
        currentPath = storage.initStoragePath;
      }
    } else {
      currentPath = path;
    }

    final List<FileSystemEntity> fileToShow =
        await storage.dirFiles(currentPath);
    final fileList = fileToShow.map((f) => ExtendedFile(f.path));
    setState(() {
      files = fileList.toList();
    });

    files.where((f) => f.shouldHaveThumbnails).forEach((f) {
      ImageUtil.generateThumbnail(f.path).then((thumbPath) => setState(() {
            f.thumbnailPath = thumbPath;
          }));
    });
  }

  bool goToParentDirectory() {
    final parentPath = Uri.parse(currentPath).resolve('./').toString();
    if (parentPath == '/') {
      return false;
    }
    loadPath(parentPath);
    return true;
  }

  static setupThumbNailOrIcons(ExtendedFile file) {
    if (file.type == '') {
      return const Icon(Icons.folder);
    }
    if (file.shouldHaveThumbnails) {
      if (file.thumbnailPath == '') {
        return const Icon(Icons.insert_drive_file);
      }
      return file.thumbnailPath.contains('avif') ? AvifImage.file(File(file.thumbnailPath)) : Image.file(File(file.thumbnailPath));
    } else {
      return const Icon(Icons.insert_drive_file);
    }
  }
}
