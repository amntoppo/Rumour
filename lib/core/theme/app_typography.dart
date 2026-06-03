import 'package:flutter/material.dart';

// ─── Type scale constants ──────────────────────────────────────────────────────

abstract final class _Sp {
  static const double xs  = 11;
  static const double sm  = 12;
  static const double md  = 13;
  static const double base = 14;
  static const double lg  = 16;
  static const double xl  = 17;
  static const double h1  = 32;
  static const double hero = 56;
}

abstract final class _Lh {
  static const double tight   = 1.0;
  static const double snug    = 1.2;
  static const double normal  = 1.35;
  static const double relaxed = 1.4;
}

abstract final class _Fw {
  static const w4 = FontWeight.w400;
  static const w5 = FontWeight.w500;
  static const w6 = FontWeight.w600;
  static const w8 = FontWeight.w800;
}

// ─── Helper ───────────────────────────────────────────────────────────────────

TextStyle _ts({
  required Color color,
  required double size,
  required FontWeight weight,
  double? height,
  double? spacing,
}) => TextStyle(
  color: color,
  fontSize: size,
  fontWeight: weight,
  height: height,
  letterSpacing: spacing,
);

// ─── Palette colour shortcuts used only by typography ─────────────────────────

const _white  = Color(0xFFFFFFFF);
const _black  = Color(0xFF000000);
const _grey   = Color(0xFF9CA3AF); // textSecondary (dark)
const _muted  = Color(0xFF6B7280); // textMuted (dark)

const _inkDark    = Color(0xFF0F172A); // textPrimary (light)
const _subLight   = Color(0xFF475569); // textSecondary (light)
const _mutedLight = Color(0xFF94A3B8); // textMuted (light)
const _metaLight  = Color(0xFF64748B);

// ─── ThemeExtension ──────────────────────────────────────────────────────────

@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.screenTitle,
    required this.screenSubtitle,
    required this.appBarTitle,
    required this.appBarSubtitle,
    required this.bodyLg,
    required this.body,
    required this.message,
    required this.messageMeta,
    required this.username,
    required this.dateSeparator,
    required this.inputText,
    required this.inputHint,
    required this.buttonLabel,
    required this.identityCaption,
    required this.identityName,
    required this.identityHelper,
  });

  final TextStyle screenTitle;
  final TextStyle screenSubtitle;
  final TextStyle appBarTitle;
  final TextStyle appBarSubtitle;
  final TextStyle bodyLg;
  final TextStyle body;
  final TextStyle message;
  final TextStyle messageMeta;
  final TextStyle username;
  final TextStyle dateSeparator;
  final TextStyle inputText;
  final TextStyle inputHint;
  final TextStyle buttonLabel;
  final TextStyle identityCaption;

  /// Overwritten at widget level by ShaderMask for gradient rendering.
  final TextStyle identityName;
  final TextStyle identityHelper;

  // ── Dark ──────────────────────────────────────────────────────────────────

  static final AppTypography dark = AppTypography(
    screenTitle:     _ts(color: _white, size: _Sp.h1,   weight: _Fw.w8, height: 1.15, spacing: -0.5),
    screenSubtitle:  _ts(color: _grey,  size: _Sp.base, weight: _Fw.w4, height: _Lh.normal),
    appBarTitle:     _ts(color: _white, size: _Sp.xl,   weight: _Fw.w6, height: _Lh.snug),
    appBarSubtitle:  _ts(color: _grey,  size: _Sp.md,   weight: _Fw.w4, height: _Lh.snug),
    bodyLg:          _ts(color: _white, size: _Sp.lg,   weight: _Fw.w4, height: _Lh.relaxed),
    body:            _ts(color: _white, size: _Sp.base, weight: _Fw.w4, height: _Lh.relaxed),
    message:         _ts(color: _white, size: _Sp.base, weight: _Fw.w4, height: _Lh.relaxed),
    messageMeta:     _ts(color: _grey,  size: _Sp.xs,   weight: _Fw.w4, height: _Lh.snug),
    username:        _ts(color: _white, size: _Sp.md,   weight: _Fw.w5, height: _Lh.snug),
    dateSeparator:   _ts(color: _grey,  size: _Sp.sm,   weight: _Fw.w5, height: _Lh.snug),
    inputText:       _ts(color: _white, size: _Sp.base, weight: _Fw.w4),
    inputHint:       _ts(color: _muted, size: _Sp.base, weight: _Fw.w4),
    buttonLabel:     _ts(color: _black, size: _Sp.lg,   weight: _Fw.w6, height: _Lh.snug),
    identityCaption: _ts(color: _grey,  size: _Sp.md,   weight: _Fw.w4, height: 1.3),
    identityName:    _ts(color: _white, size: _Sp.hero, weight: _Fw.w8, height: _Lh.tight, spacing: -1.0),
    identityHelper:  _ts(color: _grey,  size: _Sp.md,   weight: _Fw.w4, height: _Lh.relaxed),
  );

  // ── Light (inherits structure, overrides colours) ─────────────────────────

  static AppTypography light = AppTypography(
    screenTitle:     dark.screenTitle.copyWith(color: _inkDark),
    screenSubtitle:  dark.screenSubtitle.copyWith(color: _subLight),
    appBarTitle:     dark.appBarTitle.copyWith(color: _inkDark),
    appBarSubtitle:  dark.appBarSubtitle.copyWith(color: _subLight),
    bodyLg:          dark.bodyLg.copyWith(color: _inkDark),
    body:            dark.body.copyWith(color: _inkDark),
    message:         dark.message.copyWith(color: _inkDark),
    messageMeta:     dark.messageMeta.copyWith(color: _metaLight),
    username:        dark.username.copyWith(color: _inkDark),
    dateSeparator:   dark.dateSeparator.copyWith(color: _subLight),
    inputText:       dark.inputText.copyWith(color: _inkDark),
    inputHint:       dark.inputHint.copyWith(color: _mutedLight),
    buttonLabel:     dark.buttonLabel.copyWith(color: _white),
    identityCaption: dark.identityCaption.copyWith(color: _subLight),
    identityName:    dark.identityName,
    identityHelper:  dark.identityHelper.copyWith(color: _subLight),
  );

  // ── ThemeExtension boilerplate ────────────────────────────────────────────

  @override
  AppTypography copyWith({
    TextStyle? screenTitle,
    TextStyle? screenSubtitle,
    TextStyle? appBarTitle,
    TextStyle? appBarSubtitle,
    TextStyle? bodyLg,
    TextStyle? body,
    TextStyle? message,
    TextStyle? messageMeta,
    TextStyle? username,
    TextStyle? dateSeparator,
    TextStyle? inputText,
    TextStyle? inputHint,
    TextStyle? buttonLabel,
    TextStyle? identityCaption,
    TextStyle? identityName,
    TextStyle? identityHelper,
  }) => AppTypography(
    screenTitle:     screenTitle     ?? this.screenTitle,
    screenSubtitle:  screenSubtitle  ?? this.screenSubtitle,
    appBarTitle:     appBarTitle     ?? this.appBarTitle,
    appBarSubtitle:  appBarSubtitle  ?? this.appBarSubtitle,
    bodyLg:          bodyLg          ?? this.bodyLg,
    body:            body            ?? this.body,
    message:         message         ?? this.message,
    messageMeta:     messageMeta     ?? this.messageMeta,
    username:        username        ?? this.username,
    dateSeparator:   dateSeparator   ?? this.dateSeparator,
    inputText:       inputText       ?? this.inputText,
    inputHint:       inputHint       ?? this.inputHint,
    buttonLabel:     buttonLabel     ?? this.buttonLabel,
    identityCaption: identityCaption ?? this.identityCaption,
    identityName:    identityName    ?? this.identityName,
    identityHelper:  identityHelper  ?? this.identityHelper,
  );

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return AppTypography(
      screenTitle:     l(screenTitle,     other.screenTitle),
      screenSubtitle:  l(screenSubtitle,  other.screenSubtitle),
      appBarTitle:     l(appBarTitle,     other.appBarTitle),
      appBarSubtitle:  l(appBarSubtitle,  other.appBarSubtitle),
      bodyLg:          l(bodyLg,          other.bodyLg),
      body:            l(body,            other.body),
      message:         l(message,         other.message),
      messageMeta:     l(messageMeta,     other.messageMeta),
      username:        l(username,        other.username),
      dateSeparator:   l(dateSeparator,   other.dateSeparator),
      inputText:       l(inputText,       other.inputText),
      inputHint:       l(inputHint,       other.inputHint),
      buttonLabel:     l(buttonLabel,     other.buttonLabel),
      identityCaption: l(identityCaption, other.identityCaption),
      identityName:    l(identityName,    other.identityName),
      identityHelper:  l(identityHelper,  other.identityHelper),
    );
  }
}
