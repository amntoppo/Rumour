import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

extension ContextX on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get safeInsets => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  AppTypography get typography => Theme.of(this).extension<AppTypography>()!;
}
