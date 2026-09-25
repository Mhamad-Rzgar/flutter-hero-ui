import 'package:flutter/widgets.dart';

import 'color_value.dart';

/// Shares the color of a `HeroColorPicker` with the color components inside
/// it (React Aria's `ColorPickerContext`).
///
/// A `HeroColorSwatch`, `HeroColorArea`, `HeroColorSlider`,
/// `HeroColorField` or `HeroColorSwatchPicker` without its own value reads
/// [value] and reports edits through [onChanged]. The value is a
/// [HeroColorValue], so every bound component keeps the same hue even when
/// saturation or brightness reach zero.
class HeroColorPickerScope extends InheritedWidget {
  /// Publishes [value] to [child].
  const HeroColorPickerScope({
    super.key,
    required this.value,
    required this.onChanged,
    required super.child,
  });

  /// The shared color.
  final HeroColorValue value;

  /// Called with the new color when a bound component edits it.
  final ValueChanged<HeroColorValue> onChanged;

  /// The closest picker scope, or null outside a color picker.
  static HeroColorPickerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroColorPickerScope>();

  @override
  bool updateShouldNotify(HeroColorPickerScope oldWidget) =>
      value != oldWidget.value || onChanged != oldWidget.onChanged;
}
