import 'dart:math';

import 'package:colorus/colorus.dart';
import 'package:flutter/material.dart';

///
/// Helper class to compute values for `ColorusRing` and `ColorusWheel`
///
class ColorusCircle {
  final double spacing = 12;
  final double sliderThickness = 50;
  final double toggleSize = 24;
  late final double boxLength, diameter, sliderLength;
  late final bool hasSlider, hasToggle, isVertical;

  ColorusCircle({
    required BoxConstraints constraints,
    ColorusSliderPosition sliderPosition = .none,
    ColorusTogglePosition togglePosition = .none,
  }) {
    hasSlider = sliderPosition != .none;
    hasToggle = togglePosition != .none;
    isVertical = (sliderPosition == .left) || (sliderPosition == .right);
    double availW = constraints.hasInfiniteWidth ? 300 : constraints.maxWidth;
    double availH = constraints.hasInfiniteHeight ? 300 : constraints.maxHeight;

    if (hasSlider) {
      availW -= isVertical ? sliderThickness : 0;
      availH -= isVertical ? 0 : sliderThickness;
    }

    diameter = min(availH, availW).clamp(100.0, double.infinity);

    bool hasConflict = false;
    if (hasSlider && hasToggle) {
      hasConflict = switch (sliderPosition) {
        .top => togglePosition == .topLeft || togglePosition == .topRight,
        .right => togglePosition == .topRight || togglePosition == .bottomRight,
        .bottom =>
          togglePosition == .bottomRight || togglePosition == .bottomLeft,
        .left => togglePosition == .bottomLeft || togglePosition == .topLeft,
        _ => false,
      };
    }
    sliderLength = diameter - (hasConflict ? toggleSize : 0);
  }

  Widget get hGap => SizedBox(width: spacing);

  Widget get vGap => SizedBox(height: spacing);
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
