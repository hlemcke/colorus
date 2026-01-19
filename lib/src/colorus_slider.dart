import 'dart:ui';

import 'package:flutter/material.dart';

///
/// Positioning
///
enum ColorusPosition { top, bottom, left, right, none }

///
/// Slider for red, green, blue, alpha
///
class ColorusSlider extends StatelessWidget {
  static const double interactiveHeight = 30;
  static const double sliderHeight = 48;
  static const double trackBarHeight = 16;
  final Color baseColor;
  final bool isHue;
  final ColorusPosition labelPosition;
  final ValueChanged<double> onChanged;
  final Orientation orientation;
  final bool withCheckerBoard;
  late final bool _isVertical;
  late final String _percentage;
  late final double _value;

  ColorusSlider({
    super.key,
    required double value,
    required this.baseColor,
    required this.onChanged,
    this.isHue = false,
    this.labelPosition = ColorusPosition.none,
    this.orientation = Orientation.landscape,
    this.withCheckerBoard = false,
  }) {
    _isVertical = orientation == Orientation.portrait;
    _value = clampDouble(value, 0, 1);
    _percentage = "${(_value * 100).round()}%";
  }

  @override
  Widget build(BuildContext context) {
    //--- The Slider Component
    Widget sliderCore = RotatedBox(
      quarterTurns: _isVertical ? 3 : 0,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: .none,
        children: [
          //--- Slim visual track (background)
          ClipRRect(
            borderRadius: BorderRadius.circular(trackBarHeight / 2),
            child: CustomPaint(
              size: const Size(double.infinity, trackBarHeight),
              painter: ColorusTrackPainter(
                color: baseColor,
                isHue: isHue,
                value: _value,
                withCheckerBoard: withCheckerBoard,
              ),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              minThumbSeparation: 4,
              overlayColor: Colors.black.withValues(alpha: 0.1),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: trackBarHeight,
              trackShape: const _FullWidthTrackShape(),
            ),
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(navigationMode: .directional),
              child: Slider(
                min: 0,
                max: 1,
                value: _value,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );

    if (labelPosition == ColorusPosition.none) {
      return _isVertical
          ? SizedBox(width: sliderHeight, child: sliderCore)
          : sliderCore;
    }

    // 2. The Label
    Widget label = SizedBox(
      width: _isVertical ? sliderHeight : null,
      child: Text(
        _percentage,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        textAlign: .center,
      ),
    );

    // 3. Dynamic Layout based on labelPosition
    return _buildPositionedLayout(sliderCore, label);
  }

  Widget _buildPositionedLayout(Widget slider, Widget label) {
    // Determine if the container should be a Row or Column
    final bool isColumn =
        labelPosition == ColorusPosition.top ||
        labelPosition == ColorusPosition.bottom;

    return Flex(
      direction: isColumn ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (labelPosition == ColorusPosition.top ||
            labelPosition == ColorusPosition.left)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: label,
          ),

        // Use Expanded if the slider needs to fill space in its main axis
        if (!_isVertical && !isColumn)
          Expanded(child: slider)
        else if (_isVertical && isColumn)
          Expanded(child: slider)
        else if (_isVertical)
          SizedBox(width: 24, child: slider)
        else
          slider,

        if (labelPosition == ColorusPosition.bottom ||
            labelPosition == ColorusPosition.right)
          label,
      ],
    );
  }
}

///
class ColorusTrackPainter extends CustomPainter {
  final Color color;
  final bool isHue;
  final double value; // 0.0 to 1.0
  final bool withCheckerBoard;

  ColorusTrackPainter({
    required this.color,
    required this.value,
    this.withCheckerBoard = false,
    this.isHue = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    //--- draw checkerboard
    if (withCheckerBoard) {
      final paintGray = Paint()..color = Colors.grey.withValues(alpha: 0.2);
      const double sq = 6.0;

      for (double i = 0; i < size.width; i += sq) {
        for (double j = 0; j < size.height; j += sq) {
          if ((i / sq).floor() % 2 == (j / sq).floor() % 2) {
            canvas.drawRect(Rect.fromLTWH(i, j, sq, sq), paintGray);
          }
        }
      }
    }

    //--- Draw main background (Gradient)
    late Gradient gradient;
    if (isHue) {
      gradient = LinearGradient(
        colors: [
          for (double i = 0; i <= 1; i += 0.01)
            HSVColor.fromAHSV(1.0, i * 360, 1.0, 1.0).toColor(),
        ],
        stops: [for (double i = 0; i <= 1; i += 0.01) i],
      );
    } else {
      gradient = LinearGradient(
        colors: [color.withValues(alpha: 0), color.withValues(alpha: 1)],
      );
    }
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    //--- Draw active line
    final double lineHeight = size.height / 3;
    final double yOffset = (size.height - lineHeight) / 2; // centers line
    final activeRect = Rect.fromLTWH(
      0,
      yOffset,
      size.width * value,
      lineHeight,
    );
    canvas.drawRect(
      activeRect,
      Paint()..color = Colors.black.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(ColorusTrackPainter old) =>
      old.value != value ||
      old.color != color ||
      old.isHue != isHue ||
      old.withCheckerBoard != withCheckerBoard;
}

class _FullWidthTrackShape extends RoundedRectSliderTrackShape {
  const _FullWidthTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    return Rect.fromLTWH(
      offset.dx,
      offset.dy + (parentBox.size.height - trackHeight) / 2,
      parentBox.size.width,
      trackHeight,
    );
  }
}

///
/// Checkerboard as slider background
///
class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.withValues(alpha: 0.2);
    const double sq = 6.0;
    for (double i = 0; i < size.width; i += sq) {
      for (double j = 0; j < size.height; j += sq) {
        if ((i / sq).floor() % 2 == (j / sq).floor() % 2) {
          canvas.drawRect(Rect.fromLTWH(i, j, sq, sq), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
