import 'dart:io';
import 'package:chiyo_gallery/components/file.dart';
import 'package:flutter/material.dart';
import "package:path/path.dart" as p;
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

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

  @override
  void initState() {
    super.initState();
    initPath();
  }

  void initPath([String params = '']) async {
    final fetchedFiles = await widget.controller.fetchFile(params);
    setState(() {
      files = fetchedFiles;
    });

    final waitThumbFiles = files.where((f) => f.shouldHaveThumbnails);

    fetchThumb(waitThumbFiles);
  }

  fetchThumb(Iterable<MediaFile> files) async {
    for (var i = 0; i < files.length; ++i) {
      final newThumbFile = await ImageUtil.generateNormalThumbnails(files.elementAt(i));
      setState(() {
        files.elementAt(i).thumbnailFile = newThumbFile;
      });
    }
    /* TO-DO
    final taskStream = Stream<Future<File>>.fromIterable(
        files.map((file) => ImageUtil.generateNormalThumbnails(file))).toList();
    const concurrency = 3;

    await for (final taskBatch in taskStream.batch(concurrency)) {}*/
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      if (!goToParentDirectory()) {
        return true;
      } else {
        return false;
      }
    }, child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double parentWidth = constraints.maxWidth;
      final int columnCount = parentWidth ~/ rowWidth;
      final int rowCount = (files.length / columnCount).ceil();
      return SizedBox.expand(
          child: files.isNotEmpty
              ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: LayoutGrid(
                    columnGap: 10,
                    rowGap: -12,
                    columnSizes: List.generate(columnCount, (index) => 1.fr),
                    rowSizes: List.generate(
                        rowCount, (index) => const FixedTrackSize(80)),
                    children: List.generate(files.length, (index) {
                      final currentFile = files[index];
                      return Card(
                        color: const Color.fromRGBO(255, 255, 255, 1.0),
                        child: ListTile(
                          leading: setupThumbNailOrIcons(currentFile),
                          title: Text(p.basename(currentFile.path),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () {
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
                                            imagePaths: imagePaths,
                                            imageIndex: imageIndex)));
                                return;
                              } else {
                                FileController.storage
                                    .openFile(currentFile.path);
                              }
                            } else {
                              currentPath = '${currentFile.path}/';
                              initPath(currentPath);
                            }
                          },
                        ),
                      );
                    }),
                  ))
              : const Text('No files'));
    }));
  }

  bool goToParentDirectory() {
    final uriInfo = Uri.parse(currentPath);
    final parentPath = uriInfo.resolve('../').toString();
    if (parentPath == '/') {
      return false;
    }
    widget.controller.fetchFile(parentPath).then((fetchFiles) {
      setState(() {
        files = fetchFiles;
      });
    });
    return true;
  }

  static setupThumbNailOrIcons(MediaFile file) {
    if (file.type == '') {
      return const Icon(Icons.folder, size: 50, color: Colors.green);
    }
    if (file.shouldHaveThumbnails) {
      if (file.thumbnailFile == null) {
        return const Icon(Icons.insert_drive_file);
      } else {
        return Image.file(file.thumbnailFile!, fit: BoxFit.fill);
      }
    } else {
      switch (file.type) {
        case '.mp4':
          return const Icon(Icons.video_collection_outlined, size: 50);
      }
      return const Icon(Icons.insert_drive_file, size: 50);
    }
  }
}
