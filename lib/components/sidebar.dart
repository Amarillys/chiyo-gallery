import 'package:flutter/material.dart';

import 'package:chiyo_gallery/components/storage_bar.dart';
import 'package:chiyo_gallery/components/collection.dart';

class SideBar extends StatefulWidget {
  const SideBar({ super.key });

  @override
  State<SideBar> createState() => SideBarState();
}

class SideBarState extends State<SideBar> {
  final storageBar = const StorageBar();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        storageBar,
        const CollectionBar()
      ],
    );
  }
}