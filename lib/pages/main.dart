import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'dart:io';
import 'package:chiyo_gallery/utils/config.dart' as config;
import 'package:toast/toast.dart';
import 'package:chiyo_gallery/pages/browser.dart';

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
                        color: Colors.green,
                        child: const Center(child: Text('Left')))),
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
