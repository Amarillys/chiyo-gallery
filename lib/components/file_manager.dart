import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import "package:path/path.dart" as p;
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:toast/toast.dart';

import 'package:chiyo_gallery/components/file.dart';
import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/events/events_definition.dart';
import 'package:chiyo_gallery/utils/string_util.dart';
import 'package:chiyo_gallery/controller/file/base.dart';
import 'package:chiyo_gallery/pages/viewer.dart';
import 'package:chiyo_gallery/utils/image_util.dart';
import 'package:chiyo_gallery/components/underline.dart';
import 'package:chiyo_gallery/utils/config.dart';

class FileBrowser extends StatefulWidget {
  final FileController controller;

  const FileBrowser({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => ViewerState();
}

class ViewerState extends State<FileBrowser> {
  static final eventBus = GlobalEventBus.instance;
  double rowWidth = 300;
  double rowHeight = 75;
  List<MediaFile> files = [];
  List<String> histories = [""];
  List<int> selected = [];
  bool historyBacking = false;
  String currentPath = '';
  late TextStyle descStyle;
  bool onExit = false;
  final _scrollController = ScrollController();
  Color _baseColor = Colors.green;
  bool showEmptyFile = false;
  String sortType = 'name-up';
  String layoutType = 'list';

  @override
  void initState() {
    super.initState();

    loadConfig();
    initPath();

    eventBus.on<ChangePathEvent>().listen((event) {
      initPath(event.path);
    });

    eventBus.on<PathBackEvent>().listen((event) {
      if (histories.length == 1) {
        return;
      } else {
        final backPath = histories.removeLast();
        historyBacking = true;
        initPath(backPath);
      }
    });

    eventBus.on<ShowHiddenOptionChangedEvent>().listen((event) {
      GlobalConfig.set(ConfigMap.showHidden, event.showHidden);
      initPath(currentPath);
    });
    
    // layout
    layoutType = GlobalConfig.get(ConfigMap.layoutType);
    final Map<String, double> layoutWidth = {
      'tiling': 180,
      'list': 300,
      'gallery': 140
    };
    rowWidth = layoutWidth[layoutType]!;
    eventBus.on<LayoutChangedEvent>().listen((event) {
      setState(() {
        layoutType = event.layoutType;
        rowWidth = layoutWidth[layoutType]!;
      });
    });

    sortType = GlobalConfig.get(ConfigMap.sortType);
    eventBus.on<SortTypeChangedEvent>().listen((event) {
      setState(() {
        sortType = event.sortType;
        sortFiles(files);
      });
    });
  }

  void loadConfig() {
    descStyle = TextStyle(
        color: Color(int.parse(GlobalConfig.get(ConfigMap.descFontColor), radix: 16)),
        fontSize: 12
    );
    _baseColor = Colors.green;
  }

  void initPath([String params = '']) async {
    var fetchedFiles =
        await widget.controller.fetchFile(params: params);
    if (!showEmptyFile) {
      fetchedFiles = fetchedFiles.where((file) => file.type == 'directory' || file.size > 0).toList();
    }
    if (historyBacking) {
      historyBacking = false;
    } else {
      histories.add(currentPath);
    }
    currentPath = params;
    eventBus.fire(PathChangedEvent(params));
    eventBus.fire(ClearItemChooseEvent());
    selected = [];
    sortFiles(fetchedFiles);
    setupFile();
  }

  sortFiles (List<MediaFile> fetchedFiles) {
    fetchedFiles = widget.controller.sort(fetchedFiles, sortType);
    setState(() {
      files = fetchedFiles;
    });
  }


  setupFile() {
    scrollToTop();
    final waitThumbFiles = files.where((f) => f.shouldHaveThumbnails);
    fetchThumb(waitThumbFiles);

    final directories = files.where((f) => f.type == 'directory');
    getDirectoryDetail(directories);
  }

  void fetchThumb(Iterable<MediaFile> files) async {
    if (files.isEmpty) {
      return;
    }
    for (var i = 0; i < files.length; ++i) {
      ImageUtil.generateNormalThumbnails(files.elementAt(i)).then((newThumbFile) {
        if (newThumbFile != null) {
          setState(() {
            files.elementAt(i).thumbnailFile = newThumbFile;
          });
        }
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
    return WillPopScope(
      onWillPop: () async { return !goToParentDirectory(context); },
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        double parentWidth = constraints.maxWidth;
        int columnCount = parentWidth ~/ rowWidth;
        final int rowCount = (files.length / columnCount).ceil();
        rowHeight = 75;
        double columnGap = 2;
        if (layoutType == 'gallery') {
          rowWidth = parentWidth / columnCount;
          rowHeight = rowWidth;
          if (parentWidth > 320 && parentWidth < 540) {
            rowHeight = rowWidth * 0.8;
          }
        } else if (layoutType == 'tiling') {
          if (parentWidth > 320 && parentWidth < 540) {
            columnCount = 3;
            rowWidth = parentWidth / columnCount;
          } else {
            rowWidth = parentWidth / columnCount;
          }
          rowHeight = rowWidth;
        }
        return SizedBox.expand(
          child: files.isNotEmpty
              ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  child: LayoutGrid(
                      columnGap: columnGap,
                      rowGap: columnGap,
                      columnSizes: List.generate(columnCount, (index) => 1.fr),
                      rowSizes: List.generate(rowCount, (index) => FixedTrackSize(rowHeight)),
                      children: List.generate(files.length, (index) {
                        final currentFile = files[index];
                        return InkWell(
                            onTap: () { onItemTap(currentFile); },
                            onLongPress: () { onItemLongPress(currentFile, index); },
                            child: generateFileLayout(currentFile, index)
                        );
                      })))
              : Center(child: SizedBox(
                  height: 200,
                  child: Column(
                      children: [const Icon(Icons.folder_off, size: 128, color: Colors.pink),
                          Text('noFiles'.tr(),
                              style: const TextStyle(fontSize: 20, color: Colors.black45))])))
      );
    }));
  }

  Widget generateFileLayout(MediaFile currentFile, int index) {
    if (layoutType == 'tiling') {
      return buildTilingLayout(currentFile, index);
    } else if (layoutType == 'gallery') {
      return buildGalleryLayout(currentFile, index);
    } else {
      return buildListLayout(currentFile, index);
    }
  }

  Widget buildListLayout(MediaFile currentFile, int index) {
    bool isSelected = selected.contains(index);
    return Card(
      margin: const EdgeInsets.only(top: 0, bottom: 0),
      color: isSelected ? const Color.fromRGBO(180, 180, 180, 0.4) : const Color.fromRGBO(250, 250, 250, 0.3),
      elevation: 0,
      child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 5, right: 10),
                child: setupThumbNailOrIcons(currentFile, _baseColor)),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: double.infinity, height: 3),
                    Text(p.basename(currentFile.path),
                        maxLines: 2,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                    generateSizeDescription(currentFile, context, descStyle),
                    const CustomUnderline()
                  ]),
            )])
    );
  }

  Widget buildTilingLayout(MediaFile currentFile, int index) {
    return SizedBox(width: rowWidth, height: rowWidth, child: Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        setupThumbNailOrIcons(currentFile, _baseColor, iconSize: rowWidth * 0.6),
        Center(child: Text(p.basename(currentFile.path), textAlign: TextAlign.center, maxLines: 2))
      ],
    ));
  }

  Widget buildGalleryLayout(MediaFile currentFile, int index) {
    if (!currentFile.shouldHaveThumbnails) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          setupThumbNailOrIcons(currentFile, _baseColor, iconSize: rowHeight * 0.66),
          Container(
            width: double.infinity,
            height: 40,
            color: Colors.grey.withOpacity(0.5),
            child: Center(child: Text(p.basename(currentFile.path), maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)))
          )
        ],
      );
    } else {
      return setupThumbNailOrIcons(currentFile, _baseColor, iconSize: rowWidth, circle: false);
    }
  }

  bool goToParentDirectory(BuildContext context) {
    final uriInfo = Uri.parse(currentPath);
    final parentPath = uriInfo.resolve('../').toString();
    if (parentPath == '' || !widget.controller.canAccess(parentPath)) {
      if (onExit) {
        return false;
      }
      onExit = true;
      Toast.show('oneMoreClickToExit'.tr());
      Future.delayed(const Duration(seconds: 1), () {
        onExit = false;
      });
      return true;
    }
    scrollToTop();
    initPath(parentPath);
    return true;
  }

  static setupThumbNailOrIcons(MediaFile file, Color baseColor, { double iconSize = 50, circle = true }) {
    const padding = 4;
    if (file.type == 'directory') {
      return Icon(Icons.folder, size: iconSize + padding, color: baseColor);
    }
    if (file.shouldHaveThumbnails) {
      if (file.thumbnailFile == null) {
        return Icon(Icons.image,
            size: iconSize + padding, color: baseColor);
      } else {
        if (circle) {
          return Container(
            margin: EdgeInsets.only(left: padding.toDouble(), bottom: padding.toDouble(), top: padding.toDouble()),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(iconSize / 2)),
                child: Image.file(file.thumbnailFile!,
                    fit: BoxFit.cover, height: iconSize, width: iconSize)),
          );
        } else {
          return Image.file(file.thumbnailFile!,
              fit: BoxFit.cover, height: iconSize, width: iconSize);
        }
      }
    } else {
      switch (file.type) {
        case '.mp4':
          return Icon(Icons.video_collection_outlined, size: iconSize + padding, color: baseColor);
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
      initPath('${currentFile.path}/');
    }
  }

  onItemLongPress(MediaFile currentFile, int index) {
    if (selected.contains(index)) {
      setState(() {
        selected.remove(index);
      });
    } else {
      setState(() {
        selected.add(index);
      });
    }
    eventBus.fire(ItemChooseEvent(selected, files.map((e) => e.path).toList()));
  }

  static Row generateSizeDescription(MediaFile currentFile, BuildContext ctx, TextStyle textStyle) {
    final size = currentFile.size;
    String description = '';
    if (currentFile.type == 'directory') {
      description = 'empty'.tr();
      if (currentFile.fileCount > 0) {
        description = 'n_files'.tr(namedArgs: { 'count': currentFile.fileCount.toString() });
      }
    } else if (size == 0) {
      description = '0 B';
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
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(microseconds: 1),
        curve: Curves.bounceIn
      );
    }
  }
}
