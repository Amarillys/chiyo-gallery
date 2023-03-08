import 'dart:io';
import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/events/events_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenViewer extends StatefulWidget {
  final String imagePath;
  const FullScreenViewer({super.key, required this.imagePath});

  @override
  State<FullScreenViewer> createState() => FullScreenViewerState();
}

class FullScreenViewerState extends State<FullScreenViewer> {
  static final eventBus = GlobalEventBus.instance;
  // late PhotoViewController controller;
  final PhotoViewScaleStateController scaleController = PhotoViewScaleStateController();
  double initScale = 1;

  @override
  void initState () {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider imageWidget;
    if (widget.imagePath.contains('.avif')) {
      imageWidget = AvifImage.file(File(widget.imagePath), fit: BoxFit.contain).image;
    } else {
      imageWidget = Image.file(File(widget.imagePath), fit: BoxFit.contain).image;
    }
    final viewer = PhotoView(
        imageProvider: imageWidget,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        initialScale: PhotoViewComputedScale.contained,
        enableRotation: true,
        scaleStateController: scaleController,
        filterQuality: FilterQuality.high,
        onScaleEnd: (context, details, controllerValue) {
          if (details.pointerCount > 0) return;
          if (details.velocity.pixelsPerSecond.dx > 1000) {
            eventBus.fire(PrevImageEvent());
          } else if (details.velocity.pixelsPerSecond.dx < -1000) {
            eventBus.fire(NextImageEvent());
          }
        }
    );
    return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: viewer)
          ]
        ));
  }

  @override
  void dispose() {
    // controller.dispose();
    scaleController.dispose();
    super.dispose();
  }
}
