import 'dart:io';

import 'package:chiyo_gallery/utils/config.dart';
import 'package:chiyo_gallery/utils/string_util.dart';
import 'package:chiyo_gallery/utils/task_queue.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:chiyo_gallery/storage/storage.dart';
import 'package:chiyo_gallery/pages/main.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await EasyLocalization.ensureInitialized();
  await init();
  runApp(
      EasyLocalization(
        assetLoader: YamlAssetLoader(),
        supportedLocales: const [Locale('en'), Locale('zh', 'CN'), Locale('ja', 'JP'), Locale('zh', 'TW')],
        path: 'assets/translations',
        child: const ChiyoGallery())
      );
}

class ChiyoGallery extends StatelessWidget {
  const ChiyoGallery({super.key});

  static final storage = Storage.instance;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // TO-DO
    final languageValue = StringUtil.splitLang(GlobalConfig.get(ConfigMap.language));
    context.setLocale(Locale(languageValue.elementAt(0), languageValue.elementAt(1)));
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Chiyo Gallery',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: 'Chiyo Gallery'),
    );
  }
}

Future init() async {
  final appDataDirectoryPath = await getApplicationDocumentsDirectory();
  GlobalConfig(appDataDirectoryPath.path);
  if (Platform.isAndroid || Platform.isIOS) {
    TaskQueue(2);
  } else {
    TaskQueue(4);
  }
  final storage = Storage.instance;
  await storage.grantPermission();
  FlutterNativeSplash.remove();
}
