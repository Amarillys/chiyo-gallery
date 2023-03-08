import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:chiyo_gallery/utils/config.dart';
import 'package:chiyo_gallery/components/custom_panel.dart';
import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/events/events_definition.dart';

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
      buildOptions();
    });
    eventBus.on<ClearItemChooseEvent>().listen((event) {
      selectedIndexes = [];
      buildOptions();
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

  void buildOptions () {
    options = [];
    final normalOptions = [
      PopupMenuItem(
        value: 'layout_options',
        child: Text('layoutType'.tr())
      ),
      const PopupMenuItem(
        value: 'move',
        child: Text('移动文件'),
      )
    ];
    if (selectedIndexes.length == 1) {
      normalOptions.add(PopupMenuItem(
        value: 'add_collection',
        child: Text('addToCollection'.tr()),
      ));
      setState(() {
        options = [...options, ... normalOptions];
      });
    } else {
      setState(() {
        options = normalOptions;
      });
    }
  }
  
  void handleOptions(value) {
    switch (value) {
      case 'add_collection':
        var collections = List<String>.from(GlobalConfig.get(ConfigMap.collections));
        eventBus.fire(AddCollectionEvent(paths[selectedIndexes[0]]));
        collections.add(paths[selectedIndexes[0]]);
        GlobalConfig.set(ConfigMap.collections, collections);
        break;
      case 'layout_options':
        eventBus.fire(ShowCustomPanelEvent([
          CustomOption(type: 'checkbox', valuePath: ConfigMap.showHidden, title: 'displayHidden'),
          CustomOption(type: 'selections', valuePath: ConfigMap.layoutType, title: 'layoutType', selections: [
            Selection(Icons.list, 'list', 'list'),
            Selection(Icons.window, 'tiling', 'tiling'),
            Selection(Icons.image, 'gallery', 'gallery')
          ])
        ]));
        break;
    }
  }

  void handlerChangeLayout (value) {

  }
}
