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

  Widget _buildColor() => Frame(
    label: 'Selected Color - #${color.toARGB32().toRadixString(16)}',
    child: Stack(
      children: [
        Align(alignment: .bottomCenter, child: Text('Background Text')),
        Container(color: color, height: kMinInteractiveDimension),
      ],
    ),
  );

  Widget _buildGrid() => Frame(
    label: 'Grid',
    child: ColorusGrid(
      color: color,
      onChanged: (col) => setState(() => color = col),
    ),
  );

  Widget _buildHueSlider() => Frame(
    label: 'HUE Slider',
    child: ColorusHueSlider(
      color: color,
      onChanged: (col) => setState(() => color = col),
    ),
  );

  Widget _buildRGBSlider() => Frame(
    label: 'RGB Slider',
    child: ColorusRGBSlider(
      color: color,
      onChanged: (col) => setState(() => color = col),
      showValues: true,
      withAlpha: true,
    ),
  );

  Widget _buildRing() => Frame(
    label: 'Ring Chooser',
    child: Center(
      child: SizedBox(
        height: 200,
        width: 250, // adjust width for AlphaSlider
        child: ColorusRing(
          color: color,
          onChanged: (col) => setState(() => color = col),
          alphaPosition: ColorusPosition.right,
          showValue: true,
        ),
      ),
    ),
  );

  Widget _buildWheel() => Frame(
    label: 'Wheel Chooser',
    child: SizedBox(
      height: 200,
      width: 200,
      child: ColorusWheelWithToggle(
        color: color,
        onChanged: (col) => setState(() => color = col),
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
        return AlertDialog(
          title: _showTitle(context, 'Ring-Chooser'),
          content: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 250,
              height: 200,
              child: ColorusRing(
                color: dialogColor,
                onChanged: (col) => setState(() => dialogColor = col),
                alphaPosition: .right,
                showValue: true,
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
    await showAdaptiveDialog<Color?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: _showTitle(context, 'Wheel-Chooser'),
          content: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 200,
              height: 200,
              child: ColorusWheelWithToggle(
                color: dialogColor,
                onChanged: (col) => setState(() => dialogColor = col),
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
/// Frame with label
///
class Frame extends StatelessWidget {
  final Widget child;
  final String label;

  const Frame({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      labelText: label,
    ),
    child: child,
  );
}
