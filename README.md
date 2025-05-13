# colorus

Flutter Color Pickers

# Features

* Runs on all platforms
* Provides small and easy to use color pickers

# Getting started

Add the latest version of Colorus to the pubspc.yaml file:

```yaml
flutter:
  colorus: ^0.0.1
```

# Usage

Use `Colorus` like this:

```dart
ColorusHueSlider
(
color: color,
onChanged: (col) => setState(() => color = col),
),
```

For other examples see `example/main.dart`.