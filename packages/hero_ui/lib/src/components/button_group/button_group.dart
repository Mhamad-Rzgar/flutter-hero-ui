/// HeroUI's ButtonGroup: related buttons joined into one control.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../button/button.dart';
import '../toolbar/toolbar_scope.dart';
import 'button_group_scope.dart';

export 'button_group_scope.dart';

/// Groups related [HeroButton]s into a single attached control.
///
/// ```dart
/// HeroButtonGroup(
///   variant: HeroButtonVariant.secondary,
///   children: [
///     HeroButton(onPressed: () {}, child: const Text('First')),
///     const HeroButtonGroupSeparator(),
///     HeroButton(onPressed: () {}, child: const Text('Second')),
///     const HeroButtonGroupSeparator(),
///     HeroButton(onPressed: () {}, child: const Text('Third')),
///   ],
/// )
/// ```
///
/// The group passes [variant], [size], [isDisabled] and [fullWidth] to its
/// buttons (a button's own props win, so `isDisabled: false` re-enables one
/// button of a disabled group), rounds only the outer corners, merges the
/// outlines of `outline` buttons and turns off the press scale. A
/// [HeroButtonGroupSeparator] between two children draws a divider at the
/// start of the following button.
///
/// Children that are not buttons themselves (for example a dropdown whose
/// trigger is a [HeroButton]) pass the group's styling on to the buttons
/// they contain.
class HeroButtonGroup extends StatelessWidget {
  /// Creates a button group.
  const HeroButtonGroup({
    super.key,
    required this.children,
    this.variant,
    this.size,
    this.orientation,
    this.fullWidth = false,
    this.isDisabled = false,
    this.semanticLabel,
  });

  /// The buttons, optionally with [HeroButtonGroupSeparator]s between them.
  final List<Widget> children;

  /// The variant of every button that does not set its own.
  final HeroButtonVariant? variant;

  /// The size of every button that does not set its own.
  final HeroSize? size;

  /// Whether the buttons are laid out in a row or a column; defaults to the
  /// orientation of the enclosing `HeroToolbar`, then horizontal.
  final Axis? orientation;

  /// Whether the group fills a bounded width; its buttons share it equally
  /// in a row and stretch in a column.
  final bool fullWidth;

  /// Whether every button that does not set `isDisabled` is disabled.
  final bool isDisabled;

  /// Accessibility label of the group (`aria-label`).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final List<(Widget, bool)> items = <(Widget, bool)>[];
    bool separated = false;
    for (final Widget child in children) {
      if (child is HeroButtonGroupSeparator) {
        separated = true;
        continue;
      }
      items.add((child, separated));
      separated = false;
    }
    final Axis orientation =
        this.orientation ??
        HeroToolbarScope.maybeOf(context)?.orientation ??
        Axis.horizontal;
    final bool horizontal = orientation == Axis.horizontal;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: _HeroGroupFlex(
        direction: orientation,
        mainAxisSize: fullWidth && horizontal
            ? MainAxisSize.max
            : MainAxisSize.min,
        crossAxisAlignment: fullWidth && !horizontal
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: <Widget>[
          for (int i = 0; i < items.length; i++)
            _HeroButtonGroupItem(
              key: items[i].$1.key == null
                  ? null
                  : ValueKey<Key>(items[i].$1.key!),
              flex: fullWidth && horizontal ? 1 : null,
              scope: (Widget child) => HeroButtonGroupScope(
                position: HeroGroupPosition(
                  orientation: orientation,
                  index: i,
                  count: items.length,
                ),
                variant: variant,
                size: size,
                isDisabled: isDisabled,
                fullWidth: fullWidth ? true : null,
                hasSeparator: items[i].$2,
                child: child,
              ),
              child: items[i].$1,
            ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<HeroButtonVariant>('variant', variant, defaultValue: null),
      )
      ..add(EnumProperty<HeroSize>('size', size, defaultValue: null))
      ..add(EnumProperty<Axis>('orientation', orientation, defaultValue: null))
      ..add(FlagProperty('fullWidth', value: fullWidth, ifTrue: 'full width'))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'));
  }
}

/// A divider between two buttons of a [HeroButtonGroup]
/// (`ButtonGroup.Separator`).
///
/// Place it in the group's `children` between two buttons; the following
/// button draws a 1 px line in its text color at 15% opacity over half its
/// height, on its start edge (on its top edge in vertical groups). Outside
/// a group it renders nothing.
class HeroButtonGroupSeparator extends StatelessWidget {
  /// Creates a separator.
  const HeroButtonGroupSeparator({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _HeroButtonGroupItem extends StatefulWidget {
  const _HeroButtonGroupItem({
    super.key,
    required this.flex,
    required this.scope,
    required this.child,
  });

  final int? flex;
  final Widget Function(Widget child) scope;
  final Widget child;

  @override
  State<_HeroButtonGroupItem> createState() => _HeroButtonGroupItemState();
}

class _HeroButtonGroupItemState extends State<_HeroButtonGroupItem> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return _HeroGroupItemData(
      flex: widget.flex,
      raised: _focused,
      // Tracks focus anywhere inside the item so the focused button paints
      // above its neighbours and its focus ring is not covered (`z-10`).
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onFocusChange: (bool focused) => setState(() => _focused = focused),
        child: widget.scope(widget.child),
      ),
    );
  }
}

class _HeroGroupParentData extends FlexParentData {
  /// Whether the child paints after (above) its siblings.
  bool raised = false;
}

class _HeroGroupItemData extends ParentDataWidget<_HeroGroupParentData> {
  const _HeroGroupItemData({
    required this.flex,
    required this.raised,
    required super.child,
  });

  final int? flex;
  final bool raised;

  @override
  void applyParentData(RenderObject renderObject) {
    final _HeroGroupParentData data =
        renderObject.parentData! as _HeroGroupParentData;
    final RenderObject? parent = renderObject.parent;
    if (data.flex != flex || data.fit != FlexFit.tight) {
      data
        ..flex = flex
        ..fit = FlexFit.tight;
      parent?.markNeedsLayout();
    }
    if (data.raised != raised) {
      data.raised = raised;
      parent?.markNeedsPaint();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _HeroGroupFlex;
}

/// A [Flex] that paints a raised child last.
class _HeroGroupFlex extends Flex {
  const _HeroGroupFlex({
    required super.direction,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.children,
  });

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return _RenderHeroGroupFlex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
      spacing: spacing,
    );
  }
}

/// Buttons are laid out at whole pixels like the browser's pixel snapping:
/// full-width items get whole-pixel boundaries and the group paints at a
/// whole-pixel offset, so the fills of neighbouring buttons meet without an
/// anti-aliasing seam.
class _RenderHeroGroupFlex extends RenderFlex {
  _RenderHeroGroupFlex({
    super.direction,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    super.clipBehavior,
    super.spacing,
  });

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _HeroGroupParentData) {
      child.parentData = _HeroGroupParentData();
    }
  }

  @override
  void performLayout() {
    super.performLayout();
    if (direction != Axis.horizontal) return;
    // Flexible (full-width) items share the width in fractions; move their
    // boundaries to whole pixels.
    RenderBox? child = firstChild;
    while (child != null) {
      final _HeroGroupParentData data =
          child.parentData! as _HeroGroupParentData;
      if ((data.flex ?? 0) > 0) {
        final double left = data.offset.dx.roundToDouble();
        final double right = (data.offset.dx + child.size.width)
            .roundToDouble()
            .clamp(left, size.width);
        if (left != data.offset.dx || right - left != child.size.width) {
          child.layout(
            BoxConstraints.tightFor(
              width: right - left,
            ).copyWith(maxHeight: constraints.maxHeight),
            parentUsesSize: true,
          );
          data.offset = Offset(left, (size.height - child.size.height) / 2);
        }
      }
      child = data.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    offset = Offset(offset.dx.roundToDouble(), offset.dy.roundToDouble());
    RenderBox? raised;
    RenderBox? child = firstChild;
    while (child != null) {
      final _HeroGroupParentData data =
          child.parentData! as _HeroGroupParentData;
      if (data.raised) raised = child;
      child = data.nextSibling;
    }
    if (raised == null) {
      super.paint(context, offset);
      return;
    }
    child = firstChild;
    while (child != null) {
      final _HeroGroupParentData data =
          child.parentData! as _HeroGroupParentData;
      if (child != raised) context.paintChild(child, data.offset + offset);
      child = data.nextSibling;
    }
    context.paintChild(
      raised,
      (raised.parentData! as _HeroGroupParentData).offset + offset,
    );
  }
}
