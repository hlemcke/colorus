import 'package:colorus/colorus.dart';
import 'package:flutter/material.dart';

/// Entry point of example application
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) =>
      MaterialApp(home: const MyHomePage(), themeMode: ThemeMode.system);
}

///
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Displayed and selected color
  Color color = Colors.deepOrange;
  ColorusSliderPosition sliderPosition = .none;
  ColorusTogglePosition togglePosition = .none;
  bool showValue = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buildAppBar(),
    body: SafeArea(minimum: const EdgeInsets.all(16), child: _buildWheel()),
  );

  PreferredSizeWidget _buildAppBar() =>
      AppBar(title: const Text('Colorus - Color-Choosers'));

  Widget _buildWheel() => Column(
    children: [
      Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          AlphaPositioner(
            onChanged: (v) => setState(() => sliderPosition = v),
            value: sliderPosition,
          ),
          TogglePositioner(
            onChanged: (v) => setState(() => togglePosition = v),
            value: togglePosition,
          ),
        ],
      ),
      SizedBox(height: 24),
      LabeledFrame(
        label: Text('Wheel'),
        child: SizedBox(
          width: 300,
          height: 300,
          child: ColorusWheel(
            color: color,
            onChanged: (col) => setState(() => color = col),
            alphaPosition: sliderPosition,
            showValue: showValue,
            togglePosition: togglePosition,
          ),
        ),
      ),
    ],
  );
}

///
class AlphaPositioner extends StatelessWidget {
  final ValueChanged<ColorusSliderPosition> onChanged;
  final ColorusSliderPosition value;

  const AlphaPositioner({
    super.key,
    required this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => DropdownMenu<ColorusSliderPosition>(
    initialSelection: value,
    label: Text('Alpha-Position'),
    onSelected: (v) => onChanged(v!),
    dropdownMenuEntries: [
      for (ColorusSliderPosition pos in ColorusSliderPosition.values)
        DropdownMenuEntry(value: pos, label: pos.name),
    ],
  );
}

///
class TogglePositioner extends StatelessWidget {
  final ValueChanged<ColorusTogglePosition> onChanged;
  final ColorusTogglePosition value;

  const TogglePositioner({
    super.key,
    required this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => DropdownMenu<ColorusTogglePosition>(
    initialSelection: value,
    label: Text('Toggle-Position'),
    onSelected: (v) => onChanged(v!),
    dropdownMenuEntries: [
      for (ColorusTogglePosition pos in ColorusTogglePosition.values)
        DropdownMenuEntry(value: pos, label: pos.name),
    ],
  );
}

///
/// Frame with label
///
///
/// A rounded frame around a [child] with an optional [label]
///
class LabeledFrame extends StatelessWidget {
  final Widget child;
  final Widget? label;
  final Color? labelColor;
  final bool labelFrame;
  final EdgeInsetsGeometry padding;

  const LabeledFrame({
    super.key,
    this.label,
    this.labelColor,
    this.labelFrame = false,
    this.padding = const EdgeInsets.all(20),
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Stack(
    // --- allow the label to be placed outside the bounds
    clipBehavior: Clip.none,
    children: [
      Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: child,
      ),
      if (label != null)
        Positioned(
          top: -10.0,
          left: 10.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: labelColor ?? Theme.of(context).colorScheme.surface,
            ),
            child: label,
          ),
        ),
    ],
  );
}
