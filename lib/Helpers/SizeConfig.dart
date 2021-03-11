import 'dart:math';

import 'package:flutter/widgets.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double _screenWidth;
  static double _screenHeight;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;
  static double diagonal;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (_screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (_screenHeight - _safeAreaVertical) / 100;
    diagonal = sqrt((safeBlockHorizontal * safeBlockHorizontal) +
        (safeBlockVertical * safeBlockVertical));
  }
}
