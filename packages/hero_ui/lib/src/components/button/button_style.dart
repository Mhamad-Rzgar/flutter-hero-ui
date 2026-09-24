import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Overrides for the look of a [HeroButton]-like component, the Flutter
/// counterpart of adding Tailwind classes to a HeroUI button.
///
/// Every field is optional; `null` keeps the component's HeroUI value.
/// Colors are [WidgetStateProperty]s resolved against the button's
/// interaction state ([WidgetState.hovered], [WidgetState.pressed],
/// [WidgetState.focused], [WidgetState.disabled]), so a hover color is
/// `WidgetStateProperty.resolveWith((states) => states.contains(
/// WidgetState.hovered) ? hover : null)`. A property that resolves to
/// `null` falls back to the component's own color for that state.
///
/// ```dart
/// HeroButton(
///   style: HeroButtonStyle(
///     borderRadius: BorderRadius.zero,
///     backgroundColor: WidgetStateProperty.resolveWith(
///       (Set<WidgetState> states) => states.contains(WidgetState.hovered)
///           ? const Color(0xFF0FBF3E)
///           : const Color(0xFF08872B),
///     ),
///   ),
///   onPressed: merge,
///   child: const Text('Merge pull request'),
/// )
/// ```
@immutable
class HeroButtonStyle with Diagnosticable {
  /// Creates a style override.
  const HeroButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.side,
    this.shadows,
    this.borderRadius,
    this.height,
    this.padding,
    this.textStyle,
    this.iconSize,
    this.pressedScale,
  });

  /// Fill color per interaction state (`--button-bg`, `--button-bg-hover`,
  /// `--button-bg-pressed`).
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Text and icon color per interaction state (`--button-fg`).
  final WidgetStateProperty<Color?>? foregroundColor;

  /// Outline drawn inside the button's bounds. [BorderSide.none] removes
  /// the outline of the `outline` variant.
  final BorderSide? side;

  /// Drop shadows painted behind the button (`shadow-*`).
  final List<BoxShadow>? shadows;

  /// Corner radii; defaults to `rounded-3xl`.
  final BorderRadiusGeometry? borderRadius;

  /// Minimum height (and the width of icon-only buttons).
  final double? height;

  /// Padding around the content, replacing the horizontal padding of the
  /// size (`px-*` / `py-*`).
  final EdgeInsetsGeometry? padding;

  /// Merged onto the label text style (`font-*`, `text-*`).
  final TextStyle? textStyle;

  /// Size of slot icons (`[&_svg]:size-*`).
  final double? iconSize;

  /// Scale applied while pressed (`active:scale-*`); `1` disables it.
  final double? pressedScale;

  /// Returns a copy with the given fields replaced.
  HeroButtonStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    BorderSide? side,
    List<BoxShadow>? shadows,
    BorderRadiusGeometry? borderRadius,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    double? iconSize,
    double? pressedScale,
  }) {
    return HeroButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      side: side ?? this.side,
      shadows: shadows ?? this.shadows,
      borderRadius: borderRadius ?? this.borderRadius,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      iconSize: iconSize ?? this.iconSize,
      pressedScale: pressedScale ?? this.pressedScale,
    );
  }

  /// Returns this style with the non-null fields of [other] applied on top.
  /// Text styles are merged.
  HeroButtonStyle merge(HeroButtonStyle? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      side: other.side,
      shadows: other.shadows,
      borderRadius: other.borderRadius,
      height: other.height,
      padding: other.padding,
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      iconSize: other.iconSize,
      pressedScale: other.pressedScale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeroButtonStyle &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.side == side &&
        listEquals(other.shadows, shadows) &&
        other.borderRadius == borderRadius &&
        other.height == height &&
        other.padding == padding &&
        other.textStyle == textStyle &&
        other.iconSize == iconSize &&
        other.pressedScale == pressedScale;
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    foregroundColor,
    side,
    shadows == null ? null : Object.hashAll(shadows!),
    borderRadius,
    height,
    padding,
    textStyle,
    iconSize,
    pressedScale,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<WidgetStateProperty<Color?>>(
          'backgroundColor',
          backgroundColor,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<WidgetStateProperty<Color?>>(
          'foregroundColor',
          foregroundColor,
          defaultValue: null,
        ),
      )
      ..add(DiagnosticsProperty<BorderSide>('side', side, defaultValue: null))
      ..add(
        DiagnosticsProperty<BorderRadiusGeometry>(
          'borderRadius',
          borderRadius,
          defaultValue: null,
        ),
      )
      ..add(DoubleProperty('height', height, defaultValue: null))
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>(
          'padding',
          padding,
          defaultValue: null,
        ),
      )
      ..add(DoubleProperty('iconSize', iconSize, defaultValue: null))
      ..add(DoubleProperty('pressedScale', pressedScale, defaultValue: null));
  }
}
