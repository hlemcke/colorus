import 'package:flutter/material.dart';

import 'colorus_slider.dart';

class ColorusHueSlider extends StatelessWidget {
  final Color color;
  final ValueChanged<Color>? onChanged;

  const ColorusHueSlider({super.key, required this.color, this.onChanged});

  @override
  Widget build(BuildContext context) {
    HSVColor hsvColor = HSVColor.fromColor(color);
    // Values are already 0.0 to 1.0 (Hue is 0-360, Alpha is 0-1)
    double hueValue = hsvColor.hue / 360;
    double alphaValue = color.a;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Hue Slider
        ColorusSlider(
          value: hueValue,
          baseColor: Colors.transparent, // Ignored because isHue is true
          isHue: true,
          onChanged: (v) => _updateColor(v, alphaValue),
        ),
        const SizedBox(height: 8),
        // 2. Opacity (Alpha) Slider
        ColorusSlider(
          value: alphaValue,
          // Use current color at full opacity as the gradient end-point
          baseColor: color.withValues(alpha: 1.0),
          withCheckerBoard: true,
          onChanged: (v) => _updateColor(hueValue, v),
        ),
      ],
    );
  }

  void _updateColor(double huePercent, double alpha) {
    if (onChanged == null) return;

    // Convert back to 0-360 range for HSVColor
    HSVColor currentHsv = HSVColor.fromColor(color);
    Color updatedColor = HSVColor.fromAHSV(
      alpha,
      huePercent * 360,
      currentHsv.saturation,
      currentHsv.value,
    ).toColor();

    onChanged!(updatedColor);
  }
}
