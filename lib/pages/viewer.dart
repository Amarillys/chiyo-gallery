import 'package:chiyo_gallery/components/file_manager.dart';
import 'package:flutter/cupertino.dart';

class ViewerPage extends StatefulWidget {
  const ViewerPage({ super.key });

  @override
  State<ViewerPage> createState() => ViewerState();
}

class ViewerState extends State<ViewerPage> {

  @override
  Widget build(BuildContext context) {
    return const FileBrowser();
  }
}
