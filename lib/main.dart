import 'package:flutter/material.dart';
import 'package:global_configs/global_configs.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import './storage/storage.dart';
import './pages/main.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ChiyoGallery());
}

class ChiyoGallery extends StatelessWidget {
  const ChiyoGallery({super.key});

  static final storage = Storage.instance;
  static final Future<GlobalConfigs> _config = init();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _config,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            FlutterNativeSplash.remove();
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
            return const Text('initialing...');
          }
        });
  }

  static Future<GlobalConfigs> init() async {
    await storage.grantPermission();
    return GlobalConfigs().loadJsonFromdir('assets/configs/dev.json');
  }
}
