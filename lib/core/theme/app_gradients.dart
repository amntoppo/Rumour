import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppGradients {
  AppGradients._();

  static LinearGradient identityName(AppPalette palette) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [palette.identityGradientStart, palette.identityGradientEnd],
  );
}
