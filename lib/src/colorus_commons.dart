import 'dart:math';

import 'package:flutter/material.dart';

///
///
///
class Circle extends StatelessWidget {
  /// Color of border
  final Color borderColor;

  /// Background color
  final Color color;

  /// Radius of circle
  final double radius;

  const Circle({
    super.key,
    required this.radius,
    this.borderColor = Colors.black,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 2 * radius,
    height: 2 * radius,
    decoration: BoxDecoration(
      border: Border.all(color: borderColor, width: 2),
      color: color,
      shape: BoxShape.circle,
    ),
  );
}

///
/// Basic Flutter colors sorted by _rainbow_
///
List<Color> rainbowColors = [
  Colors.red, // ❤️ Red
  Colors.deepOrange, // 🧡 Deep Orange
  Colors.orange, // 🧡 Orange
  Colors.amber, // 💛 Amber
  Colors.yellow, // 💛 Yellow
  Colors.lime, // 💚 Lime
  Colors.lightGreen, // 💚 Light Green
  Colors.green, // 💚 Green
  Colors.teal, // 💙 Teal
  Colors.cyan, // 💙 Cyan
  Colors.lightBlue, // 💙 Light Blue
  Colors.blue, // 💙 Blue
  Colors.indigo, // 💙 Indigo
  Colors.purple, // 💜 Purple
  Colors.deepPurple, // 💜 Deep Purple
  Colors.pink, // 💗 Pink
  Colors.brown, // 🤎 Brown
  Colors.grey, // 🖤 Grey
  Colors.blueGrey, // 🖤 Blue Grey
  Colors.black, // 🖤 Black
];

///
/// Finds nearest color from [colors]
///
Color findNearestColor(Color inputColor, List<Color> colors) {
  Color nearestColor = colors[0];
  double minDistance = double.infinity;

  for (Color color in colors) {
    double distance = sqrt(
      pow(inputColor.r - color.r, 2) +
          pow(inputColor.g - color.g, 2) +
          pow(inputColor.b - color.b, 2),
    );

    if (distance < minDistance) {
      minDistance = distance;
      nearestColor = color;
    }
  }

  return nearestColor;
}
