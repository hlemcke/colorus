import 'package:flutter/material.dart';

///
///
class ColorusHueSlider extends StatefulWidget {
  final Color color;
  final ValueChanged<Color>? onChanged;

  const ColorusHueSlider({super.key, required this.color, this.onChanged});

  @override
  State<StatefulWidget> createState() => _ColorusHueSliderState();
}

class _ColorusHueSliderState extends State<ColorusHueSlider> {
  double _hueSliderValue = 0.0;
  double _opacitySliderValue = 1.0;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
    HSVColor hsvColor = HSVColor.fromColor(_color);
    _hueSliderValue = hsvColor.hue / 360;
    _opacitySliderValue = hsvColor.alpha;
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [_buildSliderHue(), _buildSliderOpacity()],
  );

  Widget _buildSliderHue() => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              for (double i = 0; i <= 1; i += 0.01)
                HSVColor.fromAHSV(1.0, i * 360, 1.0, 1.0).toColor(),
            ],
            stops: [for (double i = 0; i <= 1; i += 0.01) i],
          ),
        ),
      ),
      Slider(
        onChanged: (v) => setState(() => _updateColor(v, _opacitySliderValue)),
        overlayColor: WidgetStatePropertyAll(Colors.black),
        thumbColor: Colors.white,
        value: _hueSliderValue,
      ),
    ],
  );

  Widget _buildSliderOpacity() => SizedBox(
    height: 30,
    child: Slider(
      onChanged: (v) => setState(() => _updateColor(_hueSliderValue, v)),
      overlayColor: WidgetStatePropertyAll(Colors.black),
      thumbColor: Colors.white,
      value: _opacitySliderValue,
    ),
  );

  void _updateColor(double hue, double opacity) => setState(() {
    _hueSliderValue = hue;
    _opacitySliderValue = opacity;
    _color = HSVColor.fromAHSV(opacity, hue * 360, 1.0, 1.0).toColor();
    if (widget.onChanged != null) {
      widget.onChanged!(_color);
    }
  });
}
