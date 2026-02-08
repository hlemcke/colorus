import 'dart:math';

import 'package:colorus/src/colorus_commons.dart';
import 'package:flutter/material.dart';

import '../colorus.dart';

///
/// Positioning of the toggle used by `ColorusWheel`
///
enum ColorusTogglePosition { bottomLeft, bottomRight, topLeft, topRight, none }

///
class ColorusWheel extends StatefulWidget {
  final Color color;
  final bool isBlackMode;
  final ValueChanged<Color>? onChanged;
  final ColorusSliderPosition alphaPosition;
  final ColorusTogglePosition togglePosition;
  final bool showValue;

  ///
  /// A wheel with all rainbow colors and the gradient from center to border
  ///
  /// `alphaPosition` will add a slider to set the alpha value.
  /// Otherwise it will remain unchanged.
  ///
  /// `showValue: true` will display the alpha value inside its selector
  ///
  /// `togglePosition` will add a toggle to change the gradient from center to
  /// border or the other way round.
  ///
  const ColorusWheel({
    super.key,
    required this.color,
    this.onChanged,
    this.alphaPosition = ColorusSliderPosition.none,
    this.isBlackMode = false,
    this.showValue = false,
    this.togglePosition = ColorusTogglePosition.none,
  });

  @override
  State<StatefulWidget> createState() => _ColorusWheelState();
}

class _ColorusWheelState extends State<ColorusWheel> {
  late Color _color;
  late double _a, _h, _s, _v;
  late bool _isBlackMode;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
    _isBlackMode = widget.isBlackMode;
    final hsv = HSVColor.fromColor(widget.color);
    _a = widget.color.a;
    _h = hsv.hue;
    _s = hsv.saturation;
    _v = hsv.value;

    //--- Adjust alpha if no slider and its near zero
    if ((_a < 0.05) && (widget.alphaPosition == .none)) _a = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        ColorusLayout layout = ColorusLayout(
          constraints: constraints,
          sliderPosition: widget.alphaPosition,
          togglePosition: widget.togglePosition,
        );

        Widget wheel = _buildWheel(layout);
        Widget slider = _buildSlider(layout);
        Widget toggle = _buildToggle(layout);

        return _applyLayout(layout, wheel, slider, toggle);
      },
    );
  }

  @override
  void didUpdateWidget(ColorusWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.color.toARGB32() != oldWidget.color.toARGB32()) {
      _syncInternalHSV(widget.color);
      _color = widget.color;
    }
  }

  /// Layout widgets
  Widget _applyLayout(
    ColorusLayout layout,
    Widget wheel,
    Widget slider,
    Widget toggle,
  ) {
    double dt = layout.sliderThickness; // Delta for slider
    ColorusSliderPosition ap = widget.alphaPosition;
    return SizedBox.square(
      dimension: layout.boxLength,
      child: Stack(
        children: [
          //--- The optional alpha-slider
          switch (widget.alphaPosition) {
            .none => SizedBox.shrink(),
            .top => Positioned(top: 0, left: 0, right: dt, child: slider),
            .right => Positioned(right: 0, top: 0, bottom: dt, child: slider),
            .bottom => Positioned(bottom: 0, left: 0, right: dt, child: slider),
            .left => Positioned(left: 0, top: 0, bottom: dt, child: slider),
          },
          //--- The wheel itself
          switch (widget.alphaPosition) {
            .none => wheel,
            .top => Positioned(bottom: 0, child: wheel),
            .right => Positioned(left: 0, child: wheel),
            .bottom => Positioned(top: 0, child: wheel),
            .left => Positioned(right: 0, child: wheel),
          },
          //--- The optional toggle action
          switch (widget.togglePosition) {
            .none => SizedBox.shrink(),
            .topRight => Positioned(
              top: ap == .top ? dt : 0,
              right: ap == .top || ap == .right || ap == .bottom ? dt : 0,
              child: toggle,
            ),
            .bottomRight => Positioned(
              bottom: ap == .bottom || ap == .left || ap == .right ? dt : 0,
              right: ap == .top || ap == .bottom || ap == .right ? dt : 0,
              child: toggle,
            ),
            .bottomLeft => Positioned(
              bottom: ap == .bottom || ap == .left || ap == .right ? dt : 0,
              left: ap == .left ? dt : 0,
              child: toggle,
            ),
            .topLeft => Positioned(
              left: ap == .left ? dt : 0,
              top: ap == .top ? dt : 0,
              child: toggle,
            ),
          },
        ],
      ),
    );
  }

  /// Builds the alpha-slider
  Widget _buildSlider(ColorusLayout layout) {
    if (!layout.hasSlider) return const SizedBox.shrink();

    return SizedBox(
      width: layout.isVertical ? layout.sliderThickness : layout.sliderLength,
      height: layout.isVertical ? layout.sliderLength : layout.sliderThickness,
      child: ColorusSlider(
        baseColor: _color,
        onChanged: (alpha) => _notify(alpha, _h, _s, _v),
        orientation: layout.isVertical ? .portrait : .landscape,
        showValue: widget.showValue,
        value: _a,
        withCheckerBoard: true,
      ),
    );
  }

  Widget _buildToggle(ColorusLayout layout) => (widget.togglePosition == .none)
      ? const SizedBox.shrink()
      : ColorusWheelToggle(
          isBlackMode: _isBlackMode,
          onToggle: () => setState(() => _isBlackMode = !_isBlackMode),
        );

  /// Builds the wheel
  Widget _buildWheel(ColorusLayout circle) {
    final double radius = circle.diameter / 2;
    final double angle = _h * pi / 180;
    final double distance = (_isBlackMode ? _v : _s) * radius;

    final Offset indicatorPos = Offset(
      radius + distance * cos(angle),
      radius + distance * sin(angle),
    );

    return SizedBox(
      width: circle.diameter,
      height: circle.diameter,
      child: Stack(
        children: [
          GestureDetector(
            // The hit test and coordinates are now bound to this square
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => _handleTouch(d.localPosition, radius),
            onPanDown: (d) => _handleTouch(d.localPosition, radius),
            child: CustomPaint(
              size: Size(circle.diameter, circle.diameter),
              painter: _ColorusWheelPainter(isBlackMode: _isBlackMode),
            ),
          ),
          // The Selector Dot
          Positioned(
            left: indicatorPos.dx - 12,
            top: indicatorPos.dy - 12,
            child: IgnorePointer(child: _buildIndicator()),
          ),
        ],
      ),
    );
  }

  void _handleTouch(Offset localOffset, double radius) {
    final double dx = localOffset.dx - radius;
    final double dy = localOffset.dy - radius;
    final double distance = sqrt(dx * dx + dy * dy);
    final double factor = (distance / radius).clamp(0.0, 1.0);

    double angle = atan2(dy, dx) * 180 / pi;
    if (angle < 0) angle += 360;

    return _isBlackMode
        ? _notify(_a, angle, 1.0, factor)
        : _notify(_a, angle, factor, 1.0);
  }

  Widget _buildIndicator() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: (_isBlackMode && _v < 0.5) ? Colors.white : Colors.black,
          width: 3,
        ),
        color: _color,
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
    );
  }

  void _notify(double a, double h, double s, double v) {
    setState(() {
      _a = a;
      _h = h;
      _s = s;
      _v = v;
    });
    _color = HSVColor.fromAHSV(a, h, s, v).toColor();
    widget.onChanged?.call(_color);
  }

  void _syncInternalHSV(Color color) {
    final hsv = HSVColor.fromColor(color);
    _a = color.a;
    if (hsv.saturation > 0.01 || hsv.value > 0.01) {
      _h = hsv.hue;
    }
    _s = hsv.saturation;
    _v = hsv.value;
  }
}

///
/// Toggle for wheel between black and white gradient
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
  Widget build(BuildContext context) => IconButton(
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

///
/// Paints wheel with all colors
///
class _ColorusWheelPainter extends CustomPainter {
  final bool isBlackMode;

  _ColorusWheelPainter({required this.isBlackMode});

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
  bool shouldRepaint(_ColorusWheelPainter oldDelegate) =>
      oldDelegate.isBlackMode != isBlackMode;
}
