import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/events/events_definition.dart';
import 'package:flutter/material.dart';

class ContextMenu extends StatefulWidget {
  const ContextMenu({super.key});

  @override
  State<ContextMenu> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  static final eventBus = GlobalEventBus.instance;
  List<PopupMenuEntry> options = [];
  List<int> selectedIndexes = [];
  List<String> paths = [];

  @override
  void initState() {
    super.initState();
    eventBus.on<ItemChooseEvent>().listen((event) {
      selectedIndexes = event.itemIndexes;
      paths = event.paths;
      if (event.itemIndexes.length == 1) {
        setState(() {
          options = <PopupMenuEntry>[
            const PopupMenuItem(
              value: 'add_collection',
              child: Text('添加到收藏夹'),
            ),
            const PopupMenuItem(
              value: 'move',
              child: Text('移动文件'),
            )
          ];
        });
      } else {
        setState(() {
          options = <PopupMenuEntry>[
            const PopupMenuItem(
              value: 'move',
              child: Text('移动文件'),
            )
          ];
        });
      }
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return PopupMenuButton(
        onSelected: handleOptions,
        itemBuilder: (BuildContext ctx) {
          return options;
        }
    );
  }
  
  void handleOptions(value) {
    switch (value) {
      case 'add_collection':
        eventBus.fire(AddCollectionEvent(paths[selectedIndexes[0]]));
    }
  }
}
