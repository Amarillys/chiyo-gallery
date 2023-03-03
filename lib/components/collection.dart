import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/events/events_definition.dart';
import 'package:chiyo_gallery/utils/config.dart';
import 'package:chiyo_gallery/utils/image_util.dart';

class CollectionBar extends StatefulWidget {
  const CollectionBar({ super.key });

  @override
  State<CollectionBar> createState () => _CollectionBarState();
}

class _CollectionBarState extends State<CollectionBar> {
  late List<String> collections = [];
  static final eventBus = GlobalEventBus.instance;
  late StreamSubscription _addCollectionListener;

  @override
  void initState() {
    super.initState();
    collections = List<String>.from(GlobalConfig.get(ConfigMap.collections));

    _addCollectionListener = eventBus.on<AddCollectionEvent>().listen((event) {
      setState(() {
        collections.add(event.collectionPath);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
        contentPadding: const EdgeInsets.only(left: 15),
        dense: true,
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Text(AppLocalizations.of(context)!.collection,
            style: const TextStyle(fontSize: 16)),
            children: generateCollectionWidget()
        ),
    );
  }


  List<Widget> generateCollectionWidget() {
    List<Widget> items = [];
    for (var i = 0; i < collections.length; ++i) {
      items.add(InkWell(
          onTap: () {
            eventBus.fire(ChangePathEvent(collections[i]));
            eventBus.fire(CloseDrawerEvent());
          },
          child: Row(children: [
            Container(
                margin: const EdgeInsets.all(10),
                child: Icon(Icons.folder_special, size: 40,
                    color: ImageUtil.mapColorFromString(GlobalConfig.get(ConfigMap.baseColor)))),
            Text(p.basename(collections[i]))
          ])
      ));
    }
    return items;
  }

  @override
  void dispose() {
    _addCollectionListener.cancel();
    super.dispose();
  }
}