import 'package:colorus/src/colorus_commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Colorus Commons', () {
    //---
    test('Compute contrast ratios', () {
      //--- given
      List<_ColorsContrast> data = [
        _ColorsContrast(Colors.black, Colors.white, 21.0),
        _ColorsContrast(Colors.red, Colors.green, 1.3),
      ];

      //--- when / then
      for (int i = 0; i < data.length; i++) {
        _ColorsContrast c = data[i];
        double contrast = ColorusHelper.getContrastRatio(c.colorA, c.colorB);
        expect(contrast.toInt(), c.contrast.toInt());
      }
    });
  });
}

class _ColorsContrast {
  Color colorA, colorB;
  double contrast;

  _ColorsContrast(this.colorA, this.colorB, this.contrast);
}
