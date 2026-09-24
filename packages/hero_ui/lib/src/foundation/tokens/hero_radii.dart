import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

/// The HeroUI border-radius scale.
///
/// HeroUI derives every radius from a single `--radius` variable (8 by
/// default) and a separate `--field-radius` for form fields (12 by default).
/// The named steps follow `theme.css`:
///
/// | Token | Formula | Default |
/// | --- | --- | --- |
/// | [xs] | radius × 0.25 | 2 |
/// | [sm] | radius × 0.5 | 4 |
/// | [md] | radius × 0.75 | 6 |
/// | [lg] | radius × 1 | 8 |
/// | [xl] | radius × 1.5 | 12 |
/// | [xl2] | radius × 2 | 16 |
/// | [xl3] | radius × 3 | 24 |
/// | [xl4] | radius × 4 | 32 |
@immutable
class HeroRadii with Diagnosticable {
  /// Creates a radius scale from the base [radius] and the [field] radius.
  const HeroRadii({this.radius = 8, this.field = 12});

  /// The `--radius` base value.
  final double radius;

  /// The `--field-radius` used by inputs, selects and other form fields.
  final double field;

  /// `rounded-none`.
  double get none => 0;

  /// `rounded-xs` (radius × 0.25).
  double get xs => radius * 0.25;

  /// `rounded-sm` (radius × 0.5).
  double get sm => radius * 0.5;

  /// `rounded-md` (radius × 0.75).
  double get md => radius * 0.75;

  /// `rounded-lg` (radius × 1).
  double get lg => radius;

  /// `rounded-xl` (radius × 1.5).
  double get xl => radius * 1.5;

  /// `rounded-2xl` (radius × 2).
  double get xl2 => radius * 2;

  /// `rounded-3xl` (radius × 3).
  double get xl3 => radius * 3;

  /// `rounded-4xl` (radius × 4).
  double get xl4 => radius * 4;

  /// `rounded-full`: large enough to produce a stadium on any control.
  double get full => 9999;

  /// Returns a copy with the given values replaced.
  HeroRadii copyWith({double? radius, double? field}) =>
      HeroRadii(radius: radius ?? this.radius, field: field ?? this.field);

  /// Linearly interpolates between two scales.
  static HeroRadii lerp(HeroRadii a, HeroRadii b, double t) => HeroRadii(
    radius: lerpDouble(a.radius, b.radius, t)!,
    field: lerpDouble(a.field, b.field, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is HeroRadii && other.radius == radius && other.field == field;

  @override
  int get hashCode => Object.hash(radius, field);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('radius', radius))
      ..add(DoubleProperty('field', field));
  }
}
