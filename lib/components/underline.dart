import 'package:flutter/material.dart';

class CustomUnderline extends StatelessWidget {
  final Color color;

  const CustomUnderline(
      {super.key, this.color = const Color.fromRGBO(190, 190, 190, 0.4)});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
          ),
          child: Row(
            children: const [
              Expanded(
                child: SizedBox(height: 0.6),
              )
            ],
          )),
    );
  }
}
