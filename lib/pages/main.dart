
import 'package:chiyo_gallery/components/custom_panel.dart';
import 'package:chiyo_gallery/utils/string_util.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:path/path.dart' as p;

import 'package:chiyo_gallery/pages/browser.dart';
import 'package:chiyo_gallery/components/sidebar.dart';
import 'package:chiyo_gallery/components/menu.dart';
import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/events/events_definition.dart';
import 'package:chiyo_gallery/storage/storage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final eventBus = GlobalEventBus.instance;
  bool showCustomPanel = false;
  List<CustomOption> menuOptions = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    eventBus.on<CloseDrawerEvent>().listen((event) {
      _scaffoldKey.currentState?.closeDrawer();
    });

    eventBus.on<ShowCustomPanelEvent>().listen((event) {
      setState(() {
        menuOptions = event.menuOptions;
        showCustomPanel = true;
      });
    });

    eventBus.on<HideCustomPanelEvent>().listen((event) {
      setState(() {
        showCustomPanel = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        bool isPortrait = orientation == Orientation.portrait;

        // header
        List<Widget> titleComps = [TitleBar(isPortrait: isPortrait)];
        if (!isPortrait) {
            titleComps.insert(0, Container(
              margin: const EdgeInsets.only(bottom: 3),
                child: const Text("CHIYO GALLERY  - ", style: TextStyle(fontSize: 24))));
        }

        // body
        final sideBarWidget = SideBar(isPortrait: isPortrait);
        List<Widget> bodyContent = [isPortrait ?
          Row(children: const <Widget>[Expanded(flex: 1, child: BrowserPage())]):
          Row(children: <Widget>[Expanded(flex: 2, child: sideBarWidget), const Expanded(flex: 6, child: BrowserPage())])
        ];
        if (showCustomPanel) {
          bodyContent.add(CustomPanel(menuOptions: menuOptions));
        }

        return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Row(children: titleComps),
              leading: isPortrait ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () { _scaffoldKey.currentState?.openDrawer(); },
              ) : IconButton(
                icon: const Icon(Icons.arrow_back_ios_outlined),
                onPressed: () {
                  eventBus.fire(PathBackEvent());
                  eventBus.fire(HideCustomPanelEvent());
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                const ContextMenu()]
            ),
            body: Stack(children: bodyContent),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Increment',
              child: const Icon(Icons.add)
            ),
            drawer: sideBarWidget
        );
    });
  }
}

class TitleBar extends StatefulWidget {
  final bool isPortrait;
  const TitleBar({ super.key, required this.isPortrait });

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {
  static final eventBus = GlobalEventBus.instance;
  static final storage = Storage.instance;
  List<String> paths = [];

  @override
  void initState() {
    super.initState();
    eventBus.on<PathChangedEvent>().listen((event) {
      setState(() {
        paths = p.split(event.path);
        if (paths.isNotEmpty) {
          paths[0] = storage.dealPrefixPath(paths[0]);
        }
      });
    });
  }

  @override
  Widget build(BuildContext ctx) {
    List<Widget> pathTab = [];
    var startIndex = 0;
    if (widget.isPortrait && paths.length > 2) {
      startIndex = paths.length - 2;
    }

    var iconSize = widget.isPortrait ? 15.0 : 18.0;
    var fontSize = widget.isPortrait ? 18.0 : 24.0;
    var margin = widget.isPortrait ?
      const EdgeInsets.only(left: 3, right:3) :
      const EdgeInsets.only(bottom: 3, left: 5, right: 5);
    for (var i = startIndex; i < paths.length; ++i) {
      pathTab.add(InkWell(
        onTap: () {
          final targetPath = paths.slice(0, i + 1).join('/');
          eventBus.fire(ChangePathEvent(targetPath));
        },
        child: Container(
          margin: margin,
          child: Text(StringUtil.cutString(paths[i], 7), style: TextStyle(fontSize: fontSize)),
        )
      ));
      if (i < paths.length - 1) {
        pathTab.add(Container(
          margin: const EdgeInsets.all(2.0),
          child: Icon(Icons.arrow_forward_ios, size: iconSize),
        ));
      }
    }
    return Row(
      children: pathTab
    );
  }
}