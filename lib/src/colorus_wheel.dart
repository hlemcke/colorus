import 'dart:math';

import 'package:flutter/material.dart';

///
class ColorusWheel extends StatelessWidget {
  // static const Color orange = Color.fromARGB(255, 0xfd, 0x82, 0x02);

  /// This color is initially displayed
  final Color color;

  /// Callback method invoked when color is changed by user
  final ValueChanged<Color>? onChanged;

  const ColorusWheel({super.key, required this.color, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double available = min(constraints.maxHeight, constraints.maxWidth);
        double radius = available / 2;

        // Convert Color -> HSV -> Canvas Coordinates
        final hsv = HSVColor.fromColor(color);
        final double angle = hsv.hue * pi / 180;
        final double distance = hsv.saturation * radius;

        final Offset indicatorPos = Offset(
          radius + distance * cos(angle),
          radius + distance * sin(angle),
        );

        return GestureDetector(
          onPanUpdate: (details) => _handleTouch(details.localPosition, radius),
          onPanDown: (details) => _handleTouch(details.localPosition, radius),
          child: Center(
            child: SizedBox(
              width: available,
              height: available,
              child: Stack(
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: ColorusWheelPainter(),
                    ),
                  ),
                  // The Selection Indicator
                  Positioned(
                    left: indicatorPos.dx - 12,
                    top: indicatorPos.dy - 12,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(blurRadius: 4, color: Colors.black45),
                        ],
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTouch(Offset localOffset, double radius) {
    final double dx = localOffset.dx - radius;
    final double dy = localOffset.dy - radius;
    final double distance = sqrt(dx * dx + dy * dy);

    // Calculate Hue (0-360)
    double angle = atan2(dy, dx) * 180 / pi;
    if (angle < 0) angle += 360;

    // Calculate Saturation (0-1)
    final double saturation = (distance / radius).clamp(0.0, 1.0);

    final Color newColor = HSVColor.fromAHSV(
      1.0,
      angle,
      saturation,
      1.0,
    ).toColor();
    onChanged?.call(newColor);
  }
}

///
/// Paints wheel with all colors
///
class ColorusWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    //--- Rainbow colors (Hue)
    final List<Color> colors = [
      const Color(0xFFFF0000), // Red
      const Color(0xFFFFFF00), // Yellow
      const Color(0xFF00FF00), // Green
      const Color(0xFF00FFFF), // Cyan
      const Color(0xFF0000FF), // Blue
      const Color(0xFFFF00FF), // Magenta
      const Color(0xFFFF0000), // Red again to close circle
    ];
    Rect rect = Offset.zero & size;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    Paint sweepPaint = Paint()
      ..shader = SweepGradient(colors: colors).createShader(rect);
    canvas.drawCircle(center, radius, sweepPaint);

    //--- Draw white overly (Saturation)
    // Adjust stops to make the white center smaller/tighter
    Paint radialPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withValues(alpha: 0.0)],
        stops: const [0.0, 0.2], // White only at the very center
      ).createShader(rect);

    canvas.drawCircle(center, radius, radialPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
