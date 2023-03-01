import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

import 'package:chiyo_gallery/pages/browser.dart';
import 'package:chiyo_gallery/components/sidebar.dart';
import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/events/events_definition.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final eventBus = GlobalEventBus.instance;

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        bool isPortrait = orientation == Orientation.portrait;
        List<Widget> titleComps = [const TitleBar()];
        if (!isPortrait) {
            titleComps.insert(0, Container(
              margin: const EdgeInsets.only(bottom: 3, right: 15),
                child: const Text("CHIYO GALLERY", style: TextStyle(fontSize: 24))));
        }
        return Scaffold(
            appBar: AppBar(
              title: Row(children: titleComps),
              leading: isPortrait ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                },
              ) : IconButton(
                icon: const Icon(Icons.arrow_back_ios_outlined),
                onPressed: () {
                  eventBus.fire(PathBackEvent());
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                )],
            ),
            body: isPortrait ?
                Row(children: const <Widget>[Expanded(flex: 1, child: BrowserPage())])
              : Row(children: const <Widget>[
                      Expanded(flex: 2, child: SideBar()),
                      Expanded(flex: 5, child: BrowserPage())
                ]),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Increment',
              child: const Icon(Icons.add)
            )
        );
    });
  }
}

class TitleBar extends StatefulWidget {
  const TitleBar({ super.key });

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {
  static final eventBus = GlobalEventBus.instance;
  List<String> paths = [];

  @override
  void initState() {
    super.initState();
    eventBus.on<PathChangedEvent>().listen((event) {
      setState(() {
        paths = p.split(event.path);
      });
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Row(
      children: paths.map((title) {
                  return InkWell(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 3, right: 20),
                      child: Text(title),
                    ),
                  );
                }).toList()
    );
  }
}