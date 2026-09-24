import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

/// The HeroUI spacing scale.
///
/// HeroUI uses Tailwind CSS v4's `--spacing` unit (0.25rem = 4 logical
/// pixels). Utilities such as `p-3` or `gap-2` multiply that unit, so
/// `spacing(3)` is 12 and `spacing(0.5)` is 2.
@immutable
class HeroSpacing with Diagnosticable {
  /// Creates a spacing scale with the given [unit].
  const HeroSpacing({this.unit = 4});

  /// The `--spacing` unit in logical pixels.
  final double unit;

  /// Returns `unit × steps`, the equivalent of a Tailwind spacing utility.
  double call(double steps) => unit * steps;

  /// `1` step (4).
  double get s1 => unit;

  /// `2` steps (8).
  double get s2 => unit * 2;

  /// `3` steps (12).
  double get s3 => unit * 3;

  /// `4` steps (16).
  double get s4 => unit * 4;

  /// `5` steps (20).
  double get s5 => unit * 5;

  /// `6` steps (24).
  double get s6 => unit * 6;

  /// `8` steps (32).
  double get s8 => unit * 8;

  /// Returns a copy with the given values replaced.
  HeroSpacing copyWith({double? unit}) => HeroSpacing(unit: unit ?? this.unit);

  /// Linearly interpolates between two scales.
  static HeroSpacing lerp(HeroSpacing a, HeroSpacing b, double t) =>
      HeroSpacing(unit: lerpDouble(a.unit, b.unit, t)!);

  @override
  bool operator ==(Object other) => other is HeroSpacing && other.unit == unit;

  @override
  int get hashCode => unit.hashCode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('unit', unit));
  }
}
