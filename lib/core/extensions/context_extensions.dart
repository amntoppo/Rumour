import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

extension ContextX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  AppTypography get typography => Theme.of(this).extension<AppTypography>()!;
}
