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
                  if (pathStat.type == FileSystemEntityType.file) {
                    if (ImageUtil.isImageFile(filePath)) {
                      final imagePaths = files.where((f) => f.shouldHaveThumbnails).map((f) => f.path).toList();
                      final imageIndex = imagePaths.indexOf(filePath);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              ViewerPage(imagePaths: imagePaths, imageIndex:imageIndex)));
                      return;
                    }
                  } else {
                    loadPath('${files[index].path}/');
                  }
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

    final avifFiles = files.where((f) => f.shouldHaveThumbnails && f.path.contains('.avif')).toList();
    final normalImageFiles = files.where((f) => f.shouldHaveThumbnails && !f.path.contains('.avif')).toList();
    generateNormalThumbnails(avifFiles);
    generateNormalThumbnails(normalImageFiles);
  }

  void generateNormalThumbnails(images) async {
    for (var i = 0; i < images.length; ++i) {
      final MediaFile image = images[i];
      final File? thumbCache = await ImageUtil.getThumbFile(image.path);
      if (thumbCache != null) {
        setState(() {
          image.thumbnailFile = thumbCache;
        });
      } else {
        final thumbnail = await ImageUtil.generateThumbnail(image.path);
        setState(() {
          image.thumbnailFile = thumbnail;
        });
      }
    }
  }

  bool goToParentDirectory() {
    final uriInfo = Uri.parse(currentPath);
    final parentPath = uriInfo.resolve('../').toString();
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
