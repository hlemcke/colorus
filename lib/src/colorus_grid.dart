import 'package:flutter/material.dart';

import 'colorus_commons.dart';

///
///
///
class ColorusGrid extends StatelessWidget {
  /// Color of border
  final Color borderColor;

  /// Currently selected color
  late final Color color;

  late final double _diameter;

  /// Radius of selectable color circles
  final double radius;

  /// Callback method invoked when color is changed by user
  final ValueChanged<Color>? onChanged;

  ///
  /// Horizontal and vertical spacing between color circles
  ///
  final double spacing;

  ColorusGrid({
    super.key,
    required Color color,
    this.borderColor = Colors.black,
    this.radius = 12,
    this.onChanged,
    this.spacing = 12,
  }) {
    this.color = findNearestColor(color, rainbowColors);
    _diameter = 2 * radius;
  }

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    runSpacing: spacing,
    spacing: spacing,
    children: [for (Color color in rainbowColors) _buildColorSelector(color)],
  );

  Widget _buildColorSelector(Color clr) => GestureDetector(
    onTap: (onChanged == null) ? null : () => onChanged!(clr),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: (clr == color) ? clr : Colors.black,
          width: 1,
        ),
        color: clr,
        shape: BoxShape.circle,
      ),
      height: _diameter,
      width: _diameter,
    ),
  );
}
