import 'package:colorus/colorus.dart';
import 'package:colorus/src/colorus_grid.dart';
import 'package:flutter/material.dart';

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
  Color color = Color.fromARGB(255, 0, 0, 255);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buildAppBar(),
    body: SafeArea(minimum: const EdgeInsets.all(16), child: _buildBody()),
  );

  PreferredSizeWidget _buildAppBar() =>
      AppBar(title: const Text('Colorus - Color-Choosers'));

  Widget _buildBody() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16.0,
    children: [_buildColor(), _buildHueSlider(), _buildRing(), _buildGrid()],
  );

  Widget _buildColor() => Frame(
    label: 'Selected Color - #${color.toARGB32().toRadixString(16)}',
    child: Container(color: color, height: kMinInteractiveDimension),
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

  Widget _buildRing() => Frame(
    label: 'Ring Chooser',
    child: SizedBox(height: 200, width: 200, child:
    ColorusRing(
      color: color,
      onChanged: (col) => setState(() => color = col),
    ),),
  );
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
