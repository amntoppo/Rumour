import 'package:flutter/material.dart';

/// Semantic colors exposed as a [ThemeExtension] — `context.palette.foo`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bgBase,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.inputBg,
    required this.divider,
    required this.accentPrimary,
    required this.onAccent,
    required this.identityGradientStart,
    required this.identityGradientEnd,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.statusOnline,
  });

  final Color bgBase;
  final Color surfaceCard;
  final Color surfaceElevated;
  final Color inputBg;
  final Color divider;
  final Color accentPrimary;
  final Color onAccent;

  // identity name gradient endpoints
  final Color identityGradientStart;
  final Color identityGradientEnd;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color statusOnline;

  static const AppPalette dark = AppPalette(
    bgBase: Color(0xFF09090B),
    surfaceCard: Color(0xFF18181B),
    surfaceElevated: Color(0xFF27272A),
    inputBg: Color(0xFF27272A),
    divider: Color(0xFF3F3F46),
    accentPrimary: Color(0xFFA3E635),
    onAccent: Color(0xFF000000),
    identityGradientStart: Color(0xFFFDE047),
    identityGradientEnd: Color(0xFFA3E635),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9CA3AF),
    textMuted: Color(0xFF6B7280),
    statusOnline: Color(0xFFA3E635),
  );

  static const AppPalette light = AppPalette(
    bgBase: Color(0xFFF8FAFC),
    surfaceCard: Color(0xFFE5EAF1),
    surfaceElevated: Color(0xFFE2E8F0),
    inputBg: Color(0xFFE8EEF5),
    divider: Color(0xFFCBD5E1),
    accentPrimary: Color(0xFF65A30D),
    onAccent: Color(0xFFFFFFFF),
    identityGradientStart: Color(0xFFF59E0B),
    identityGradientEnd: Color(0xFF65A30D),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    statusOnline: Color(0xFF65A30D),
  );

  @override
  AppPalette copyWith({
    Color? bgBase,
    Color? surfaceCard,
    Color? surfaceElevated,
    Color? inputBg,
    Color? divider,
    Color? accentPrimary,
    Color? onAccent,
    Color? identityGradientStart,
    Color? identityGradientEnd,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? statusOnline,
  }) {
    return AppPalette(
      bgBase: bgBase ?? this.bgBase,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      inputBg: inputBg ?? this.inputBg,
      divider: divider ?? this.divider,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      onAccent: onAccent ?? this.onAccent,
      identityGradientStart:
          identityGradientStart ?? this.identityGradientStart,
      identityGradientEnd: identityGradientEnd ?? this.identityGradientEnd,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      statusOnline: statusOnline ?? this.statusOnline,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      inputBg: Color.lerp(inputBg, other.inputBg, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      identityGradientStart: Color.lerp(
        identityGradientStart,
        other.identityGradientStart,
        t,
      )!,
      identityGradientEnd: Color.lerp(
        identityGradientEnd,
        other.identityGradientEnd,
        t,
      )!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      statusOnline: Color.lerp(statusOnline, other.statusOnline, t)!,
    );
  }
}
