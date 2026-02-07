import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

///
/// Positioning of a slider when used by `ColorusRing` or `ColorusWheel`
///
enum ColorusSliderPosition { top, bottom, left, right, none }

///
/// Slider for red, green, blue, alpha, hue
///
class ColorusSlider extends StatelessWidget {
  static const double interactiveHeight = 36;
  static const double sliderGap = 5;
  static const double sliderHeight = 48;
  static const double thumbRadius = 14;
  static const double trackBarHeight = 18;

  final Color baseColor;
  final bool isHue;
  final ValueChanged<double> onChanged;
  final Orientation orientation;
  final bool withCheckerBoard;
  final bool showValue;
  late final bool _isVertical;
  late final double _value;

  ColorusSlider({
    super.key,
    required double value,
    required this.baseColor,
    required this.onChanged,
    this.isHue = false,
    this.orientation = Orientation.landscape,
    this.showValue = false,
    this.withCheckerBoard = false,
  }) {
    _isVertical = orientation == Orientation.portrait;
    _value = clampDouble(value, 0, 1);
  }

  @override
  Widget build(BuildContext context) => RotatedBox(
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
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: thumbRadius,
            ),
            thumbColor: Colors.white,
            thumbShape: ColorusThumbPainter(
              orientation: orientation,
              showValue: showValue,
              value: (_value * 100).round(),
            ),
            trackHeight: trackBarHeight,
            trackShape: const _FullWidthTrackShape(),
          ),
          child: Slider(
            min: 0.0,
            max: 1.0,
            value: _value,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
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

///
/// Custom painter to draw the number inside the thumb
///
class ColorusThumbPainter extends SliderComponentShape {
  final Orientation orientation;
  final bool showValue;
  final int value;

  ColorusThumbPainter({
    required this.orientation,
    required this.value,
    this.showValue = false,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(ColorusSlider.thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final double radius = ColorusSlider.thumbRadius;

    //--- 1. Draw shadow when active / dragged
    // activationAnimation.value is 0.0 when idle, and 1.0 when active/dragged.
    if (activationAnimation.value > 0) {
      final double activeProgress = activationAnimation.value;

      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.75 * activeProgress)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          6 * activeProgress, // Shadow gets blurrier as it "lifts"
        );

      // Draw the "lifted" shadow
      canvas.drawCircle(center, radius, shadowPaint);
    }

    // 2. Draw the white thumb circle
    final Paint thumbPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, thumbPaint);

    // 3. Optional: Draw a thin border so the thumb doesn't "disappear" on white backgrounds
    final Paint borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, radius, borderPaint);

    if (showValue) {
      // 2. Draw the text inside
      TextSpan span = TextSpan(
        style: TextStyle(
          fontSize: ColorusSlider.thumbRadius * 0.8,
          fontWeight: FontWeight.bold,
          color: Colors.black, // Text color
        ),
        text: '${this.value}',
      );

      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      tp.layout();

      // 3. Counter-rotate the canvas for the text
      canvas.save(); // Save current state

      // Move the canvas origin to the center of the thumb
      canvas.translate(center.dx, center.dy);

      // If vertical, the RotatedBox turned it 270 degrees (3 quarter turns).
      // We rotate it back 90 degrees (or -270) to make it upright.
      if (orientation == Orientation.portrait) {
        canvas.rotate(math.pi / 2);
      }

      // 4. Paint the text at the (now rotated) center
      // Since we translated to 'center', the new local center is Offset.zero
      Offset textOffset = Offset(-(tp.width / 2), -(tp.height / 2));
      tp.paint(canvas, textOffset);
      canvas.restore();
    }
  }
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
