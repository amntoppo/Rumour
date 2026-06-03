import 'package:flutter/material.dart';

/// Named text styles. Colors baked in for dark; light overrides them below.
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

  /// Gradient applied at the widget layer via ShaderMask.
  final TextStyle identityName;

  final TextStyle identityHelper;

  static const AppTypography dark = AppTypography(
    screenTitle: TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.5,
    ),
    screenSubtitle: TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.35,
    ),
    appBarTitle: TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    appBarSubtitle: TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),
    bodyLg: TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    body: TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    message: TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    messageMeta: TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),
    username: TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.2,
    ),
    dateSeparator: TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.2,
    ),
    inputText: TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    inputHint: TextStyle(
      color: Color(0xFF6B7280),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    buttonLabel: TextStyle(
      color: Color(0xFF000000),
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    identityCaption: TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    identityName: TextStyle(
      color: Color(0xFFFFFFFF), // overwritten by ShaderMask
      fontSize: 56,
      fontWeight: FontWeight.w800,
      height: 1.0,
      letterSpacing: -1.0,
    ),
    identityHelper: TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
  );

  static AppTypography light = AppTypography(
    screenTitle: dark.screenTitle.copyWith(color: const Color(0xFF0F172A)),
    screenSubtitle: dark.screenSubtitle.copyWith(
      color: const Color(0xFF475569),
    ),
    appBarTitle: dark.appBarTitle.copyWith(color: const Color(0xFF0F172A)),
    appBarSubtitle: dark.appBarSubtitle.copyWith(
      color: const Color(0xFF475569),
    ),
    bodyLg: dark.bodyLg.copyWith(color: const Color(0xFF0F172A)),
    body: dark.body.copyWith(color: const Color(0xFF0F172A)),
    message: dark.message.copyWith(color: const Color(0xFF0F172A)),
    messageMeta: dark.messageMeta.copyWith(color: const Color(0xFF64748B)),
    username: dark.username.copyWith(color: const Color(0xFF0F172A)),
    dateSeparator: dark.dateSeparator.copyWith(color: const Color(0xFF475569)),
    inputText: dark.inputText.copyWith(color: const Color(0xFF0F172A)),
    inputHint: dark.inputHint.copyWith(color: const Color(0xFF94A3B8)),
    buttonLabel: dark.buttonLabel.copyWith(color: const Color(0xFFFFFFFF)),
    identityCaption: dark.identityCaption.copyWith(
      color: const Color(0xFF475569),
    ),
    identityName: dark.identityName,
    identityHelper: dark.identityHelper.copyWith(
      color: const Color(0xFF475569),
    ),
  );

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
  }) {
    return AppTypography(
      screenTitle: screenTitle ?? this.screenTitle,
      screenSubtitle: screenSubtitle ?? this.screenSubtitle,
      appBarTitle: appBarTitle ?? this.appBarTitle,
      appBarSubtitle: appBarSubtitle ?? this.appBarSubtitle,
      bodyLg: bodyLg ?? this.bodyLg,
      body: body ?? this.body,
      message: message ?? this.message,
      messageMeta: messageMeta ?? this.messageMeta,
      username: username ?? this.username,
      dateSeparator: dateSeparator ?? this.dateSeparator,
      inputText: inputText ?? this.inputText,
      inputHint: inputHint ?? this.inputHint,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      identityCaption: identityCaption ?? this.identityCaption,
      identityName: identityName ?? this.identityName,
      identityHelper: identityHelper ?? this.identityHelper,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      screenTitle: TextStyle.lerp(screenTitle, other.screenTitle, t)!,
      screenSubtitle: TextStyle.lerp(screenSubtitle, other.screenSubtitle, t)!,
      appBarTitle: TextStyle.lerp(appBarTitle, other.appBarTitle, t)!,
      appBarSubtitle: TextStyle.lerp(appBarSubtitle, other.appBarSubtitle, t)!,
      bodyLg: TextStyle.lerp(bodyLg, other.bodyLg, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      message: TextStyle.lerp(message, other.message, t)!,
      messageMeta: TextStyle.lerp(messageMeta, other.messageMeta, t)!,
      username: TextStyle.lerp(username, other.username, t)!,
      dateSeparator: TextStyle.lerp(dateSeparator, other.dateSeparator, t)!,
      inputText: TextStyle.lerp(inputText, other.inputText, t)!,
      inputHint: TextStyle.lerp(inputHint, other.inputHint, t)!,
      buttonLabel: TextStyle.lerp(buttonLabel, other.buttonLabel, t)!,
      identityCaption: TextStyle.lerp(
        identityCaption,
        other.identityCaption,
        t,
      )!,
      identityName: TextStyle.lerp(identityName, other.identityName, t)!,
      identityHelper: TextStyle.lerp(identityHelper, other.identityHelper, t)!,
    );
  }
}
