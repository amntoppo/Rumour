import 'package:flutter/material.dart';

// ─── Raw colour tokens ─────────────────────────────────────────────────────────
// Organised by hue family so it's trivial to swap a family without touching
// the semantic layer below.

abstract final class _Zinc {
  static const c950 = Color(0xFF09090B);
  static const c900 = Color(0xFF18181B);
  static const c800 = Color(0xFF27272A);
  static const c700 = Color(0xFF3F3F46);
}

abstract final class _Slate {
  static const c50  = Color(0xFFF8FAFC);
  static const c100 = Color(0xFFE5EAF1);
  static const c200 = Color(0xFFE2E8F0);
  static const c250 = Color(0xFFE8EEF5);
  static const c300 = Color(0xFFCBD5E1);
  static const c400 = Color(0xFF94A3B8);
  static const c500 = Color(0xFF64748B);
  static const c600 = Color(0xFF475569);
  static const c900 = Color(0xFF0F172A);
}

abstract final class _Lime {
  static const c400 = Color(0xFFA3E635);
  static const c700 = Color(0xFF65A30D);
}

abstract final class _Amber {
  static const c300 = Color(0xFFFDE047);
  static const c500 = Color(0xFFF59E0B);
}

abstract final class _Mono {
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}

// ─── Semantic palette ─────────────────────────────────────────────────────────

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette._({
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
    required this.keyIconBg,
  });

  final Color bgBase;
  final Color surfaceCard;
  final Color surfaceElevated;
  final Color inputBg;
  final Color divider;
  final Color accentPrimary;
  final Color onAccent;
  final Color identityGradientStart;
  final Color identityGradientEnd;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color statusOnline;
  final Color keyIconBg;

  // ── Named instances ──────────────────────────────────────────────────────────

  static const AppPalette dark = AppPalette._(
    bgBase:                _Zinc.c950,
    surfaceCard:           _Zinc.c900,
    surfaceElevated:       _Zinc.c800,
    inputBg:               _Zinc.c800,
    divider:               _Zinc.c700,
    accentPrimary:         _Lime.c400,
    onAccent:              _Mono.black,
    identityGradientStart: _Amber.c300,
    identityGradientEnd:   _Lime.c400,
    textPrimary:           _Mono.white,
    textSecondary:         Color(0xFF9CA3AF),
    textMuted:             Color(0xFF6B7280),
    statusOnline:          _Lime.c400,
    keyIconBg:             _Zinc.c800,
  );

  static const AppPalette light = AppPalette._(
    bgBase:                _Slate.c50,
    surfaceCard:           _Slate.c100,
    surfaceElevated:       _Slate.c200,
    inputBg:               _Slate.c250,
    divider:               _Slate.c300,
    accentPrimary:         _Lime.c700,
    onAccent:              _Mono.white,
    identityGradientStart: _Amber.c500,
    identityGradientEnd:   _Lime.c700,
    textPrimary:           _Slate.c900,
    textSecondary:         _Slate.c600,
    textMuted:             _Slate.c400,
    statusOnline:          _Lime.c700,
    keyIconBg:             Color(0x80E2E8F0),
  );

  // ── ThemeExtension boilerplate ───────────────────────────────────────────────

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
    Color? keyIconBg,
  }) => AppPalette._(
    bgBase:                bgBase                ?? this.bgBase,
    surfaceCard:           surfaceCard           ?? this.surfaceCard,
    surfaceElevated:       surfaceElevated       ?? this.surfaceElevated,
    inputBg:               inputBg               ?? this.inputBg,
    divider:               divider               ?? this.divider,
    accentPrimary:         accentPrimary         ?? this.accentPrimary,
    onAccent:              onAccent              ?? this.onAccent,
    identityGradientStart: identityGradientStart ?? this.identityGradientStart,
    identityGradientEnd:   identityGradientEnd   ?? this.identityGradientEnd,
    textPrimary:           textPrimary           ?? this.textPrimary,
    textSecondary:         textSecondary         ?? this.textSecondary,
    textMuted:             textMuted             ?? this.textMuted,
    statusOnline:          statusOnline          ?? this.statusOnline,
    keyIconBg:             keyIconBg             ?? this.keyIconBg,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette._(
      bgBase:                c(bgBase,                other.bgBase),
      surfaceCard:           c(surfaceCard,           other.surfaceCard),
      surfaceElevated:       c(surfaceElevated,       other.surfaceElevated),
      inputBg:               c(inputBg,               other.inputBg),
      divider:               c(divider,               other.divider),
      accentPrimary:         c(accentPrimary,         other.accentPrimary),
      onAccent:              c(onAccent,              other.onAccent),
      identityGradientStart: c(identityGradientStart, other.identityGradientStart),
      identityGradientEnd:   c(identityGradientEnd,   other.identityGradientEnd),
      textPrimary:           c(textPrimary,           other.textPrimary),
      textSecondary:         c(textSecondary,         other.textSecondary),
      textMuted:             c(textMuted,             other.textMuted),
      statusOnline:          c(statusOnline,          other.statusOnline),
      keyIconBg:             c(keyIconBg,             other.keyIconBg),
    );
  }
}
