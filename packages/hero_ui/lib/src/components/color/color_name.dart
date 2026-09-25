import 'dart:math' as math;
import 'dart:ui' show Color;

import '../../foundation/foundation.dart';

// OKLCH hue anchors of React Aria's `Color.getColorName`.
const List<(double, String)> _hues = <(double, String)>[
  (0, 'pink'),
  (15, 'red'),
  (48, 'orange'),
  (94, 'yellow'),
  (135, 'green'),
  (175, 'cyan'),
  (264, 'blue'),
  (284, 'purple'),
  (320, 'magenta'),
  (349, 'pink'),
];

/// A readable English name of [color] for screen readers, such as
/// "vibrant red", "dark blue", "light gray" or "white" (React Aria's
/// `Color.getColorName`).
///
/// Like React Aria the name is derived in the perceptually uniform OKLCH
/// space: the hue picks the base name (dark oranges are "brown"), the
/// chroma adds "grayish" or "vibrant" and the lightness adds "very dark",
/// "dark", "light" or "very light". A fully transparent color is
/// "transparent"; a translucent one appends the transparency
/// ("red, 50% transparent").
String heroColorName(Color color) {
  if (color.a <= 0) return 'transparent';
  final OkLch lch = OkLab.fromColor(color.withValues(alpha: 1)).toOkLch();
  String name = _opaqueName(lch.l, lch.c, lch.h);
  if (color.a < 1) {
    final int transparent = ((1 - color.a) * 100).round();
    if (transparent > 0) name = '$name, $transparent% transparent';
  }
  return name;
}

String _opaqueName(double l, double c, double h) {
  if (l > 0.999) return 'white';
  if (l < 0.001) return 'black';

  String hue;
  if (c < 0.02) {
    hue = 'gray';
  } else {
    // The name of the nearest hue anchor: past the halfway point between two
    // anchors a hue takes the next name, as in React Aria.
    hue = _hues.first.$2;
    double best = double.infinity;
    for (final (double anchor, String name) in _hues) {
      final double distance = math.min(
        (h - anchor).abs(),
        360 - (h - anchor).abs(),
      );
      if (distance < best) {
        best = distance;
        hue = name;
      }
    }
    // Dark oranges and yellows read as brown.
    if ((hue == 'orange' || hue == 'yellow') && l < 0.55) hue = 'brown';
  }

  final String chroma = hue == 'gray'
      ? ''
      : c < 0.07
      ? 'grayish'
      : c >= 0.2
      ? 'vibrant'
      : '';

  final String lightness = l < 0.3
      ? 'very dark'
      : l < 0.55
      ? 'dark'
      : l < 0.7
      ? ''
      : l < 0.85
      ? 'light'
      : 'very light';

  return <String>[
    lightness,
    chroma,
    hue,
  ].where((String part) => part.isNotEmpty).join(' ');
}
