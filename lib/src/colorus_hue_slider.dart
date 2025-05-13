import 'package:flutter/material.dart';

///
///
///
class ColorusHueSlider extends StatelessWidget {
  final Color color;
  final ValueChanged<Color>? onChanged;

  const ColorusHueSlider({super.key, required this.color, this.onChanged});

  @override
  Widget build(BuildContext context) {
    HSVColor hsvColor = HSVColor.fromColor(color);
    double hueSliderValue = hsvColor.hue / 360;
    double opacitySliderValue = hsvColor.alpha;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSliderHue(hueSliderValue, opacitySliderValue),
        _buildSliderOpacity(hueSliderValue, opacitySliderValue),
      ],
    );
  }

  Widget _buildSliderHue(double hue, double opacity) => Container(
    height: 30,
    margin: EdgeInsets.only(bottom: 8, top: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(
        colors: [
          for (double i = 0; i <= 1; i += 0.01)
            HSVColor.fromAHSV(1.0, i * 360, 1.0, 1.0).toColor(),
        ],
        stops: [for (double i = 0; i <= 1; i += 0.01) i],
      ),
    ),
    child: Slider(
      onChanged: (v) => _updateColor(v, opacity),
      overlayColor: WidgetStatePropertyAll(Colors.black),
      thumbColor: Colors.white,
      value: hue,
    ),
  );

  Widget _buildSliderOpacity(double hue, double opacity) => Container(
    height: 30,
    margin: EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(colors: [Colors.white, color]),
    ),
    child: Slider(
      onChanged: (v) => _updateColor(hue, v),
      overlayColor: WidgetStatePropertyAll(Colors.black),
      thumbColor: Colors.white,
      value: opacity,
    ),
  );

  void _updateColor(double hue, double opacity) {
    Color clr = HSVColor.fromAHSV(opacity, hue * 360, 1.0, 1.0).toColor();
    if (onChanged != null) {
      onChanged!(clr);
    }
  }
}
