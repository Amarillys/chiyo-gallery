import 'package:flutter/material.dart';

import 'package:chiyo_gallery/components/file_manager.dart';
import 'package:chiyo_gallery/controller/file/storage_file_controller.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({ super.key });

  @override
  State<BrowserPage> createState() => ViewerState();
}

class ViewerState extends State<BrowserPage> {

  @override
  Widget build(BuildContext context) {
    return FileBrowser(controller: StorageFileController(),);
  }
}
