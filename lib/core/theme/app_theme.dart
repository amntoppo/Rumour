import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(
        palette: AppPalette.dark,
        typography: AppTypography.dark,
        brightness: Brightness.dark,
        statusBarIcons: Brightness.light,
      );

  static ThemeData get light => _build(
        palette: AppPalette.light,
        typography: AppTypography.light,
        brightness: Brightness.light,
        statusBarIcons: Brightness.dark,
      );

  static ThemeData _build({
    required AppPalette palette,
    required AppTypography typography,
    required Brightness brightness,
    required Brightness statusBarIcons,
  }) {
    final base = brightness == Brightness.dark
        ? ColorScheme.dark(
            surface: palette.bgBase,
            primary: palette.accentPrimary,
            onPrimary: palette.onAccent,
            secondary: palette.accentPrimary,
            onSecondary: palette.onAccent,
            onSurface: palette.textPrimary,
          )
        : ColorScheme.light(
            surface: palette.bgBase,
            primary: palette.accentPrimary,
            onPrimary: palette.onAccent,
            secondary: palette.accentPrimary,
            onSecondary: palette.onAccent,
            onSurface: palette.textPrimary,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: base,
      scaffoldBackgroundColor: palette.bgBase,
      dividerColor: palette.divider,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: typography.appBarTitle,
        iconTheme: IconThemeData(color: palette.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusBarIcons,
          statusBarBrightness: brightness,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accentPrimary,
          foregroundColor: palette.onAccent,
          textStyle: typography.buttonLabel,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[palette, typography],
    );
  }
}
