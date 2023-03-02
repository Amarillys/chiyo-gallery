import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/events/events_definition.dart';
import 'package:chiyo_gallery/utils/config.dart';

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
    if (selectedIndexes.length == 1) {
      setState(() {
        options = <PopupMenuEntry>[
          PopupMenuItem(
            value: 'add_collection',
            child: Text(AppLocalizations.of(context)!.addToCollection),
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
  }
  
  void handleOptions(value) {
    switch (value) {
      case 'add_collection':
        var collections = List<String>.from(GlobalConfig.get(ConfigMap.collections));
        eventBus.fire(AddCollectionEvent(paths[selectedIndexes[0]]));
        collections.add(paths[selectedIndexes[0]]);
        GlobalConfig.set(ConfigMap.collections, collections);
        break;
    }
  }
}
