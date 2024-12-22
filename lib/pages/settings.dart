import 'package:chiyo_gallery/utils/locale_map.dart';
import 'package:flutter/material.dart';

import 'package:chiyo_gallery/components/selector.dart';
import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/utils/config.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({ super.key });

  @override
  State<SettingPage> createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  static final eventBus = GlobalEventBus.instance;

  @override
  Widget build(BuildContext ctx) {
    final languageList = [
      Selection(Languages.zhCN, Languages.zhCNIntro),
      Selection(Languages.enUS, Languages.enUSIntro),
      Selection(Languages.jaJP, Languages.jaJPIntro),
      Selection(Languages.zhTW, Languages.zhTWIntro)
    ];
    return Positioned.fill(child: Column(
      children: [Row(
          children: [
            Text('${'language'.tr()} : '),
            DropdownSelector(list: languageList, configPath: ConfigMap.language, eventType: 'language')
          ]
      )]
    ));
  }
}