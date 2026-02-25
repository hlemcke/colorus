import 'dart:math';

import 'package:flutter/material.dart';

///
/// OKLab color
///
class OKLabColor {
  final double L;
  final double a;
  final double b;

  OKLabColor({required this.L, required this.a, required this.b});

  ///
  /// Computes the OKLab color from RGB (alpha is unused)
  ///
  factory OKLabColor.fromColor({required Color color}) {
    //--- 1) linearize RGB
    double R = _rgbToLinear(color.r);
    double G = _rgbToLinear(color.g);
    double B = _rgbToLinear(color.b);

    //--- 2) Linear RGB → LMS
    final l = 0.4122214708 * R + 0.5363325363 * G + 0.0514459929 * B;
    final m = 0.2119034982 * R + 0.6806995451 * G + 0.1073969566 * B;
    final s = 0.0883024619 * R + 0.2817188376 * G + 0.6299787005 * B;

    //--- 3) Cube roots
    final l_ = pow(l, 1.0 / 3.0).toDouble();
    final m_ = pow(m, 1.0 / 3.0).toDouble();
    final s_ = pow(s, 1.0 / 3.0).toDouble();

    //--- 4) LMS → OKLab
    final labL = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_;
    final labA = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_;
    final labB = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_;

    return OKLabColor(L: labL, a: labA, b: labB);
  }

  ///
  /// Interpolate between two colors using lerp-factor.
  ///
  /// * `t == 0` -> c1
  /// * `t == 1` -> c2
  ///
  OKLabColor interpolate(OKLabColor c2, double t) => OKLabColor(
    L: L + (c2.L - L) * t,
    a: a + (c2.a - a) * t,
    b: b + (c2.b - b) * t,
  );

  ///
  /// Computes Flutter standard [Color] from this [OKLabColor]. Sets alpha
  /// channel to its maximum value.
  ///
  Color toColor() {
    // 1) OKLab → LMS'
    final l_ = L + 0.3963377774 * a + 0.2158037573 * b;
    final m_ = L - 0.1055613458 * a - 0.0638541728 * b;
    final s_ = L - 0.0894841775 * a - 1.2914855480 * b;
    // 2) Kubik
    final l = l_ * l_ * l_;
    final m = m_ * m_ * m_;
    final s = s_ * s_ * s_;
    // 3) LMS → lineares RGB
    final R = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
    final G = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
    final B = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

    // 4) lineares RGB → sRGB (double 0.0–1.0)
    double toSrgb(double c) {
      return c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1.0 / 2.4) - 0.055;
    }

    final r = toSrgb(R).clamp(0.0, 1.0);
    final g = toSrgb(G).clamp(0.0, 1.0);
    final b2 = toSrgb(B).clamp(0.0, 1.0);
    return Color.from(red: r, green: g, blue: b2, alpha: 1.0);
  }

  static double _rgbToLinear(double c) {
    return (c <= 0.04045)
        ? c / 12.92
        : pow((c + 0.055) / 1.055, 2.4).toDouble();
  }
}
