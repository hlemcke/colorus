import 'package:colorus/colorus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Entry point of example application
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
    home: const MyHomePage(),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.amber,
      fontFamily: 'Roboto',
      useMaterial3: true,
    ),
    theme: ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: Colors.amber,
      fontFamily: 'Roboto',
      useMaterial3: true,
    ),
    themeMode: ThemeMode.system,
  );
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buildAppBar(),
    body: SafeArea(minimum: const EdgeInsets.all(16), child: _buildBody()),
  );

  PreferredSizeWidget _buildAppBar() =>
      AppBar(title: const Text('Colorus - Color-Choosers'));

  Widget _buildBody() => ListView(
    shrinkWrap: true,
    children: [
      ListTile(leading: _buildAction4Color(), title: _buildColor()),
      ListTile(leading: _buildAction4HueSlider(), title: _buildHueSlider()),
      ListTile(leading: _buildAction4Ring(), title: _buildRing()),
      ListTile(leading: _buildAction4Wheel(), title: _buildWheel()),
      ListTile(leading: _buildAction4Grid(), title: _buildGrid()),
      ListTile(leading: _buildAction4RGBSlider(), title: _buildRGBSlider()),
    ],
  );

  Widget _buildAction4Color() => IconButton.outlined(
    icon: Icon(Icons.copy_outlined),
    onPressed: () {
      String hexColor = '0x${color.toARGB32().toRadixString(16)}';
      Clipboard.setData(ClipboardData(text: hexColor));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Color $hexColor copied to clipboard',
            overflow: TextOverflow.ellipsis,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    },
    tooltip: 'Copy color code to clipboard',
  );

  Widget _buildAction4Grid() => IconButton.outlined(
    icon: Icon(Icons.grid_4x4_outlined),
    onPressed: () => _showGrid(context, color),
    tooltip: 'Open grid chooser in dialog',
  );

  Widget _buildAction4HueSlider() => IconButton.outlined(
    icon: Icon(Icons.color_lens_outlined),
    onPressed: () => _showHueSlider(context, color),
    tooltip: 'Open Hue chooser in dialog',
  );

  Widget _buildAction4Ring() => IconButton.outlined(
    icon: Icon(Icons.lightbulb_circle_outlined),
    onPressed: () => _showRing(context, color).then((col) {
      if (col != null) setState(() => color = col);
    }),
    tooltip: 'Open ring chooser in dialog',
  );

  Widget _buildAction4RGBSlider() => IconButton.outlined(
    icon: Icon(Icons.menu_open_outlined),
    onPressed: () => _showRGBSlider(context, color),
    tooltip: 'Open RGB chooser in dialog',
  );

  Widget _buildAction4Wheel() => IconButton.outlined(
    icon: Icon(Icons.lightbulb_circle_outlined),
    onPressed: () => _showWheel(context, color).then((col) {
      if (col != null) setState(() => color = col);
    }),
    tooltip: 'Open wheel chooser in dialog',
  );

  Widget _buildColor() => LabeledFrame(
    label: Text('Selected Color - #${color.toARGB32().toRadixString(16)}'),
    child: Stack(
      children: [
        Align(alignment: .bottomCenter, child: Text('Background Text')),
        Container(color: color, height: kMinInteractiveDimension),
      ],
    ),
  );

  Widget _buildGrid() => LabeledFrame(
    label: Text('Grid'),
    child: ColorusGrid(
      color: color,
      onChanged: (col) => setState(() => color = col),
    ),
  );

  Widget _buildHueSlider() => LabeledFrame(
    label: Text('HUE Slider'),
    child: ColorusHueSlider(
      color: color,
      onChanged: (col) => setState(() => color = col),
    ),
  );

  Widget _buildRGBSlider() => LabeledFrame(
    label: Text('RGB Slider'),
    child: ColorusRGBSlider(
      color: color,
      onChanged: (col) => setState(() => color = col),
      showValues: true,
      withAlpha: true,
    ),
  );

  Widget _buildRing() => LabeledFrame(
    label: Text('Ring Chooser'),
    child: Center(
      child: SizedBox(
        height: 200,
        width: 250, // adjust width for AlphaSlider
        child: ColorusRing(
          color: color,
          onChanged: (col) => setState(() => color = col),
          alphaPosition: ColorusSliderPosition.right,
          showValue: true,
        ),
      ),
    ),
  );

  Widget _buildWheel() => LabeledFrame(
    label: Text('Wheel Chooser'),
    child: Center(
      child: SizedBox(
        height: 250,
        width: 250,
        child: ColorusWheel(
          color: color,
          onChanged: (col) => setState(() => color = col),
          alphaPosition: .right,
          showValue: true,
          togglePosition: .bottomLeft,
        ),
      ),
    ),
  );

  Future<Color?> _showGrid(BuildContext context, Color clr) =>
      showAdaptiveDialog<Color?>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Rainbow Grid'),
          content: ColorusGrid(
            color: clr,
            onChanged: (col) => setState(() => color = col),
          ),
        ),
      );

  Future<Color?> _showHueSlider(BuildContext context, Color clr) =>
      showAdaptiveDialog<Color?>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Hue Slider'),
          content: ColorusHueSlider(
            color: clr,
            onChanged: (col) => setState(() => color = col),
          ),
        ),
      );

  Future<Color?> _showRGBSlider(BuildContext context, Color clr) =>
      showAdaptiveDialog<Color?>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('RGB-Slider'),
          content: ColorusRGBSlider(
            color: clr,
            onChanged: (col) => setState(() => color = col),
          ),
        ),
      );

  Future<Color?> _showRing(BuildContext context, Color initialColor) async {
    Color dialogColor = initialColor;
    await showAdaptiveDialog<Color?>(
      context: context,
      builder: (BuildContext context) {
        ColorusSliderPosition alphaPosition = .none;
        bool showValue = false;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: _showTitle(context, 'Ring-Chooser'),
            content: SizedBox(
              width: 250,
              height: 250,
              child: ColorusRing(
                color: dialogColor,
                onChanged: (col) => setState(() => dialogColor = col),
                alphaPosition: alphaPosition,
                showValue: showValue,
              ),
            ),
          ),
        );
      },
    );
    return dialogColor;
  }

  Widget _showTitle(BuildContext context, String label) => AppBar(
    title: Text(label),
    actions: [
      IconButton(
        icon: Icon(Icons.cancel_outlined),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );

  Future<Color?> _showWheel(BuildContext context, Color initialColor) async {
    Color dialogColor = initialColor;
    ColorusSliderPosition sliderPosition = .none;
    ColorusTogglePosition togglePosition = .none;
    bool showValue = true;
    await showAdaptiveDialog<Color?>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: _showTitle(context, 'Wheel-Chooser'),
            content: SingleChildScrollView(
              child: Column(
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
                        color: dialogColor,
                        onChanged: (col) => setState(() => dialogColor = col),
                        alphaPosition: sliderPosition,
                        showValue: showValue,
                        togglePosition: togglePosition,
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
    return dialogColor;
  }
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
