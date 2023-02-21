import 'dart:io';
import 'package:chiyo_gallery/components/file.dart';
import 'package:flutter/material.dart';
import "package:path/path.dart" as p;

import 'package:chiyo_gallery/storage/storage.dart';
import 'package:global_configs/global_configs.dart';

import '../utils/image_util.dart';
import '../pages/viewer.dart';

class FileBrowser extends StatefulWidget {
  const FileBrowser({super.key});

  @override
  State<StatefulWidget> createState() => ViewerState();
}

class ViewerState extends State<FileBrowser> {
  static final storage = Storage.instance;
  String currentPath = '';
  List<MediaFile> files = [];
  bool permissionGranted = false;

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
          itemBuilder: (itemContext, index) {
            return Card(
              child: ListTile(
                leading: setupThumbNailOrIcons(files[index]),
                title: Text(p.basename(files[index].path)),
                onTap: () {
                  final filePath = files[index].path;
                  final pathStat = File(filePath).statSync();
                  if (pathStat.type == FileSystemEntityType.file && ImageUtil.isImageFile(filePath)) {
                    final imagePaths = files.where((f) => f.shouldHaveThumbnails).map((f) => f.path).toList();
                    final imageIndex = imagePaths.indexOf(filePath);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            ViewerPage(imagePaths: imagePaths, imageIndex:imageIndex)));
                    return;
                  }
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
    if (!permissionGranted) {
      await storage.grantPermission();
    }
    permissionGranted = true;
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
    final fileList = fileToShow.map((f) => MediaFile(f.path));
    setState(() {
      files = fileList.toList();
    });

    generateNormalThumbnails();
    final avifFiles = files.where((f) => f.shouldHaveThumbnails && f.path.contains('.avif')).toList();
    for (var i = 0; i < avifFiles.length; ++i) {
      if (avifFiles[i].thumbnailFile == null) {
        final thumbnail = await ImageUtil.generateThumbnail(avifFiles[i].path);
        setState(() {
          avifFiles[i].thumbnailFile = thumbnail;
        });
      }
    }
  }

  void generateNormalThumbnails() async {
    final normalFiles = files.where((f) => f.shouldHaveThumbnails && !f.path.contains('.avif')).toList();
    for (var i = 0; i < normalFiles.length; ++i) {
      if (normalFiles[i].thumbnailFile == null) {
        final thumbnail = await ImageUtil.generateThumbnail(normalFiles[i].path);
        setState(() {
          normalFiles[i].thumbnailFile = thumbnail;
        });
      }
    }
  }

  bool goToParentDirectory() {
    final uriInfo = Uri.parse(currentPath);
    final parentPath = uriInfo.resolve('./').toString();
    if (parentPath == '/') {
      return false;
    }
    loadPath(parentPath);
    return true;
  }

  static setupThumbNailOrIcons(MediaFile file) {
    if (file.type == '') {
      return const Icon(Icons.folder);
    }
    if (file.shouldHaveThumbnails) {
      if (file.thumbnailFile == null) {
        return const Icon(Icons.insert_drive_file);
      } else {
        return Image.file(file.thumbnailFile!, fit: BoxFit.fill);
      }
    } else {
      return const Icon(Icons.insert_drive_file);
    }
  }
}
