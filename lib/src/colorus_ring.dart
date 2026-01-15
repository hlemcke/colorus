import 'dart:math';

import 'package:flutter/material.dart';

import 'colorus_commons.dart';

///
class ColorusRing extends StatelessWidget {
  // static const Color orange = Color.fromARGB(255, 0xfd, 0x82, 0x02);

  /// This color is initially displayed
  final Color color;

  /// Callback method invoked when color is changed by user
  final ValueChanged<Color>? onChanged;

  /// Thickness of the ring
  final double thickness;

  const ColorusRing({
    super.key,
    required this.color,
    this.onChanged,
    this.thickness = 24,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = min(constraints.maxHeight, constraints.maxWidth);
        double radius = width / 2;
        double radialWidth = max(radius / 10, 24);
        radialWidth = max(radialWidth, thickness);
        radius -= radialWidth;
        // debugPrint( 'constraints=$constraints -> width=$width, radius=$radius, thick=$thickness' );
        return SizedBox(
          height: width,
          width: width,
          child: Stack(
            // alignment: Alignment.center,
            children: [
              _buildRing(width, radius, radialWidth),
              _buildRingSelector(width, radius, radialWidth),
              _buildGradientSelector(context, width, radius, radialWidth),
            ],
          ),
        );
      },
    );
  }

  /// Ring of all colors
  Widget _buildRing(double width, double radius, double thickness) =>
      Positioned(
        left: thickness / 2,
        top: thickness / 2,
        child: CustomPaint(
          size: Size(width, width),
          painter: ColorRingPainter(radius: radius, width: thickness),
          // ),
        ),
      );

  /// Color selector circle in ring
  Widget _buildRingSelector(double width, double radius, double thickness) {
    double angle = computeAngleFromColor(color);
    return Positioned(
      left: radius * (1 + cos(angle)),
      top: radius * (1 + sin(angle)),
      child: GestureDetector(
        onPanUpdate: (details) {
          double newAngle = atan2(
            details.localPosition.dy - radius,
            details.localPosition.dx - radius,
          );
          Color newColor = computeColorFromAngle(newAngle);
          if (onChanged != null) {
            onChanged!(newColor);
          }
        },
        child: Circle(radius: thickness / 2),
      ),
    );
  }

  /// Square inside ring to select brightness and saturation
  Widget _buildGradientSelector(
    BuildContext context,
    double width,
    double radius,
    double thickness,
  ) {
    double squareWidth = 1.4 * radius - thickness;
    return Positioned(
      left: radius - squareWidth / 2 + thickness / 2,
      top: radius - squareWidth / 2 + thickness / 2,
      child: GradientSelector(
        color: color,
        onChanged: onChanged,
        size: squareWidth,
      ),
    );
  }

  double computeAngleFromColor(Color color) {
    HSVColor hsvColor = HSVColor.fromColor(color);
    return hsvColor.hue * pi / 180;
  }

  Color computeColorFromAngle(double angle) {
    double hue = angle * 180 / pi;
    while (hue < 0) {
      hue += 360;
    }
    while (hue > 360) {
      hue -= 360;
    }
    HSVColor hsvColor = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0);
    return hsvColor.toColor();
  }
}

///
/// Points ring with all colors
///
class ColorRingPainter extends CustomPainter {
  double radius;
  double width;

  ColorRingPainter({required this.radius, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(radius, radius);
    final gradient = SweepGradient(
      colors: [
        for (double i = 0; i <= 1; i += 0.01)
          HSVColor.fromAHSV(1, i * 360, 1, 1).toColor(),
      ],
    );
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

///
/// Gradient selector square to select
///
/// * saturation -> left = low, right = high
/// * brightness -> bottom = low, top = high
///
class GradientSelector extends StatelessWidget {
  final Color color;
  late final HSVColor hsv;
  final ValueChanged<Color>? onChanged;

  /// Size (width and height) of the square
  final double size;

  GradientSelector({
    super.key,
    required this.color,
    required this.size,
    this.onChanged,
  }) {
    hsv = HSVColor.fromColor(color);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          Offset localPosition = box.globalToLocal(details.globalPosition);
          double saturation = (localPosition.dx / box.size.width);
          saturation = saturation.clamp(0.0, 1.0);
          double value = (1 - localPosition.dy / box.size.height);
          value = value.clamp(0.0, 1.0);
          HSVColor newHsv = HSVColor.fromAHSV(
            hsv.alpha,
            hsv.hue,
            saturation,
            value,
          );
          if (onChanged != null) {
            onChanged!(newHsv.toColor());
          }
        }
      },
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, color, Colors.black],
              ),
            ),
          ),
          Positioned(
            left: hsv.saturation * size - 10,
            top: (1 - hsv.value) * size - 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
