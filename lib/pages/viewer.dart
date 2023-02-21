import 'package:flutter/material.dart';
import '../components/fullscreen_viewer.dart';

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

  @override
  void initState() {
    super.initState();
    imagePath = widget.imagePaths[widget.imageIndex];
    currentIndex = widget.imageIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FullScreenViewer(imagePath: imagePath)
          ),
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context))
          ),
          Positioned(
            top: 650,
            left: 500,
            child: IconButton(
              icon: const Icon(Icons.arrow_left, size: 80, color: Colors.black54),
              onPressed: () => prevPicture())
          ),
          Positioned(
            top: 650,
            left: 650,
            child: IconButton(
              icon: const Icon(Icons.arrow_right, size: 80,  color: Colors.black54),
              onPressed: () => nextPicture())
          )],
      )
    );
  }

  nextPicture() {
    if (currentIndex + 1 >= widget.imagePaths.length) {
      currentIndex = 0;
    } else {
      currentIndex++;
    }
    setState(() {
      imagePath = widget.imagePaths[currentIndex];
    });
  }

  prevPicture() {
    if (currentIndex - 1 < 0) {
      currentIndex = widget.imagePaths.length - 1;
    } else {
      currentIndex--;
    }
    setState(() {
      imagePath = widget.imagePaths[currentIndex];
    });
  }


}
