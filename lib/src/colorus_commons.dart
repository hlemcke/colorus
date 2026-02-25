import 'dart:math';
import 'dart:typed_data';

import 'package:colorus/colorus.dart';
import 'package:flutter/material.dart';

/// Provides helper methods for WCAG 2.1 compliance
class ColorusHelper {
  ///
  /// Computes the average color inside `polygon`
  ///
  /// `pixels` are RGBA colors.
  ///
  Color averagePolygonColor(
    Uint8List pixels,
    int width,
    int height,
    List<Offset> polygon,
  ) {
    //--- Compute bounding box
    double minX = polygon.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    double maxX = polygon.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
    double minY = polygon.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
    double maxY = polygon.map((p) => p.dy).reduce((a, b) => a > b ? a : b);

    double sumR = 0, sumG = 0, sumB = 0;
    int count = 0;

    for (int y = minY.floor(); y <= maxY.ceil(); y++) {
      if (y < 0 || y >= height) continue;

      for (int x = minX.floor(); x <= maxX.ceil(); x++) {
        if (x < 0 || x >= width) continue;

        //--- Check if pixel center is inside polygon
        if (!isPointInPolygon(x + 0.5, y + 0.5, polygon)) continue;

        //--- Pixel index (RGBA)
        final i = (y * width + x) * 4;

        final r = pixels[i] / 255.0;
        final g = pixels[i + 1] / 255.0;
        final b = pixels[i + 2] / 255.0;

        sumR += r;
        sumG += g;
        sumB += b;
        count++;
      }
    }

    return (count == 0)
        ? const Color.from(red: 0, green: 0, blue: 0, alpha: 1)
        : Color.from(
            red: sumR / count,
            green: sumG / count,
            blue: sumB / count,
            alpha: 1.0,
          );
  }

  ///
  /// Computes luminance of `color` as perceived by humans
  ///
  static double computeLuminance(Color color) {
    double linearize(double channel) {
      return channel <= 0.03928
          ? channel / 12.92
          : pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * linearize(color.r) +
        0.7152 * linearize(color.g) +
        0.0722 * linearize(color.b);
  }

  /// Calculates the contrast ratio between two colors.
  /// Returns a value between 1.0 and 21.0.
  ///
  /// According to WCAG 2.1, the ratio should be
  /// at least 4.5:1 for normal text and 3.0:1 for large text
  static double getContrastRatio(Color color1, Color color2) {
    final double l1 = computeLuminance(color1);
    final double l2 = computeLuminance(color2);

    return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05);
  }

  ///
  /// Returns black or white for text based on relative luminance
  ///
  /// Formula: 0.2126 * R + 0.7152 * G + 0.0722 * B
  static Color getContrastColor(Color color, {bool isDarkMode = false}) {
    final Color surface = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final double r = (color.r * color.a) + (surface.r * (1.0 - color.a));
    final double g = (color.g * color.a) + (surface.g * (1.0 - color.a));
    final double b = (color.b * color.a) + (surface.b * (1.0 - color.a));

    // standard WCAG threshold is 0.175 for linearized luminance
    double luminance = (0.299 * r + 0.587 * g + 0.114 * b);
    return luminance > 0.175 ? Colors.black : Colors.white;
  }

  ///
  /// Interpolate between two colors.
  ///
  /// * lerp == 0 -> first color
  /// * lerp == 1 -> second color
  ///
  static Color interpolate(Color c1, Color c2, double lerp) {
    final lab1 = OKLabColor.fromColor(color: c1);
    final lab2 = OKLabColor.fromColor(color: c2);
    final lab3 = lab1.interpolate(lab2, lerp);
    final alpha = (c1.a - c2.a).abs() * lerp + min(c1.a, c2.a);
    return lab3.toColor().withAlpha((alpha * 255).toInt());
  }

  static bool isAccessible(Color bg, Color fg) =>
      getContrastRatio(bg, fg) >= 4.5;

  ///
  /// Checks if a point specified by its x and y coordinate is inside `polygon`
  ///
  static bool isPointInPolygon(double x, double y, List<Offset> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].dx, yi = polygon[i].dy;
      final xj = polygon[j].dx, yj = polygon[j].dy;

      final intersect =
          ((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi + 0.0000001) + xi);

      if (intersect) inside = !inside;
    }
    return inside;
  }
}

///
/// Helper class to compute values for `ColorusRing` and `ColorusWheel`
///
class ColorusLayout {
  final double spacing = 12;
  final double sliderThickness = 50;
  final double toggleSize = 24;

  /// Size of outer layout area for wheel plus optional slider
  late final double boxLength;

  /// diameter of the wheel
  late final double diameter;

  /// length of optional alpha-slider
  late final double sliderLength;
  late final bool hasSlider, hasToggle, isVertical;

  ColorusLayout({
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
    sliderLength = diameter;
    boxLength = diameter + (hasSlider ? sliderThickness : 0);
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
