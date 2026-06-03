import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/theme/app_palette.dart';

void main() {
  group('AppPalette.dark', () {
    const dark = AppPalette.dark;

    test('bgBase is Zinc-950 (#09090B)', () {
      expect(dark.bgBase, const Color(0xFF09090B));
    });

    test('accentPrimary is Lime-400 (#A3E635)', () {
      expect(dark.accentPrimary, const Color(0xFFA3E635));
    });

    test('textPrimary is white', () {
      expect(dark.textPrimary, const Color(0xFFFFFFFF));
    });

    test('onAccent is black', () {
      expect(dark.onAccent, const Color(0xFF000000));
    });

    test('keyIconBg is Zinc-800 (#27272A)', () {
      expect(dark.keyIconBg, const Color(0xFF27272A));
    });
  });

  group('AppPalette.light', () {
    const light = AppPalette.light;

    test('bgBase is Slate-50 (#F8FAFC)', () {
      expect(light.bgBase, const Color(0xFFF8FAFC));
    });

    test('accentPrimary is Lime-700 (#65A30D)', () {
      expect(light.accentPrimary, const Color(0xFF65A30D));
    });

    test('textPrimary is Slate-900', () {
      expect(light.textPrimary, const Color(0xFF0F172A));
    });

    test('keyIconBg is Slate-200 with 50% opacity (#80E2E8F0)', () {
      expect(light.keyIconBg, const Color(0x80E2E8F0));
    });
  });

  group('AppPalette.copyWith', () {
    test('overrides only the specified field', () {
      const overrideColor = Color(0xFFFF0000);
      final modified = AppPalette.dark.copyWith(bgBase: overrideColor);

      expect(modified.bgBase, overrideColor);
      // All other fields remain unchanged
      expect(modified.accentPrimary, AppPalette.dark.accentPrimary);
      expect(modified.textPrimary, AppPalette.dark.textPrimary);
      expect(modified.surfaceCard, AppPalette.dark.surfaceCard);
      expect(modified.keyIconBg, AppPalette.dark.keyIconBg);
    });

    test('with no arguments returns an equal palette', () {
      final copy = AppPalette.dark.copyWith();
      expect(copy.bgBase, AppPalette.dark.bgBase);
      expect(copy.accentPrimary, AppPalette.dark.accentPrimary);
      expect(copy.keyIconBg, AppPalette.dark.keyIconBg);
    });
  });

  group('AppPalette.lerp', () {
    test('at t=0 returns the start palette', () {
      final result = AppPalette.dark.lerp(AppPalette.light, 0.0);
      expect(result.bgBase, AppPalette.dark.bgBase);
    });

    test('at t=1 returns the end palette', () {
      final result = AppPalette.dark.lerp(AppPalette.light, 1.0);
      expect(result.bgBase, AppPalette.light.bgBase);
    });

    test('returns this when other is not AppPalette', () {
      final result = AppPalette.dark.lerp(null, 0.5);
      expect(result.bgBase, AppPalette.dark.bgBase);
    });

    test('interpolates at t=0.5', () {
      final result = AppPalette.dark.lerp(AppPalette.light, 0.5);
      final expected = Color.lerp(AppPalette.dark.bgBase, AppPalette.light.bgBase, 0.5)!;
      expect(result.bgBase, expected);
    });
  });
}
