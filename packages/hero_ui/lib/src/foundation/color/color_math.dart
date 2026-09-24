import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

/// A color in the OKLab perceptual color space.
///
/// HeroUI declares every design token in OKLCH and derives hover, soft and
/// border shades with `color-mix(in oklab, ...)`. [OkLab] and [OkLch] let the
/// Flutter port evaluate the exact same expressions and convert the result to
/// sRGB for painting.
@immutable
class OkLab {
  /// Creates an OKLab color. [l] is lightness in `0..1`.
  const OkLab(this.l, this.a, this.b, [this.alpha = 1.0]);

  /// Lightness, `0..1`.
  final double l;

  /// Green–red axis.
  final double a;

  /// Blue–yellow axis.
  final double b;

  /// Opacity, `0..1`.
  final double alpha;

  /// Converts an sRGB [Color] into OKLab.
  factory OkLab.fromColor(Color color) {
    final double r = _toLinear(color.r);
    final double g = _toLinear(color.g);
    final double bl = _toLinear(color.b);
    final double l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * bl;
    final double m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * bl;
    final double s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * bl;
    final double l3 = _cbrt(l);
    final double m3 = _cbrt(m);
    final double s3 = _cbrt(s);
    return OkLab(
      0.2104542553 * l3 + 0.7936177850 * m3 - 0.0040720468 * s3,
      1.9779984951 * l3 - 2.4285922050 * m3 + 0.4505937099 * s3,
      0.0259040371 * l3 + 0.7827717662 * m3 - 0.8086757660 * s3,
      color.a,
    );
  }

  /// Converts to an sRGB [Color], clipping out-of-gamut channels the way
  /// browsers do when painting to an sRGB surface.
  Color toColor() {
    final double l3 = l + 0.3963377774 * a + 0.2158037573 * b;
    final double m3 = l - 0.1055613458 * a - 0.0638541728 * b;
    final double s3 = l - 0.0894841775 * a - 1.2914855480 * b;
    final double lc = l3 * l3 * l3;
    final double mc = m3 * m3 * m3;
    final double sc = s3 * s3 * s3;
    final double r = 4.0767416621 * lc - 3.3077115913 * mc + 0.2309699292 * sc;
    final double g = -1.2684380046 * lc + 2.6097574011 * mc - 0.3413193965 * sc;
    final double bl =
        -0.0041960863 * lc - 0.7034186147 * mc + 1.7076147010 * sc;
    return Color.from(
      alpha: alpha.clamp(0.0, 1.0),
      red: _fromLinear(r).clamp(0.0, 1.0),
      green: _fromLinear(g).clamp(0.0, 1.0),
      blue: _fromLinear(bl).clamp(0.0, 1.0),
    );
  }

  /// Converts to the polar OKLCH form.
  OkLch toOkLch() {
    final double c = math.sqrt(a * a + b * b);
    double h = math.atan2(b, a) * 180 / math.pi;
    if (h < 0) h += 360;
    return OkLch(l, c, c < 1e-7 ? 0 : h, alpha);
  }

  @override
  bool operator ==(Object other) =>
      other is OkLab &&
      other.l == l &&
      other.a == a &&
      other.b == b &&
      other.alpha == alpha;

  @override
  int get hashCode => Object.hash(l, a, b, alpha);

  @override
  String toString() => 'OkLab($l, $a, $b, $alpha)';
}

/// A color in the OKLCH color space (the polar form of [OkLab]).
@immutable
class OkLch {
  /// Creates an OKLCH color: lightness `0..1`, chroma `>= 0`, hue in degrees.
  const OkLch(this.l, this.c, this.h, [this.alpha = 1.0]);

  /// Lightness, `0..1`.
  final double l;

  /// Chroma.
  final double c;

  /// Hue angle in degrees.
  final double h;

  /// Opacity, `0..1`.
  final double alpha;

  /// Converts to OKLab.
  OkLab toOkLab() {
    final double rad = h * math.pi / 180;
    return OkLab(l, c * math.cos(rad), c * math.sin(rad), alpha);
  }

  /// Converts to an sRGB [Color].
  Color toColor() => toOkLab().toColor();

  /// Returns a copy with the given fields replaced.
  OkLch copyWith({double? l, double? c, double? h, double? alpha}) =>
      OkLch(l ?? this.l, c ?? this.c, h ?? this.h, alpha ?? this.alpha);

  @override
  bool operator ==(Object other) =>
      other is OkLch &&
      other.l == l &&
      other.c == c &&
      other.h == h &&
      other.alpha == alpha;

  @override
  int get hashCode => Object.hash(l, c, h, alpha);

  @override
  String toString() => 'OkLch($l, $c, $h, $alpha)';
}

/// Shorthand for an sRGB [Color] from OKLCH components, mirroring the CSS
/// `oklch(L C H / alpha)` notation (with [l] as a `0..1` fraction).
Color oklch(double l, double c, double h, [double alpha = 1.0]) =>
    OkLch(l, c, h, alpha).toColor();

/// The interpolation space of a [colorMix] call.
enum ColorMixSpace {
  /// `color-mix(in oklab, ...)`.
  oklab,

  /// `color-mix(in srgb, ...)`.
  srgb,

  /// `color-mix(in oklch, ...)`.
  oklch,
}

/// Evaluates CSS `color-mix(in <space>, a p1%, b p2%)`.
///
/// Implements the CSS Color 5 algorithm: percentages are normalised, colors
/// are interpolated with premultiplied alpha and, when the percentages sum to
/// less than 100%, the resulting alpha is scaled by that sum. Passing `null`
/// for a percentage means "the remainder", like omitting it in CSS.
Color colorMix(
  Color a,
  Color b, {
  double? p1,
  double? p2,
  ColorMixSpace space = ColorMixSpace.oklab,
}) {
  double w1 = p1 ?? (p2 == null ? 0.5 : 1 - p2);
  double w2 = p2 ?? 1 - w1;
  final double sum = w1 + w2;
  if (sum <= 0) return const Color(0x00000000);
  w1 /= sum;
  w2 /= sum;
  final double alphaMultiplier = sum < 1 ? sum : 1;

  final double alpha = a.a * w1 + b.a * w2;
  if (alpha <= 0) return const Color(0x00000000);

  switch (space) {
    case ColorMixSpace.srgb:
      double channel(double ca, double cb) =>
          (ca * a.a * w1 + cb * b.a * w2) / alpha;
      return Color.from(
        alpha: (alpha * alphaMultiplier).clamp(0.0, 1.0),
        red: channel(a.r, b.r).clamp(0.0, 1.0),
        green: channel(a.g, b.g).clamp(0.0, 1.0),
        blue: channel(a.b, b.b).clamp(0.0, 1.0),
      );
    case ColorMixSpace.oklab:
      final OkLab la = OkLab.fromColor(a);
      final OkLab lb = OkLab.fromColor(b);
      double channel(double ca, double cb) =>
          (ca * la.alpha * w1 + cb * lb.alpha * w2) / alpha;
      return OkLab(
        channel(la.l, lb.l),
        channel(la.a, lb.a),
        channel(la.b, lb.b),
        alpha * alphaMultiplier,
      ).toColor();
    case ColorMixSpace.oklch:
      final OkLch ca = OkLab.fromColor(a).toOkLch();
      final OkLch cb = OkLab.fromColor(b).toOkLch();
      // A fully transparent or achromatic side has a powerless hue and takes
      // the hue of the other side, as the CSS spec requires.
      final bool aPowerless = a.a == 0 || ca.c < 1e-6;
      final bool bPowerless = b.a == 0 || cb.c < 1e-6;
      final double ha = aPowerless ? cb.h : ca.h;
      final double hb = bPowerless ? ca.h : cb.h;
      double dh = hb - ha;
      if (dh > 180) dh -= 360;
      if (dh < -180) dh += 360;
      double channel(double va, double vb) =>
          (va * a.a * w1 + vb * b.a * w2) / alpha;
      return OkLch(
        channel(ca.l, cb.l),
        channel(ca.c, cb.c),
        (ha + dh * w2) % 360,
        alpha * alphaMultiplier,
      ).toColor();
  }
}

/// Returns [color] with its OKLCH lightness shifted by [delta], mirroring the
/// CSS relative color syntax `oklch(from <color> calc(l + delta) c h)`.
Color shiftOkLchLightness(Color color, double delta) {
  final OkLch lch = OkLab.fromColor(color).toOkLch();
  return lch.copyWith(l: (lch.l + delta).clamp(0.0, 1.0)).toColor();
}

/// Relative luminance per WCAG 2.x.
double relativeLuminance(Color color) {
  return 0.2126 * _toLinear(color.r) +
      0.7152 * _toLinear(color.g) +
      0.0722 * _toLinear(color.b);
}

/// WCAG 2.x contrast ratio between two opaque colors (`1..21`).
double contrastRatio(Color a, Color b) {
  final double la = relativeLuminance(a);
  final double lb = relativeLuminance(b);
  final double hi = math.max(la, lb);
  final double lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

double _toLinear(double c) {
  final double v = c.abs();
  final double r = v <= 0.04045
      ? v / 12.92
      : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return c < 0 ? -r : r;
}

double _fromLinear(double c) {
  final double v = c.abs();
  final double r = v <= 0.0031308
      ? v * 12.92
      : 1.055 * math.pow(v, 1 / 2.4).toDouble() - 0.055;
  return c < 0 ? -r : r;
}

double _cbrt(double x) =>
    x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();
