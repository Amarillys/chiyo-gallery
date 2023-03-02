import 'package:flutter/material.dart';

import 'package:chiyo_gallery/components/storage_bar.dart';
import 'package:chiyo_gallery/components/collection.dart';

class SideBar extends StatefulWidget {
  final bool isPortrait;
  const SideBar({ super.key, required this.isPortrait });

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
    var widgets = [
      storageBar,
      const CollectionBar()
    ];
    if (widget.isPortrait) {
      widgets.insert(0, Container(
        margin: const EdgeInsets.only(top: 30),
        height: 59,
        color: Colors.pink,
        child: const Align(
          alignment: Alignment.center,
          child: Text("CHIYO GALLERY", style: TextStyle(fontSize: 30, color: Colors.white))
        )
      ));
    }
    return Container(
      width: widget.isPortrait ? MediaQuery.of(context).size.width / 1.5 : null,
      color: widget.isPortrait ? const Color.fromRGBO(250, 250, 250, 0.9) : Colors.transparent,
      child: Column(children: widgets)
    );
  }
}