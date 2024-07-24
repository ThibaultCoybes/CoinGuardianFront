import 'package:coin_guardian/components/background_bubbles/bubble.dart';
import 'package:flutter/material.dart';

class SecondaryBubble extends StatelessWidget {
  final Color color;
  final double? top;
  final double left;
  final double? bottom;

  const SecondaryBubble({
    Key? key,
    required this.color,
    required this.left,
    this.top,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: left + 70,
          top: top != null ? top! + 90 : null,
          child: Bubble(color: color, height: 49, width: 49),
        ),
        Positioned(
          left: left + 60,
          top: top != null ? top! + 168 : null,
          child: Bubble(color: color, height: 26, width: 26),
        ),
      ],
    );
  }
}
