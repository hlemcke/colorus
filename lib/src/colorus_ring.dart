import 'dart:math';

import 'package:flutter/material.dart';

import '../colorus.dart';

class ColorusRing extends StatefulWidget {
  final Color color;
  final ValueChanged<Color>? onChanged;
  final double thickness;
  final ColorusPosition alphaPosition;
  final bool showValue;

  const ColorusRing({
    super.key,
    required this.color,
    this.onChanged,
    this.thickness = 24,
    this.alphaPosition = ColorusPosition.none,
    this.showValue = false,
  });

  @override
  State<ColorusRing> createState() => _ColorusRingState();
}

class _ColorusRingState extends State<ColorusRing> {
  late double _h, _s, _v;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.color);
    _h = hsv.hue;
    _s = hsv.saturation;
    _v = hsv.value;
  }

  @override
  void didUpdateWidget(ColorusRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.color.toARGB32() != oldWidget.color.toARGB32()) {
      _syncInternalHSV(widget.color);
    }
  }

  void _notify(double h, double s, double v, double a) {
    setState(() {
      _h = h;
      _s = s;
      _v = v;
    });
    widget.onChanged?.call(HSVColor.fromAHSV(a, h, s, v).toColor());
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      bool hasSlider = widget.alphaPosition != ColorusPosition.none;
      bool isVertical =
          (widget.alphaPosition == ColorusPosition.left) ||
          (widget.alphaPosition == ColorusPosition.right);

      //--- Calculate ring size
      double availableWidth = constraints.maxWidth;
      double availableHeight = constraints.maxHeight;
      if (hasSlider) {
        if (isVertical) availableWidth -= 50;
        if (!isVertical) availableHeight -= 50;
      }
      double ringAreaSize = min(availableWidth, availableHeight);
      if (ringAreaSize == double.infinity) ringAreaSize = 250;

      // Central Ring Component
      Widget ringWidget = Center(
        child: SizedBox(
          width: ringAreaSize,
          height: ringAreaSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(ringAreaSize, ringAreaSize),
                painter: ColorRingPainter(
                  radius: (ringAreaSize / 2) - (widget.thickness / 2),
                  width: widget.thickness,
                ),
              ),
              _buildRingInteraction(ringAreaSize),
              _buildGradientSelector(ringAreaSize),
              _buildRingSelector(ringAreaSize),
            ],
          ),
        ),
      );

      if (widget.alphaPosition == ColorusPosition.none) return ringWidget;

      // Alpha Component (Slider)
      Widget alphaComponent = ColorusSlider(
        baseColor: HSVColor.fromAHSV(1.0, _h, _s, _v).toColor(),
        onChanged: (a) => _notify(_h, _s, _v, a),
        orientation: isVertical ? Orientation.portrait : Orientation.landscape,
        showValue: widget.showValue,
        value: widget.color.a,
        withCheckerBoard: true,
      );

      return _applyLayout(ringWidget, alphaComponent);
    },
  );

  Widget _applyLayout(Widget ring, Widget alpha) {
    switch (widget.alphaPosition) {
      case ColorusPosition.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [alpha, const SizedBox(height: 20), ring],
        );
      case ColorusPosition.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [ring, const SizedBox(height: 20), alpha],
        );
      case ColorusPosition.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [alpha, const SizedBox(width: 20), ring],
        );
      case ColorusPosition.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [ring, const SizedBox(width: 20), alpha],
        );
      default:
        return ring;
    }
  }

  // --- Sub-Builders ---

  Widget _buildRingInteraction(double size) {
    double center = size / 2;
    double radius = center - (widget.thickness / 2);
    double sqSize = 1.4 * radius - widget.thickness;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (d) =>
          _handleRingTouch(d.localPosition, center, radius, sqSize),
      onPanDown: (d) =>
          _handleRingTouch(d.localPosition, center, radius, sqSize),
      child: Container(color: Colors.transparent),
    );
  }

  void _handleRingTouch(
    Offset pos,
    double center,
    double radius,
    double sqSize,
  ) {
    double dx = pos.dx - center;
    double dy = pos.dy - center;
    if (dx.abs() < sqSize / 2 && dy.abs() < sqSize / 2) return;
    double dist = sqrt(dx * dx + dy * dy);
    if (dist < radius - widget.thickness || dist > radius + widget.thickness) {
      return;
    }
    double newHue = (atan2(dy, dx) * 180 / pi) % 360;
    _notify(newHue < 0 ? newHue + 360 : newHue, _s, _v, widget.color.a);
  }

  Widget _buildRingSelector(double size) {
    double radius = (size / 2) - (widget.thickness / 2);
    double angle = _h * pi / 180;
    return Positioned(
      left: (size / 2) + radius * cos(angle) - (widget.thickness / 2),
      top: (size / 2) + radius * sin(angle) - (widget.thickness / 2),
      child: IgnorePointer(
        child: Container(
          width: widget.thickness,
          height: widget.thickness,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black45)],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientSelector(double ringSize) {
    double radius = (ringSize / 2) - (widget.thickness / 2);
    double size = 1.4 * radius - widget.thickness;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: GradientSelector(
          hue: _h,
          saturation: _s,
          value: _v,
          size: size,
          onChanged: (s, v) => _notify(_h, s, v, widget.color.a),
        ),
      ),
    );
  }

  void _syncInternalHSV(Color color) {
    final hsv = HSVColor.fromColor(color);
    if (hsv.saturation > 0.01 || hsv.value > 0.01) {
      _h = hsv.hue;
    }
    _s = hsv.saturation;
    _v = hsv.value;
  }
}

// --- Supporting Painters ---

class ColorRingPainter extends CustomPainter {
  final double radius, width;

  ColorRingPainter({required this.radius, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const gradient = SweepGradient(
      colors: [
        Color(0xFFFF0000),
        Color(0xFFFFFF00),
        Color(0xFF00FF00),
        Color(0xFF00FFFF),
        Color(0xFF0000FF),
        Color(0xFFFF00FF),
        Color(0xFFFF0000),
      ],
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(ColorRingPainter old) => old.radius != radius;
}

class GradientSelector extends StatelessWidget {
  final double hue, saturation, value, size;
  final Function(double s, double v) onChanged;

  const GradientSelector({
    super.key,
    required this.hue,
    required this.saturation,
    required this.value,
    required this.size,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pure = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
    return GestureDetector(
      onPanUpdate: (d) => onChanged(
        (d.localPosition.dx / size).clamp(0, 1),
        (1 - d.localPosition.dy / size).clamp(0, 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white, pure]),
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
          Positioned(
            left: (saturation * size) - 10,
            top: ((1 - value) * size) - 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HSVColor.fromAHSV(1, hue, saturation, value).toColor(),
                border: Border.all(
                  color: value > 0.7 && saturation < 0.3
                      ? Colors.black54
                      : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
