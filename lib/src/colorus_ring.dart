import 'dart:math';

import 'package:flutter/material.dart';

class ColorusRing extends StatelessWidget {
  final Color color;
  final ValueChanged<Color>? onChanged;
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
        // 1. Determine the square size
        double size = min(constraints.maxHeight, constraints.maxWidth);
        if (size == double.infinity) size = 200;

        final double center = size / 2;
        final double radialWidth = thickness;
        final double ringRadius = center - (radialWidth / 2);
        final double squareSize = 1.4 * ringRadius - radialWidth;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                //--- Layer 1: The Rainbow Ring
                CustomPaint(
                  size: Size(size, size),
                  painter: ColorRingPainter(
                    radius: ringRadius,
                    width: radialWidth,
                  ),
                ),

                //--- Layer 2: The Interaction Layer for the Ring
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) => _handleRingTouch(
                    details.localPosition,
                    center,
                    ringRadius,
                    squareSize,
                  ),
                  onPanDown: (details) => _handleRingTouch(
                    details.localPosition,
                    center,
                    ringRadius,
                    squareSize,
                  ),
                  //--- captures touches specifically for the Hue ring
                  child: Container(color: Colors.transparent),
                ),

                //--- Layer 3: The Gradient Square
                _buildGradientSelector(squareSize),

                //--- Layer 4: The Ring Selector Dot
                _buildRingSelector(size, ringRadius, radialWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleRingTouch(
    Offset localPos,
    double center,
    double ringRadius,
    double squareSize,
  ) {
    double dx = localPos.dx - center;
    double dy = localPos.dy - center;
    double distance = sqrt(dx * dx + dy * dy);

    // Ignore touches inside the square or too far outside the ring
    double halfSquare = squareSize / 2;
    if (dx.abs() < halfSquare && dy.abs() < halfSquare) return;
    if (distance < ringRadius - thickness || distance > ringRadius + thickness)
      return;

    double angle = atan2(dy, dx);
    double hue = (angle * 180 / pi) % 360;

    final hsv = HSVColor.fromColor(color);
    onChanged?.call(hsv.withHue(hue).toColor());
  }

  Widget _buildRingSelector(double size, double radius, double thickness) {
    double hsvHue = HSVColor.fromColor(color).hue;
    double angle = hsvHue * pi / 180;

    // We calculate the position relative to the local 'size' box
    return Positioned(
      left: (size / 2) + radius * cos(angle) - (thickness / 2),
      top: (size / 2) + radius * sin(angle) - (thickness / 2),
      child: IgnorePointer(
        child: Container(
          width: thickness,
          height: thickness,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black45)],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientSelector(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GradientSelector(color: color, size: size, onChanged: onChanged),
      ),
    );
  }
}

class ColorRingPainter extends CustomPainter {
  final double radius;
  final double width;

  ColorRingPainter({required this.radius, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      colors: [
        for (double i = 0; i <= 360; i += 5)
          HSVColor.fromAHSV(1, i, 1, 1).toColor(),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GradientSelector extends StatefulWidget {
  final Color color;
  final ValueChanged<Color>? onChanged;
  final double size;

  const GradientSelector({
    super.key,
    required this.color,
    required this.onChanged,
    required this.size,
  });

  @override
  State<GradientSelector> createState() => _GradientSelectorState();
}

class _GradientSelectorState extends State<GradientSelector> {
  bool _isDragging = false;

  void _updateSV(Offset localPos, HSVColor currentHsv) {
    // Clamping is key to stopping the "jump" at borders
    double s = (localPos.dx / widget.size).clamp(0.0, 1.0);
    double v = (1.0 - localPos.dy / widget.size).clamp(0.0, 1.0);
    widget.onChanged?.call(currentHsv.withSaturation(s).withValue(v).toColor());
  }

  @override
  Widget build(BuildContext context) {
    final hsv = HSVColor.fromColor(widget.color);
    final pureHueColor = hsv.withSaturation(1.0).withValue(1.0).toColor();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) => setState(() => _isDragging = true),
      onPanEnd: (_) => setState(() => _isDragging = false),
      onPanUpdate: (details) => _updateSV(details.localPosition, hsv),
      onPanDown: (details) => _updateSV(details.localPosition, hsv),
      child: Stack(
        clipBehavior: Clip.none,
        // Allows the zoomed dot to "exit" the box slightly
        children: [
          // Background Gradients
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, pureHueColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Animated Selection Indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 50),
            left: (hsv.saturation * widget.size) - (_isDragging ? 15 : 10),
            top: ((1 - hsv.value) * widget.size) - (_isDragging ? 15 : 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _isDragging ? 30 : 20,
              height: _isDragging ? 30 : 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                border: Border.all(
                  color: hsv.value > 0.7 ? Colors.black54 : Colors.white70,
                  width: _isDragging ? 3 : 2,
                ),
                boxShadow: _isDragging
                    ? [
                        const BoxShadow(
                          blurRadius: 10,
                          color: Colors.black38,
                          spreadRadius: 2,
                        ),
                      ]
                    : [const BoxShadow(blurRadius: 4, color: Colors.black26)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
