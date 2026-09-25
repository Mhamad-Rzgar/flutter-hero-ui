import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The HeroUI motion tokens: durations used across component CSS and the
/// easing curves declared in `theme.css`.
@immutable
class HeroMotion with Diagnosticable {
  /// Creates motion tokens. Set [reduceMotion] to force the reduced-motion
  /// behaviour regardless of the platform setting.
  const HeroMotion({this.reduceMotion = false});

  /// Forces `motion-reduce` behaviour: transitions resolve instantly.
  final bool reduceMotion;

  /// 100 ms — color and shadow transitions (`duration-100`).
  static const Duration fast = Duration(milliseconds: 100);

  /// 150 ms — the default transition duration (`duration-150`).
  static const Duration normal = Duration(milliseconds: 150);

  /// 200 ms — overlay fades and toasts.
  static const Duration medium = Duration(milliseconds: 200);

  /// 250 ms — press transforms and panel slides (`duration-250`).
  static const Duration slow = Duration(milliseconds: 250);

  /// 300 ms — drawers and large surfaces.
  static const Duration slower = Duration(milliseconds: 300);

  /// 350 ms — the slowest component transition.
  static const Duration slowest = Duration(milliseconds: 350);

  /// One turn of the `animate-spin-fast` spinner (0.75 s).
  static const Duration spin = Duration(milliseconds: 750);

  /// One sweep of the skeleton shimmer (`animate-skeleton`, 2 s).
  static const Duration skeleton = Duration(seconds: 2);

  /// One cycle of the text caret blink (`animate-caret-blink`, 1.2 s).
  static const Duration caretBlink = Duration(milliseconds: 1200);

  /// One turn of an indeterminate progress circle (`progress-circle-spin`,
  /// 1 s linear, the length of Tailwind's `animate-spin`).
  static const Duration progressSpin = Duration(seconds: 1);

  /// CSS `ease` (`--ease-smooth`).
  static const Curve smooth = Cubic(0.25, 0.1, 0.25, 1);

  /// Tailwind CSS v4 `--ease-out`.
  static const Curve easeOut = Cubic(0, 0, 0.2, 1);

  /// Tailwind CSS v4 `--ease-in`.
  static const Curve easeIn = Cubic(0.4, 0, 1, 1);

  /// Tailwind CSS v4 `--ease-in-out`.
  static const Curve easeInOut = Cubic(0.4, 0, 0.2, 1);

  /// `--ease-linear`.
  static const Curve linear = Curves.linear;

  /// `--ease-in-quad`.
  static const Curve easeInQuad = Cubic(0.55, 0.085, 0.68, 0.53);

  /// `--ease-in-cubic`.
  static const Curve easeInCubic = Cubic(0.55, 0.055, 0.675, 0.19);

  /// `--ease-in-quart`.
  static const Curve easeInQuart = Cubic(0.895, 0.03, 0.685, 0.22);

  /// `--ease-in-quint`.
  static const Curve easeInQuint = Cubic(0.755, 0.05, 0.855, 0.06);

  /// `--ease-in-expo`.
  static const Curve easeInExpo = Cubic(0.95, 0.05, 0.795, 0.035);

  /// `--ease-in-circ`.
  static const Curve easeInCirc = Cubic(0.6, 0.04, 0.98, 0.335);

  /// `--ease-out-quad`.
  static const Curve easeOutQuad = Cubic(0.25, 0.46, 0.45, 0.94);

  /// `--ease-out-cubic`.
  static const Curve easeOutCubic = Cubic(0.215, 0.61, 0.355, 1);

  /// `--ease-out-quart`.
  static const Curve easeOutQuart = Cubic(0.165, 0.84, 0.44, 1);

  /// `--ease-out-quint`.
  static const Curve easeOutQuint = Cubic(0.23, 1, 0.32, 1);

  /// `--ease-out-expo`.
  static const Curve easeOutExpo = Cubic(0.19, 1, 0.22, 1);

  /// `--ease-out-circ`.
  static const Curve easeOutCirc = Cubic(0.075, 0.82, 0.165, 1);

  /// `--ease-out-fluid`: fast start, smooth stop, Apple style.
  static const Curve easeOutFluid = Cubic(0.32, 0.72, 0, 1);

  /// `--ease-in-out-quad`.
  static const Curve easeInOutQuad = Cubic(0.455, 0.03, 0.515, 0.955);

  /// `--ease-in-out-cubic`.
  static const Curve easeInOutCubic = Cubic(0.645, 0.045, 0.355, 1);

  /// `--ease-in-out-quart`.
  static const Curve easeInOutQuart = Cubic(0.77, 0, 0.175, 1);

  /// `--ease-in-out-quint`.
  static const Curve easeInOutQuint = Cubic(0.86, 0, 0.07, 1);

  /// `--ease-in-out-expo`.
  static const Curve easeInOutExpo = Cubic(1, 0, 0, 1);

  /// `--ease-in-out-circ`.
  static const Curve easeInOutCirc = Cubic(0.785, 0.135, 0.15, 0.86);

  /// Whether animations should be skipped in [context], honouring both
  /// [reduceMotion] and the platform's reduce-motion accessibility setting.
  bool shouldReduceMotion(BuildContext context) =>
      reduceMotion || (MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  /// Returns [duration], or [Duration.zero] when motion should be reduced in
  /// [context] (the `motion-reduce:transition-none` behaviour).
  Duration resolve(BuildContext context, Duration duration) =>
      shouldReduceMotion(context) ? Duration.zero : duration;

  /// Returns a copy with the given values replaced.
  HeroMotion copyWith({bool? reduceMotion}) =>
      HeroMotion(reduceMotion: reduceMotion ?? this.reduceMotion);

  @override
  bool operator ==(Object other) =>
      other is HeroMotion && other.reduceMotion == reduceMotion;

  @override
  int get hashCode => reduceMotion.hashCode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('reduceMotion', value: reduceMotion));
  }
}
