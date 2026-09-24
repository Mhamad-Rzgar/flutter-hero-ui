import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

String hex(Color c) =>
    '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

void main() {
  group('oklch', () {
    // Reference values computed with culori (CSS Color 4 conversion).
    const Map<List<double>, String> references = <List<double>, String>{
      <double>[0.6204, 0.195, 253.83]: '#0485f7',
      <double>[0.9702, 0, 0]: '#f5f5f5',
      <double>[0.2103, 0.0059, 285.89]: '#18181b',
      <double>[0.6532, 0.2328, 25.74]: '#ff383c',
      <double>[0.7329, 0.1935, 150.81]: '#17c964',
      <double>[0.7819, 0.1585, 72.33]: '#f5a524',
      <double>[0.12, 0.005, 285.823]: '#060607',
    };

    references.forEach((List<double> lch, String expected) {
      test('oklch(${lch.join(' ')}) is $expected', () {
        expect(hex(oklch(lch[0], lch[1], lch[2])), expected);
      });
    });

    test('round-trips through OKLab', () {
      final Color c = oklch(0.6204, 0.195, 253.83);
      final OkLch back = OkLab.fromColor(c).toOkLch();
      expect(back.l, closeTo(0.6204, 0.002));
      expect(back.c, closeTo(0.195, 0.003));
      expect(back.h, closeTo(253.83, 0.5));
    });
  });

  group('colorMix', () {
    const Color transparent = Color(0x00000000);

    test('mixing with transparent scales alpha only', () {
      final Color accent = oklch(0.6204, 0.195, 253.83);
      final Color soft = colorMix(accent, transparent, p1: 0.15, p2: 0.85);
      expect(soft.a, closeTo(0.15, 0.001));
      expect(soft.r, closeTo(accent.r, 0.002));
      expect(soft.g, closeTo(accent.g, 0.002));
      expect(soft.b, closeTo(accent.b, 0.002));
    });

    test('percentages summing below 100% scale the alpha', () {
      final Color mixed = colorMix(
        const Color(0xFFFFFFFF),
        const Color(0xFF000000),
        p1: 0.90,
        p2: 0.02,
      );
      expect(mixed.a, closeTo(0.92, 0.001));
    });

    test('percentages summing above 100% are normalised', () {
      final Color a = colorMix(
        const Color(0xFFFF0000),
        const Color(0xFF0000FF),
        p1: 0.7,
        p2: 0.4,
      );
      final Color b = colorMix(
        const Color(0xFFFF0000),
        const Color(0xFF0000FF),
        p1: 0.7 / 1.1,
        p2: 0.4 / 1.1,
      );
      expect(a.r, closeTo(b.r, 1e-6));
      expect(a.b, closeTo(b.b, 1e-6));
      expect(a.a, closeTo(1, 1e-6));
    });

    test('50/50 mix of black and white in oklab is mid lightness', () {
      final Color grey = colorMix(
        const Color(0xFFFFFFFF),
        const Color(0xFF000000),
      );
      expect(OkLab.fromColor(grey).l, closeTo(0.5, 0.002));
    });

    test('srgb mix interpolates channels linearly', () {
      final Color c = colorMix(
        const Color(0xFFFFFFFF),
        const Color(0xFF000000),
        space: ColorMixSpace.srgb,
      );
      expect(c.r, closeTo(0.5, 0.001));
    });

    test('relative lightness shift', () {
      final Color base = oklch(0.6, 0.1, 200);
      final OkLch shifted = OkLab.fromColor(
        shiftOkLchLightness(base, 0.12),
      ).toOkLch();
      expect(shifted.l, closeTo(0.72, 0.003));
    });

    test('contrast ratio of black on white is 21', () {
      expect(
        contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21, 0.01),
      );
    });
  });
}
