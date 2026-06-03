import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppGradients {
  /// Diagonal gradient used behind the identity name reveal.
  static LinearGradient identityName(AppPalette p) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [p.identityGradientStart, p.identityGradientEnd],
  );
}
