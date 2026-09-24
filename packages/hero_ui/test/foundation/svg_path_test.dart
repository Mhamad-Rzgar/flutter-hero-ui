import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

void main() {
  test('parses absolute and relative commands', () {
    final Path path = parseSvgPathData('M2 2h12v12H2z');
    expect(path.getBounds(), const Rect.fromLTRB(2, 2, 14, 14));
  });

  test('parses compact numbers and packed arc flags', () {
    final Path path = parseSvgPathData(
      'M2.97 5.47a.75.75 0 0 1 1.06 0L8 9.44l3.97-3.97a.75.75 0 1 1 1.06 1.06l-4.5 4.5a.75.75 0 0 1-1.06 0l-4.5-4.5a.75.75 0 0 1 0-1.06',
    );
    // Points on the chevron's stroke are inside; the notch above it is not.
    expect(path.contains(const Offset(8, 10.2)), isTrue);
    expect(path.contains(const Offset(3.5, 6)), isTrue);
    expect(path.contains(const Offset(8, 7)), isFalse);
    expect(path.getBounds().right, lessThan(14));
  });

  test('handles smooth curves and implicit linetos', () {
    final Path path = parseSvgPathData(
      'M0 0 10 0 10 10C12 12 14 14 16 16S20 20 22 22Q24 24 26 26T30 30',
    );
    expect(path.getBounds().right, closeTo(30, 0.01));
  });

  test('supports exponents and arc with zero radius', () {
    final Path path = parseSvgPathData('M0 0L1e1 0A0 0 0 0 1 10 10');
    expect(path.getBounds(), const Rect.fromLTRB(0, 0, 10, 10));
  });

  test('every bundled icon parses and fits its view box', () {
    for (final HeroIconData icon in <HeroIconData>[
      HeroIcons.chevronDown,
      HeroIcons.close,
      HeroIcons.info,
      HeroIcons.calendarPicker,
      HeroIcons.externalLink,
      HeroIcons.bell,
      HeroIcons.gear,
      HeroIcons.magnifier,
    ]) {
      for (final Path p in icon.parsedPaths) {
        final Rect b = p.getBounds();
        expect(b.left, greaterThanOrEqualTo(-2));
        expect(b.right, lessThanOrEqualTo(icon.viewBoxWidth + 2));
      }
    }
  });
}
