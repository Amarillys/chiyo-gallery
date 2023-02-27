import 'dart:io';
import 'package:flutter/material.dart';
import 'package:global_configs/global_configs.dart';
import "package:path/path.dart" as p;
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:executor/executor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toast/toast.dart';

import 'package:chiyo_gallery/components/file.dart';
import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/events/events_definition.dart';
import 'package:chiyo_gallery/utils/string_util.dart';
import 'package:chiyo_gallery/controller/file/base.dart';
import 'package:chiyo_gallery/pages/viewer.dart';
import 'package:chiyo_gallery/utils/image_util.dart';
import 'package:chiyo_gallery/components/underline.dart';

class FileBrowser extends StatefulWidget {
  final FileController controller;

  const FileBrowser({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => ViewerState();
}

class ViewerState extends State<FileBrowser> {
  static final eventBus = GlobalEventBus.instance;
  static const int rowWidth = 330;
  List<MediaFile> files = [];
  String currentPath = '';
  String sortType = 'normal';
  late TextStyle descStyle;
  bool onExit = false;
  final _scrollController = ScrollController();
  Color _baseColor = Colors.green;

  @override
  void initState() {
    super.initState();
    loadConfig();
    initPath();

    eventBus.on<SideBarTapEvent>().listen((event) {
      scrollToTop();
      initPath(event.path);
    });
  }

  void loadConfig() {
    descStyle = TextStyle(
        color: Color(int.parse(GlobalConfigs().get('descFontColor'), radix: 16)),
        fontSize: 12
    );
    _baseColor = Colors.green;
  }

  void initPath([String params = '']) async {
    final fetchedFiles =
        await widget.controller.fetchFile(params: params, sortType: sortType);
    setState(() {
      files = fetchedFiles;
    });

    setupFile();
  }

  setupFile() {
    final waitThumbFiles = files.where((f) => f.shouldHaveThumbnails);
    fetchThumb(waitThumbFiles);

    final directories = files.where((f) => f.type == 'directory');
    getDirectoryDetail(directories);
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

  getDirectoryDetail(Iterable<MediaFile> files) {
    for (var i = 0; i < files.length; ++i) {
      files.elementAt(i).getFileCount().then((count) => {
        setState(() {
          files.elementAt(i).fileCount = count;
        })
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
                  controller: _scrollController,
                  child: LayoutGrid(
                    columnGap: 10,
                    rowGap: -12,
                    columnSizes: List.generate(columnCount, (index) => 1.fr),
                    rowSizes: List.generate(rowCount, (index) => const FixedTrackSize(80)),
                    children: List.generate(files.length, (index) {
                      final currentFile = files[index];
                      return GestureDetector(
                          onTap: () {
                            onItemTap(currentFile);
                          },
                          child: Card(
                            color: const Color.fromRGBO(250, 250, 250, 0.3),
                              elevation: 0,
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(left: 5, right: 10),
                                        child: setupThumbNailOrIcons(currentFile, _baseColor)),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                              Text(p.basename(currentFile.path),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis),
                                              generateSizeDescription(currentFile, context, descStyle),
                                              const CustomUnderline()
                                          ]),
                                    )
                                  ])));
                    }),
                  ))
              : Center(child: SizedBox(
                  height: 200,
                  child: Column(
                      children: [const Icon(Icons.folder_off, size: 128, color: Colors.pink),
                          Text(AppLocalizations.of(context)!.noFiles,
                              style: const TextStyle(fontSize: 20, color: Colors.black45))])))
      );
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
        scrollToTop();
        files = fetchFiles;
        currentPath = parentPath;
        setupFile();
      });
    });
    return true;
  }

  static setupThumbNailOrIcons(MediaFile file, Color baseColor) {
    const double iconSize = 50;
    const padding = 4;
    if (file.type == 'directory') {
      return Icon(Icons.folder, size: iconSize + padding, color: baseColor);
    }
    if (file.shouldHaveThumbnails) {
      if (file.thumbnailFile == null) {
        return Icon(Icons.insert_drive_file,
            size: 50, color: baseColor);
      } else {
        return Container(
          margin: EdgeInsets.only(left: padding.toDouble()),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(iconSize / 2)),
            child: Image.file(file.thumbnailFile!,
              fit: BoxFit.cover, height: iconSize - padding, width: iconSize - padding)),
        );
      }
    } else {
      switch (file.type) {
        case '.mp4':
          return Icon(Icons.video_collection_outlined, size: iconSize, color: baseColor);
      }
      return Icon(Icons.insert_drive_file, size: iconSize + padding, color: baseColor);
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

  static Row generateSizeDescription(MediaFile currentFile, BuildContext ctx, TextStyle textStyle) {
    final size = currentFile.size;
    String description = '';
    if (currentFile.type == 'directory') {
      description = AppLocalizations.of(ctx)!.empty;
      if (currentFile.fileCount > 0) {
        description = AppLocalizations.of(ctx)!.n_files(currentFile.fileCount);
      }
    } else if (size > 0 && size < 1024) {
      description = '$size Bytes';
    } else if (size > 1024 && size < 1048576) {
      description = '${(size / 1024).toStringAsFixed(2)} KB';
    } else if (size > 1048576 && size <  1024*1024*1024) {
      description = '${(size / 1048576).toStringAsFixed(2)} MB';
    } else {
      description = '${(size / 1073741824).toStringAsFixed(2)} GB';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(description, style: textStyle),
        Expanded(
            child: Align(
                alignment: Alignment.centerRight,
                child: Text(StringUtil.formatDate(currentFile.modified),
                    style: textStyle))
        )],
    );
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(microseconds: 1),
      curve: Curves.bounceIn
    );
  }
}
