import 'package:flutter/material.dart';

///
///
class ColorusRGBSlider extends StatelessWidget {
  final Color color;
  final ValueChanged<Color>? onChanged;
  final bool withAlpha;

  const ColorusRGBSlider({
    super.key,
    required this.color,
    this.onChanged,
    this.withAlpha = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (withAlpha) _buildSlider(true, false, false, false),
      _buildSlider(false, true, false, false),
      _buildSlider(false, false, true, false),
      _buildSlider(false, false, false, true),
    ],
  );

  Widget _buildSlider(bool isA, bool isR, bool isG, bool isB) => Container(
    height: 30,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(
        colors: [
          Colors.white,
          isA
              ? color
              : isR
              ? Colors.red
              : isG
              ? Colors.green
              : Colors.blue,
        ],
      ),
    ),
    child: Slider(
      min: 0,
      max: 1,
      onChanged: (onChanged == null)
          ? null
          : (v) => onChanged!(
              Color.from(
                alpha: isA ? v : color.a,
                red: isR ? v : color.r,
                green: isG ? v : color.g,
                blue: isB ? v : color.b,
              ),
            ),
      overlayColor: WidgetStatePropertyAll(Colors.black),
      thumbColor: Colors.white,
      value: isA
          ? color.a
          : isR
          ? color.r
          : isG
          ? color.g
          : color.b,
    ),
  );
}
