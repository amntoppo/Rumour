import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark  => _build(AppPalette.dark,  AppTypography.dark,  Brightness.dark);
  static ThemeData get light => _build(AppPalette.light, AppTypography.light, Brightness.light);

  static ThemeData _build(
    AppPalette palette,
    AppTypography typography,
    Brightness brightness,
  ) => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: _colorScheme(palette, brightness),
    scaffoldBackgroundColor: palette.bgBase,
    dividerColor: palette.divider,
    appBarTheme: _appBarTheme(palette, typography, brightness),
    filledButtonTheme: _filledButtonTheme(palette, typography),
    extensions: <ThemeExtension<dynamic>>[palette, typography],
  );

  // ── Sub-builders ────────────────────────────────────────────────────────────

  static ColorScheme _colorScheme(AppPalette p, Brightness b) {
    final factory = b == Brightness.dark ? ColorScheme.dark : ColorScheme.light;
    return factory(
      surface:     p.bgBase,
      primary:     p.accentPrimary,
      onPrimary:   p.onAccent,
      secondary:   p.accentPrimary,
      onSecondary: p.onAccent,
      onSurface:   p.textPrimary,
    );
  }

  static AppBarTheme _appBarTheme(
    AppPalette p,
    AppTypography t,
    Brightness b,
  ) => AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
    titleTextStyle: t.appBarTitle,
    iconTheme: IconThemeData(color: p.textPrimary),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: b == Brightness.dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: b,
    ),
  );

  static FilledButtonThemeData _filledButtonTheme(
    AppPalette p,
    AppTypography t,
  ) => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: p.accentPrimary,
      foregroundColor: p.onAccent,
      textStyle: t.buttonLabel,
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
