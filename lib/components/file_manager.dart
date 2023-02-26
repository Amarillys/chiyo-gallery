import 'dart:io';
import 'package:chiyo_gallery/components/file.dart';
import 'package:flutter/material.dart';
import "package:path/path.dart" as p;
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:executor/executor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toast/toast.dart';

import 'package:chiyo_gallery/controller/file/base.dart';
import 'package:chiyo_gallery/pages/viewer.dart';
import 'package:chiyo_gallery/utils/image_util.dart';

class FileBrowser extends StatefulWidget {
  final FileController controller;

  const FileBrowser({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => ViewerState();
}

class ViewerState extends State<FileBrowser> {
  static const int rowWidth = 330;
  List<MediaFile> files = [];
  String currentPath = '';
  String sortType = 'normal';
  bool onExit = false;

  @override
  void initState() {
    super.initState();
    initPath();
  }

  void initPath([String params = '']) async {
    final fetchedFiles =
        await widget.controller.fetchFile(params: params, sortType: sortType);
    setState(() {
      files = fetchedFiles;
    });

    final waitThumbFiles = files.where((f) => f.shouldHaveThumbnails);
    fetchThumb(waitThumbFiles);
  }

  fetchThumb(Iterable<MediaFile> files) async {
    final executor = Executor(concurrency: 3);
    for (var i = 0; i < files.length; ++i) {
      executor.scheduleTask(() async {
        final newThumbFile =
            await ImageUtil.generateNormalThumbnails(files.elementAt(i));
        setState(() {
          files.elementAt(i).thumbnailFile = newThumbFile;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      return Future.value(!goToParentDirectory(context));
    }, child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double parentWidth = constraints.maxWidth;
      final int columnCount = parentWidth ~/ rowWidth;
      final int rowCount = (files.length / columnCount).ceil();
      return SizedBox.expand(
          child: files.isNotEmpty
              ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                      color: Colors.white,
                      child: LayoutGrid(
                        columnGap: 10,
                        rowGap: -12,
                        columnSizes:
                            List.generate(columnCount, (index) => 1.fr),
                        rowSizes: List.generate(
                            rowCount, (index) => const FixedTrackSize(80)),
                        children: List.generate(files.length, (index) {
                          final currentFile = files[index];
                          return GestureDetector(
                              onTap: () {
                                onItemTap(currentFile);
                              },
                              child: Card(
                                  elevation: 0,
                                  // color: const Color.fromRGBO(255, 255, 255, 1.0),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, right: 10),
                                            child: setupThumbNailOrIcons(
                                                currentFile)),
                                        Expanded(
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                            Text(p.basename(currentFile.path),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            Text(generateSizeDescription(currentFile.size),
                                              style: const TextStyle(
                                                color: Color.fromRGBO(33, 33, 33, 0.5),
                                                fontSize: 13.0
                                              )
                                            )
                                          ]),
                                        )
                                      ])));
                        }),
                      )))
              : const Text('No files'));
    }));
  }

  bool goToParentDirectory(BuildContext context) {
    final uriInfo = Uri.parse(currentPath);
    final parentPath = uriInfo.resolve('../').toString();
    if (parentPath == '' || !widget.controller.canAccess(parentPath)) {
      if (onExit) {
        return false;
      }
      onExit = true;
      Toast.show(AppLocalizations.of(context)!.oneMoreClickToExit);
      Future.delayed(const Duration(seconds: 1), () {
        onExit = false;
      });
      return true;
    }
    widget.controller.fetchFile(params: parentPath).then((fetchFiles) {
      setState(() {
        files = fetchFiles;
      });
    });
    return true;
  }

  static setupThumbNailOrIcons(MediaFile file) {
    const double iconSize = 50;
    if (file.type == '') {
      return const Icon(Icons.folder, size: iconSize + 4, color: Colors.green);
    }
    if (file.shouldHaveThumbnails) {
      if (file.thumbnailFile == null) {
        return const Icon(Icons.insert_drive_file,
            size: 50, color: Colors.green);
      } else {
        return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(iconSize / 2)),
          child: Image.file(file.thumbnailFile!,
              fit: BoxFit.cover, height: iconSize, width: iconSize),
        );
      }
    } else {
      switch (file.type) {
        case '.mp4':
          return const Icon(Icons.video_collection_outlined, size: iconSize);
      }
      return const Icon(Icons.insert_drive_file, size: iconSize + 4);
    }
  }

  onItemTap(MediaFile currentFile) {
    final filePath = currentFile.path;
    final pathStat = File(filePath).statSync();
    if (pathStat.type == FileSystemEntityType.file) {
      if (ImageUtil.isImageFile(filePath)) {
        final imagePaths = files
            .where((f) => f.shouldHaveThumbnails)
            .map((f) => f.path)
            .toList();
        final imageIndex = imagePaths.indexOf(filePath);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewerPage(
                    imagePaths: imagePaths, imageIndex: imageIndex)));
        return;
      } else {
        FileController.storage.openFile(currentFile.path);
      }
    } else {
      currentPath = '${currentFile.path}/';
      initPath(currentPath);
    }
  }

  static String generateSizeDescription(int size) {
    if (size == 0) {
      return 'Directory';
    }
    if (size > 0 && size < 1024) {
      return '$size Bytes';
    } else if (size > 1024 && size < 1048576) {
      return '${size / 1024} KB';
    } else if (size > 1048576 && size <  1024*1024*1024) {
      return '${size / 1048576} MB';
    } else {
      return '${size / 1073741824} GB';
    }
  }
}
