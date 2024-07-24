import 'package:coin_guardian/components/background_bubbles/bubble.dart';
import 'package:flutter/material.dart';

class PrimaryBubble extends StatelessWidget {
  final Color color;
  final double? top;
  final double left;
  final double? bottom;

  const PrimaryBubble({
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
          top: top,
          left: left,
          bottom: bottom,
          child: Bubble(color: color, height: 156, width: 156),
        ),
        Positioned(
          left: left + 75,
          bottom: bottom != null ? bottom! + 200 : null,
          child: Bubble(color: color, height: 49, width: 49),
        ),
        Positioned(
          left: left + 20,
          bottom: bottom != null ? bottom! + 168 : null,
          child: Bubble(color: color, height: 26, width: 26),
        ),
        Positioned(
          left: left + 140,
          bottom: bottom != null ? bottom! + 185 : null,
          child: Bubble(color: color, height: 23, width: 23),
        ),
        Positioned(
          left: left + 190,
          bottom: bottom != null ? bottom! + 135 : null,
          child: Bubble(color: color, height: 12, width: 12),
        ),
      ],
    );
  }
}
