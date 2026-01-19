import 'package:flutter/material.dart';

import 'colorus_slider.dart';

class ColorusRGBSlider extends StatelessWidget {
  final Color color;
  final ValueChanged<Color>? onChanged;
  final bool withAlpha;

  const ColorusRGBSlider({
    super.key,
    required this.color,
    this.onChanged,
    this.withAlpha = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (withAlpha)
          _buildSlider(
            value: color.a,
            baseColor: color.withValues(alpha: 1.0),
            // Show color at full opacity in gradient
            isAlpha: true,
            label: "A",
          ),
        _buildSlider(value: color.r, baseColor: Colors.red, label: "R"),
        _buildSlider(value: color.g, baseColor: Colors.green, label: "G"),
        _buildSlider(value: color.b, baseColor: Colors.blue, label: "B"),
      ],
    );
  }

  Widget _buildSlider({
    required double value,
    required Color baseColor,
    required String label,
    bool isAlpha = false,
  }) {
    return ColorusSlider(
      value: value,
      baseColor: baseColor,
      withCheckerBoard: isAlpha,
      orientation: Orientation.landscape,
      onChanged: (v) {
        if (onChanged == null) return;
        onChanged!(
          Color.from(
            alpha: isAlpha ? v : color.a,
            red: label == "R" ? v : color.r,
            green: label == "G" ? v : color.g,
            blue: label == "B" ? v : color.b,
          ),
        );
      },
    );
  }
}
