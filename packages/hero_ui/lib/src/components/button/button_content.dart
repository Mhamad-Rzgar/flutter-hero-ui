import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// Lays out the content of a HeroUI button: optional start content, a
/// label and optional end content in a centred row.
///
/// Reproduces the button's `inline-flex items-center justify-center gap-2
/// whitespace-nowrap` content box:
///
/// * slots are separated by [gap] and centred on both axes;
/// * a [HeroIcon] or [Icon] in any slot gets HeroUI's `-mx-0.5` negative
///   margin ([iconInset] on each side), so icons sit 2 px closer to the
///   edges and the neighbouring text (HeroUI applies it to every `svg`);
/// * the label shrinks (so a single-line label ellipsizes) when the width
///   is bounded, and keeps its natural width when it is not;
/// * with [expand] the row fills a bounded width (`w-full`);
/// * its natural size is rounded up to whole pixels, like the browser's
///   pixel snapping, so neighbouring buttons meet without a seam.
///
/// Start and end follow the ambient [Directionality].
class HeroButtonContent extends StatelessWidget {
  /// Creates the content row of a button.
  const HeroButtonContent({
    super.key,
    this.startContent,
    this.label,
    this.endContent,
    this.gap,
    this.iconInset,
    this.expand = false,
  });

  /// Content before the label (usually an icon).
  final Widget? startContent;

  /// The label.
  final Widget? label;

  /// Content after the label (usually an icon).
  final Widget? endContent;

  /// Space between slots; defaults to `gap-2` (8).
  final double? gap;

  /// Negative horizontal margin applied to icon slots; defaults to
  /// `-mx-0.5` (2).
  final double? iconInset;

  /// Whether to fill a bounded width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double inset = iconInset ?? theme.spacing(0.5);
    double insetOf(Widget? slot) =>
        slot is HeroIcon || slot is Icon ? inset : 0;
    return _HeroButtonContentLayout(
      start: startContent,
      label: label,
      end: endContent,
      gap: gap ?? theme.spacing(2),
      startInset: insetOf(startContent),
      labelInset: insetOf(label),
      endInset: insetOf(endContent),
      expand: expand,
      textDirection: Directionality.of(context),
    );
  }
}

enum _Slot { start, label, end }

class _HeroButtonContentLayout
    extends SlottedMultiChildRenderObjectWidget<_Slot, RenderBox> {
  const _HeroButtonContentLayout({
    required this.start,
    required this.label,
    required this.end,
    required this.gap,
    required this.startInset,
    required this.labelInset,
    required this.endInset,
    required this.expand,
    required this.textDirection,
  });

  final Widget? start;
  final Widget? label;
  final Widget? end;
  final double gap;
  final double startInset;
  final double labelInset;
  final double endInset;
  final bool expand;
  final TextDirection textDirection;

  @override
  Iterable<_Slot> get slots => _Slot.values;

  @override
  Widget? childForSlot(_Slot slot) => switch (slot) {
    _Slot.start => start,
    _Slot.label => label,
    _Slot.end => end,
  };

  @override
  _RenderHeroButtonContent createRenderObject(BuildContext context) {
    return _RenderHeroButtonContent(
      gap: gap,
      startInset: startInset,
      labelInset: labelInset,
      endInset: endInset,
      expand: expand,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHeroButtonContent renderObject,
  ) {
    renderObject
      ..gap = gap
      ..startInset = startInset
      ..labelInset = labelInset
      ..endInset = endInset
      ..expand = expand
      ..textDirection = textDirection;
  }
}

/// The result of laying out the row once.
class _ContentLayout {
  const _ContentLayout({
    required this.size,
    required this.labelConstraints,
    required this.offsets,
  });

  final Size size;
  final BoxConstraints labelConstraints;
  final Map<_Slot, Offset> offsets;
}

class _RenderHeroButtonContent extends RenderBox
    with SlottedContainerRenderObjectMixin<_Slot, RenderBox> {
  _RenderHeroButtonContent({
    required double gap,
    required double startInset,
    required double labelInset,
    required double endInset,
    required bool expand,
    required TextDirection textDirection,
  }) : _gap = gap,
       _startInset = startInset,
       _labelInset = labelInset,
       _endInset = endInset,
       _expand = expand,
       _textDirection = textDirection;

  double get gap => _gap;
  double _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  double get startInset => _startInset;
  double _startInset;
  set startInset(double value) {
    if (_startInset == value) return;
    _startInset = value;
    markNeedsLayout();
  }

  double get labelInset => _labelInset;
  double _labelInset;
  set labelInset(double value) {
    if (_labelInset == value) return;
    _labelInset = value;
    markNeedsLayout();
  }

  double get endInset => _endInset;
  double _endInset;
  set endInset(double value) {
    if (_endInset == value) return;
    _endInset = value;
    markNeedsLayout();
  }

  bool get expand => _expand;
  bool _expand;
  set expand(bool value) {
    if (_expand == value) return;
    _expand = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  // Paint and hit-test order: start, label, end.
  @override
  Iterable<RenderBox> get children => <RenderBox>[
    ?childForSlot(_Slot.start),
    ?childForSlot(_Slot.label),
    ?childForSlot(_Slot.end),
  ];

  double _insetOf(_Slot slot) => switch (slot) {
    _Slot.start => _startInset,
    _Slot.label => _labelInset,
    _Slot.end => _endInset,
  };

  int get _gapCount => math.max(0, children.length - 1);

  _ContentLayout _layout(
    BoxConstraints constraints,
    ChildLayouter layoutChild,
  ) {
    final BoxConstraints loose = BoxConstraints(
      maxHeight: constraints.maxHeight,
    );
    final Map<_Slot, Size> sizes = <_Slot, Size>{};
    double fixed = _gap * _gapCount;
    for (final _Slot slot in <_Slot>[_Slot.start, _Slot.end]) {
      final RenderBox? child = childForSlot(slot);
      if (child == null) continue;
      final Size size = layoutChild(child, loose);
      sizes[slot] = size;
      fixed += math.max(0, size.width - 2 * _insetOf(slot));
    }
    BoxConstraints labelConstraints = loose;
    final RenderBox? label = childForSlot(_Slot.label);
    if (label != null) {
      if (constraints.hasBoundedWidth) {
        labelConstraints = loose.copyWith(
          maxWidth: math.max(0, constraints.maxWidth - fixed) + 2 * _labelInset,
        );
      }
      sizes[_Slot.label] = layoutChild(label, labelConstraints);
    }

    double contentWidth = _gap * _gapCount;
    double contentHeight = 0;
    sizes.forEach((_Slot slot, Size size) {
      contentWidth += math.max(0, size.width - 2 * _insetOf(slot));
      contentHeight = math.max(contentHeight, size.height);
    });
    final Size size = constraints.constrain(
      Size(
        _expand && constraints.hasBoundedWidth
            ? constraints.maxWidth
            : _snap(contentWidth),
        _snap(contentHeight),
      ),
    );

    // `justify-content: center` also centres content wider than the box.
    double x = (size.width - contentWidth) / 2;
    final Map<_Slot, Offset> offsets = <_Slot, Offset>{};
    for (final _Slot slot in _Slot.values) {
      final Size? childSize = sizes[slot];
      if (childSize == null) continue;
      final double inset = _insetOf(slot);
      final double slotWidth = math.max(0, childSize.width - 2 * inset);
      final double dx = switch (_textDirection) {
        TextDirection.ltr => x - inset,
        TextDirection.rtl => size.width - x - slotWidth - inset,
      };
      offsets[slot] = Offset(dx, (size.height - childSize.height) / 2);
      x += slotWidth + _gap;
    }
    return _ContentLayout(
      size: size,
      labelConstraints: labelConstraints,
      offsets: offsets,
    );
  }

  @override
  void performLayout() {
    final _ContentLayout layout = _layout(
      constraints,
      ChildLayoutHelper.layoutChild,
    );
    size = layout.size;
    layout.offsets.forEach((_Slot slot, Offset offset) {
      (childForSlot(slot)!.parentData! as BoxParentData).offset = offset;
    });
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      _layout(constraints, ChildLayoutHelper.dryLayoutChild).size;

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final RenderBox? label = childForSlot(_Slot.label);
    if (label == null) return null;
    final _ContentLayout layout = _layout(
      constraints,
      ChildLayoutHelper.dryLayoutChild,
    );
    final double? distance = label.getDryBaseline(
      layout.labelConstraints,
      baseline,
    );
    if (distance == null) return null;
    return distance + layout.offsets[_Slot.label]!.dy;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final RenderBox? label = childForSlot(_Slot.label);
    if (label == null) return null;
    final double? distance = label.getDistanceToActualBaseline(baseline);
    if (distance == null) return null;
    return distance + (label.parentData! as BoxParentData).offset.dy;
  }

  /// Rounds a natural extent up to a whole logical pixel.
  static double _snap(double extent) =>
      math.max(0, (extent - 1e-6).ceilToDouble());

  double _intrinsicWidth(double height, {required bool max}) {
    double width = _gap * _gapCount;
    for (final _Slot slot in _Slot.values) {
      final RenderBox? child = childForSlot(slot);
      if (child == null) continue;
      final double childWidth = max
          ? child.getMaxIntrinsicWidth(height)
          : child.getMinIntrinsicWidth(height);
      width += math.max(0, childWidth - 2 * _insetOf(slot));
    }
    return _snap(width);
  }

  double _intrinsicHeight({required bool max}) {
    double height = 0;
    for (final RenderBox child in children) {
      height = math.max(
        height,
        max
            ? child.getMaxIntrinsicHeight(double.infinity)
            : child.getMinIntrinsicHeight(double.infinity),
      );
    }
    return _snap(height);
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _intrinsicWidth(height, max: false);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _intrinsicWidth(height, max: true);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _intrinsicHeight(max: false);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(max: true);

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final RenderBox child in children) {
      context.paintChild(
        child,
        offset + (child.parentData! as BoxParentData).offset,
      );
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final RenderBox child in children.toList().reversed) {
      final bool hit = result.addWithPaintOffset(
        offset: (child.parentData! as BoxParentData).offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) =>
            child.hitTest(result, position: transformed),
      );
      if (hit) return true;
    }
    return false;
  }
}
