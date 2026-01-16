import 'dart:math';

import 'package:flutter/material.dart';

class ColorusWheel extends StatelessWidget {
  final Color color;
  final bool isBlackMode;
  final ValueChanged<Color>? onChanged;

  const ColorusWheel({
    super.key,
    required this.color,
    required this.isBlackMode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // 1. Determine the square size that fits the constraints
        double size = min(constraints.maxHeight, constraints.maxWidth);
        if (size == double.infinity) size = 200;

        double radius = size / 2;

        // 2. Map Color -> Coordinates
        final hsv = HSVColor.fromColor(color);
        final double angle = hsv.hue * pi / 180;
        final double distance =
            (isBlackMode ? hsv.value : hsv.saturation) * radius;

        final Offset indicatorPos = Offset(
          radius + distance * cos(angle),
          radius + distance * sin(angle),
        );

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: GestureDetector(
              // The hit test and coordinates are now bound to this square
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) =>
                  _handleTouch(details.localPosition, radius),
              onPanDown: (details) =>
                  _handleTouch(details.localPosition, radius),
              child: Stack(
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size(size, size),
                      painter: ColorusWheelPainter(isBlackMode: isBlackMode),
                    ),
                  ),
                  // The Selector Dot
                  Positioned(
                    left: indicatorPos.dx - 12,
                    top: indicatorPos.dy - 12,
                    child: _buildIndicator(hsv),
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
    final double factor = (distance / radius).clamp(0.0, 1.0);

    double angle = atan2(dy, dx) * 180 / pi;
    if (angle < 0) angle += 360;

    final Color newColor = isBlackMode
        ? HSVColor.fromAHSV(1.0, angle, 1.0, factor).toColor()
        : HSVColor.fromAHSV(1.0, angle, factor, 1.0).toColor();

    onChanged?.call(newColor);
  }

  Widget _buildIndicator(HSVColor hsv) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: (isBlackMode && hsv.value < 0.5) ? Colors.white : Colors.black,
          width: 3,
        ),
        color: color,
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
    );
  }
}

///
/// Paints wheel with all colors
///
class ColorusWheelPainter extends CustomPainter {
  final bool isBlackMode;

  ColorusWheelPainter({required this.isBlackMode});

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    // Rainbow Hue
    final List<Color> colors = [
      const Color(0xFFFF0000),
      const Color(0xFFFFFF00),
      const Color(0xFF00FF00),
      const Color(0xFF00FFFF),
      const Color(0xFF0000FF),
      const Color(0xFFFF00FF),
      const Color(0xFFFF0000),
    ];
    canvas.drawCircle(
      center,
      radius,
      Paint()..shader = SweepGradient(colors: colors).createShader(rect),
    );

    // Radial Overlay (White or Black)
    Paint radialPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isBlackMode ? Colors.black : Colors.white,
          (isBlackMode ? Colors.black : Colors.white).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.8],
      ).createShader(rect);

    canvas.drawCircle(center, radius, radialPaint);
  }

  @override
  bool shouldRepaint(ColorusWheelPainter oldDelegate) =>
      oldDelegate.isBlackMode != isBlackMode;
}

///
/// Toggle for wheel between black and white mode
///
class ColorusWheelToggle extends StatelessWidget {
  final bool isBlackMode;
  final VoidCallback onToggle;

  const ColorusWheelToggle({
    super.key,
    required this.isBlackMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isBlackMode ? Colors.black : Colors.white,
          border: Border.all(color: Colors.grey),
        ),
        child: Icon(
          isBlackMode ? Icons.nightlight_round : Icons.wb_sunny,
          color: isBlackMode ? Colors.white : Colors.orange,
          size: 20,
        ),
      ),
    );
  }
}

///
///
///
class ColorusWheelWithToggle extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onChanged;

  const ColorusWheelWithToggle({
    super.key,
    required this.color,
    required this.onChanged,
  });

  @override
  State<ColorusWheelWithToggle> createState() => _ColorusWheelWithToggleState();
}

class _ColorusWheelWithToggleState extends State<ColorusWheelWithToggle> {
  bool _isBlackMode = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Match the sizing logic of the Wheel itself
        double size = min(constraints.maxHeight, constraints.maxWidth);
        if (size == double.infinity) size = 200;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                ColorusWheel(
                  color: widget.color,
                  isBlackMode: _isBlackMode,
                  onChanged: widget.onChanged,
                ),
                // Toggle sits exactly at the top-right of the square
                Positioned(right: 0, top: 0, child: _buildModeToggle()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isBlackMode = !_isBlackMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isBlackMode ? Colors.grey[900] : Colors.white,
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
          border: Border.all(
            color: _isBlackMode ? Colors.white24 : Colors.black12,
          ),
        ),
        child: Icon(
          _isBlackMode ? Icons.nightlight_round : Icons.wb_sunny,
          size: 18,
          color: _isBlackMode ? Colors.blueAccent : Colors.orange,
        ),
      ),
    );
  }
}
