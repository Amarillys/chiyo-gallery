import 'package:flutter/material.dart';

class CustomUnderline extends StatelessWidget {
  final Color color;
  final double height;

  const CustomUnderline(
      {super.key, this.color = const Color.fromRGBO(190, 190, 190, 0.4), this.height = 0.6});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Divider(thickness: height, color: color)
    );
  }
}
