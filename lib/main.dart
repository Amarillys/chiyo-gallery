import 'package:flutter/material.dart';
import 'package:global_configs/global_configs.dart';
import './storage/storage.dart';
import './pages/main.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final storage = Storage.instance;
  static final Future<GlobalConfigs> _config = init();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _config,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
              title: 'Chiyo Gallery',
              theme: ThemeData(
                primarySwatch: Colors.pink,
              ),
              home: const MyHomePage(title: 'Flutter Demo Home Page'),
            );
          } else {
            return MaterialApp(
              title: 'Chiyo Gallery',
              theme: ThemeData(
                primarySwatch: Colors.pink,
              ),
              home: const Text('Initializing...')
            );
          }
        });
  }

  static Future<GlobalConfigs> init() async {
    await storage.grantPermission();
    return GlobalConfigs().loadJsonFromdir('assets/configs/dev.json');
  }
}
