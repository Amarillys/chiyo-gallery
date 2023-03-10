import 'dart:io' show Platform;
import 'dart:core';
import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/events/events_definition.dart';
import 'package:chiyo_gallery/utils/image_util.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:chiyo_gallery/storage/storage.dart';
import 'package:chiyo_gallery/utils/config.dart';

class StorageBar extends StatelessWidget {
  const StorageBar({super.key});

  static final storage = Storage.instance;
  static final eventBus = GlobalEventBus.instance;

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
        contentPadding: const EdgeInsets.only(left: 15),
        dense: true,
        child: ExpansionTile(
            initiallyExpanded: true,
            title: Text('storageDevice'.tr(),
                style: const TextStyle(fontSize: 16)),
            children: generateStorageList(context)));
  }

  List<Widget> generateStorageList(BuildContext ctx) {
    List<Widget> tabs = [];
    for (var i = 0; i < storage.externalStoragePath.length; ++i) {
      final path = storage.externalStoragePath[i];
      tabs.add(InkWell(
          onTap: () { onItemTap(path); },
          child: Row(children: [
            setupIconByType(i),
            Text(setupStorageLabel(path).tr())
          ]))
      );
    }
    return tabs;
  }

  onItemTap(String path) {
    eventBus.fire(ChangePathEvent(path));
    eventBus.fire(CloseDrawerEvent());
  }

  static Widget setupIconByType(int index) {
    IconData icon;
    if (Platform.isAndroid || Platform.isIOS) {
      icon = Icons.sd_storage;
      if (index == 0) {
        icon = Icons.phone_android;
      }
    } else {
      icon = Icons.desktop_windows;
    }
    return Container(
        margin: const EdgeInsets.all(10.0),
        child: Icon(icon,
            color: ImageUtil.mapColorFromString(GlobalConfig.get(ConfigMap.baseColor)),
            size: 40));
  }

  static String setupStorageLabel(String path) {
    return storage.convertStoragePathForDisplay(path);
  }
}
