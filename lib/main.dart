import 'dart:io';

import 'package:chiyo_gallery/utils/config.dart';
import 'package:chiyo_gallery/utils/task_queue.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:chiyo_gallery/storage/storage.dart';
import 'package:chiyo_gallery/pages/main.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ChiyoGallery());
}

class ChiyoGallery extends StatelessWidget {
  const ChiyoGallery({super.key});

  static final storage = Storage.instance;
  static final Future<bool> _init = init();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              title: 'Chiyo Gallery',
              theme: ThemeData(
                primarySwatch: Colors.pink,
              ),
              home: const MyHomePage(title: 'Chiyo Gallery'),
            );
          } else {
            return const MaterialApp(
                home: Text('initialing...'));
          }
        });
  }

  static Future<bool> init() async {
    final appDataDirectoryPath = await getApplicationDocumentsDirectory();
    GlobalConfig(appDataDirectoryPath.path);
    if (Platform.isAndroid || Platform.isIOS) {
      TaskQueue(2);
    } else {
      TaskQueue(4);
    }
    await storage.grantPermission();
    FlutterNativeSplash.remove();
    return true;
  }
}
