import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';

class FullScreenViewer extends StatefulWidget {
  final String imagePath;
  const FullScreenViewer({super.key, required this.imagePath});

  @override
  State<FullScreenViewer> createState() => FullScreenViewerState();
}

class FullScreenViewerState extends State<FullScreenViewer> {
  @override
  Widget build(BuildContext context) {
    StatefulWidget imageWidget;
    if (widget.imagePath.contains('.avif')) {
      imageWidget = AvifImage.file(File(widget.imagePath), fit: BoxFit.contain);
    } else {
      imageWidget = Image.file(File(widget.imagePath), fit: BoxFit.contain);
    }
    return Scaffold(
        body: Stack(
        children: [
          Positioned.fill(child: imageWidget)
      ],
    ));
  }
}
