import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The layout of a field root (HeroUI's `flex flex-col gap-*` field): parts
/// stacked vertically and stretched to one width, with [spacing] between
/// the parts that are rendered (a part that renders nothing, like a hidden
/// description, takes no gap, as `display: none` in CSS).
///
/// Given a tight width (or [fullWidth] and a bounded width) the layout fills
/// it; otherwise it is as wide as its widest part, like a CSS flex item.
class HeroFieldLayout extends MultiChildRenderObjectWidget {
  /// Lays out [children] as a field column.
  const HeroFieldLayout({
    super.key,
    required this.spacing,
    this.fullWidth = false,
    super.children,
  });

  /// Gap between rendered parts.
  final double spacing;

  /// Whether to fill a bounded width.
  final bool fullWidth;

  @override
  RenderHeroFieldLayout createRenderObject(BuildContext context) =>
      RenderHeroFieldLayout(spacing: spacing, fullWidth: fullWidth);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderHeroFieldLayout renderObject,
  ) {
    renderObject
      ..spacing = spacing
      ..fullWidth = fullWidth;
  }
}

/// Parent data of the children of a [RenderHeroFieldLayout].
class HeroFieldLayoutParentData extends ContainerBoxParentData<RenderBox> {}

/// The render object of a [HeroFieldLayout].
class RenderHeroFieldLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, HeroFieldLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, HeroFieldLayoutParentData> {
  /// Creates a field layout render object.
  RenderHeroFieldLayout({required double spacing, bool fullWidth = false})
    : _spacing = spacing,
      _fullWidth = fullWidth;

  /// Gap between rendered parts.
  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  /// Whether to fill a bounded width.
  bool get fullWidth => _fullWidth;
  bool _fullWidth;
  set fullWidth(bool value) {
    if (value == _fullWidth) return;
    _fullWidth = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! HeroFieldLayoutParentData) {
      child.parentData = HeroFieldLayoutParentData();
    }
  }

  double _maxChildWidth(double Function(RenderBox child) width) {
    double result = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final double w = width(child);
      if (w > result) result = w;
      child = childAfter(child);
    }
    return result;
  }

  double _stackedHeight(double Function(RenderBox child) height) {
    double total = 0;
    int visible = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final double h = height(child);
      if (h > 0) {
        total += h;
        visible++;
      }
      child = childAfter(child);
    }
    return total + (visible > 1 ? (visible - 1) * _spacing : 0);
  }

  @override
  double computeMinIntrinsicWidth(double height) => _maxChildWidth(
    (RenderBox child) => child.getMinIntrinsicWidth(double.infinity),
  );

  @override
  double computeMaxIntrinsicWidth(double height) => _maxChildWidth(
    (RenderBox child) => child.getMaxIntrinsicWidth(double.infinity),
  );

  @override
  double computeMinIntrinsicHeight(double width) =>
      _stackedHeight((RenderBox child) => child.getMinIntrinsicHeight(width));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _stackedHeight((RenderBox child) => child.getMaxIntrinsicHeight(width));

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToFirstActualBaseline(baseline);

  double _width(BoxConstraints constraints) {
    if (constraints.hasTightWidth) return constraints.maxWidth;
    if (_fullWidth && constraints.hasBoundedWidth) return constraints.maxWidth;
    return constraints.constrainWidth(
      _maxChildWidth(
        (RenderBox child) => child.getMaxIntrinsicWidth(double.infinity),
      ),
    );
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final double width = _width(constraints);
    final BoxConstraints childConstraints = BoxConstraints.tightFor(
      width: width,
    );
    final double height = _stackedHeight(
      (RenderBox child) => child.getDryLayout(childConstraints).height,
    );
    return constraints.constrain(Size(width, height));
  }

  @override
  void performLayout() {
    final double width = _width(constraints);
    final BoxConstraints childConstraints = BoxConstraints.tightFor(
      width: width,
    );
    double y = 0;
    bool first = true;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final HeroFieldLayoutParentData parentData =
          child.parentData! as HeroFieldLayoutParentData;
      if (child.size.height > 0) {
        if (!first) y += _spacing;
        first = false;
      }
      parentData.offset = Offset(0, y);
      y += child.size.height;
      child = parentData.nextSibling;
    }
    size = constraints.constrain(Size(width, y));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
