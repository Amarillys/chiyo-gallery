import 'package:flutter/material.dart';
import 'dart:io';
import 'package:toast/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:chiyo_gallery/pages/browser.dart';
import 'package:chiyo_gallery/components/sidebar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  File? willShowTestFile;

  void _incrementCounter() {
    setState(() {
      _counter++;
      if (_counter > 1) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          final locale = AppLocalizations.of(context);
          if (orientation == Orientation.portrait) {
            return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[BrowserPage()],
            ));
          } else {
            return Row(
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: Container(
                        // color: Colors.green,
                        child: const SideBar())),
                const Expanded(flex: 5, child: BrowserPage())
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
