import 'dart:io';
import 'package:flutter/material.dart';
import "package:path/path.dart" as p;

import 'package:chiyo_gallery/storage/storage.dart';
import 'package:chiyo_gallery/utils/config.dart';

class FileBrowser extends StatefulWidget {

  const FileBrowser({super.key});

  @override
  State<StatefulWidget> createState() => ViewerState();
}

class ViewerState extends State<FileBrowser> {
  static final storage = Storage.instance;
  static final config = Config();
  List<FileSystemEntity> files = [];

  @override
  Widget build(BuildContext context) {
    loadPath();
    return SizedBox(
      height: 500,
      child: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Image.file(File(files[index].path)),
              title: Text(p.basename(files[index].path)),
              onTap: () {
                // TODO: 点击后的逻辑
              },
            ),
          );
        },
      ),
    );
  }

  loadPath([String path = '']) async {
    await storage.grantPermission();
    if (path == '') {
      path = config.initPath;
    }
    final List<FileSystemEntity> fileToShow = await storage.dirFiles(path);
    setState(() {
      files = fileToShow;
    });
  }
}
