import 'package:chiyo_gallery/events/events_definition.dart';
import 'package:flutter/material.dart';
import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/components/fullscreen_viewer.dart';

class ViewerPage extends StatefulWidget {
  final List<String> imagePaths;
  final int imageIndex;
  const ViewerPage({ super.key, required this.imagePaths, required this.imageIndex });

  @override
  State<ViewerPage> createState() => ViewerState();
}

class ViewerState extends State<ViewerPage> {
  String imagePath = '';
  int currentIndex = 0;
  Color buttonBg = const Color.fromRGBO(100, 100, 100, 0.55);
  static const iconColor = Color.fromRGBO(233, 233, 233, 0.95);
  static final eventBus = GlobalEventBus.instance;

  @override
  void initState() {
    super.initState();
    imagePath = widget.imagePaths[widget.imageIndex];
    currentIndex = widget.imageIndex;

    eventBus.on<PrevImageEvent>().listen((event) {
      setState(prevPicture);
    });
    eventBus.on<NextImageEvent>().listen((event) {
      setState(nextPicture);
    });
  }

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(20));
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FullScreenViewer(imagePath: imagePath)
          ),
          Positioned(
              top: 30,
              left: 30,
              child: Material(
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: radius,
                    child: InkWell(
                        borderRadius: radius,
                        onTap: () => Navigator.pop(context),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            color: const Color.fromRGBO(135, 135, 135, 1),
                            child:const Icon(Icons.arrow_back, size: 28, color: Colors.white)
                  ))))
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child:ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Container(
                    width: 300,
                    height: 60,
                    color: buttonBg,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          setupActionIcon(Icons.arrow_back_ios_sharp, prevPicture),
                          setupActionIcon(Icons.arrow_forward_ios_sharp, nextPicture),
                        ],
                      )
                    ),
                  ),
            )),
          )]
      )
    );
  }

  nextPicture() {
    if (currentIndex + 1 >= widget.imagePaths.length) {
      currentIndex = 0;
    } else {
      currentIndex++;
    }
    setupImage();
  }

  prevPicture() {
    if (currentIndex - 1 < 0) {
      currentIndex = widget.imagePaths.length - 1;
    } else {
      currentIndex--;
    }
    setupImage();
  }

  void setupImage() {
    eventBus.fire(ImageChangedEvent());
    setState(() {
      imagePath = widget.imagePaths[currentIndex];
    });
  }

  setupActionIcon(IconData icon, VoidCallback callback) {
    return SizedBox(
        width: 60,
        height: 60,
        child: InkWell(
          onTap: callback,
          child: Icon(icon, color: iconColor),
        )
    );
  }
}
