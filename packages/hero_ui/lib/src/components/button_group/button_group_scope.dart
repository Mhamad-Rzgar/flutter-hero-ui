import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../button/button.dart';

/// Where an item sits inside an attached group of buttons (a
/// `HeroButtonGroup`, and later toggle button groups).
///
/// Attached groups round only their outer corners and merge the outlines
/// between neighbours; this class derives both from the item's index.
@immutable
class HeroGroupPosition {
  /// Creates the position of item [index] of [count] items laid out along
  /// [orientation].
  const HeroGroupPosition({
    required this.orientation,
    required this.index,
    required this.count,
  }) : assert(index >= 0 && index < count);

  /// The axis the group lays its items out on.
  final Axis orientation;

  /// The index of the item among the group's items.
  final int index;

  /// The number of items in the group.
  final int count;

  /// Whether the item is the first one (`:first-child`).
  bool get isFirst => index == 0;

  /// Whether the item is the last one (`:last-child`).
  bool get isLast => index == count - 1;

  /// Whether the item is the only one.
  bool get isOnly => count == 1;

  /// The item's corner radii: [radius] on the group's outer corners, square
  /// inside (`rounded-none` plus `rounded-s-3xl` / `rounded-e-3xl` or
  /// `rounded-t-3xl` / `rounded-b-3xl`).
  BorderRadiusDirectional borderRadius(double radius) {
    final Radius r = Radius.circular(radius);
    if (isOnly) return BorderRadiusDirectional.all(r);
    return switch (orientation) {
      Axis.horizontal => BorderRadiusDirectional.horizontal(
        start: isFirst ? r : Radius.zero,
        end: isLast ? r : Radius.zero,
      ),
      Axis.vertical => BorderRadiusDirectional.vertical(
        top: isFirst ? r : Radius.zero,
        bottom: isLast ? r : Radius.zero,
      ),
    };
  }

  /// The outline widths of a bordered item: the first item drops its end
  /// (bottom) side, the last its start (top) side and middle items both,
  /// so neighbouring outlines never double up.
  EdgeInsetsDirectional borderWidths(double width) {
    return switch (orientation) {
      Axis.horizontal => EdgeInsetsDirectional.fromSTEB(
        isFirst ? width : 0,
        width,
        isLast ? width : 0,
        width,
      ),
      Axis.vertical => EdgeInsetsDirectional.fromSTEB(
        width,
        isFirst ? width : 0,
        width,
        isLast ? width : 0,
      ),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is HeroGroupPosition &&
      other.orientation == orientation &&
      other.index == index &&
      other.count == count;

  @override
  int get hashCode => Object.hash(orientation, index, count);

  @override
  String toString() =>
      'HeroGroupPosition(${orientation.name}, ${index + 1} of $count)';
}

/// Shares a `HeroButtonGroup`'s props and an item's position with the
/// [HeroButton]s of that item.
///
/// A button reads the nearest scope for its default [variant], [size],
/// [isDisabled] and [fullWidth] (its own props win), its corner radii,
/// merged outline, separator and the absence of press scaling. Buttons
/// nested inside another button's content, and content wrapped in
/// [HeroButtonGroupScope.reset], are not affected.
class HeroButtonGroupScope extends InheritedWidget {
  /// Provides the group props and [position] to [child].
  const HeroButtonGroupScope({
    super.key,
    required HeroGroupPosition this.position,
    this.variant,
    this.size,
    this.isDisabled,
    this.fullWidth,
    this.hasSeparator = false,
    required super.child,
  });

  /// Hides any enclosing group from [child] (for example the content of a
  /// popover opened from a grouped button).
  const HeroButtonGroupScope.reset({super.key, required super.child})
    : position = null,
      variant = null,
      size = null,
      isDisabled = null,
      fullWidth = null,
      hasSeparator = false;

  /// The item's position, or null for [HeroButtonGroupScope.reset].
  final HeroGroupPosition? position;

  /// The group's variant for its buttons.
  final HeroButtonVariant? variant;

  /// The group's size for its buttons.
  final HeroSize? size;

  /// Whether the group disables its buttons.
  final bool? isDisabled;

  /// Whether the buttons fill the group's width.
  final bool? fullWidth;

  /// Whether a `HeroButtonGroupSeparator` precedes this item.
  final bool hasSeparator;

  /// The closest active scope, or null outside a group.
  static HeroButtonGroupScope? maybeOf(BuildContext context) {
    final HeroButtonGroupScope? scope = context
        .dependOnInheritedWidgetOfExactType<HeroButtonGroupScope>();
    return scope?.position == null ? null : scope;
  }

  @override
  bool updateShouldNotify(HeroButtonGroupScope oldWidget) =>
      position != oldWidget.position ||
      variant != oldWidget.variant ||
      size != oldWidget.size ||
      isDisabled != oldWidget.isDisabled ||
      fullWidth != oldWidget.fullWidth ||
      hasSeparator != oldWidget.hasSeparator;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<HeroGroupPosition>('position', position))
      ..add(
        EnumProperty<HeroButtonVariant>('variant', variant, defaultValue: null),
      )
      ..add(EnumProperty<HeroSize>('size', size, defaultValue: null))
      ..add(
        FlagProperty('hasSeparator', value: hasSeparator, ifTrue: 'separator'),
      );
  }
}
