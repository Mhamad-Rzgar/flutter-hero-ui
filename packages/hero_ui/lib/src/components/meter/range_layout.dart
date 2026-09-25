import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The layout of HeroUI's meter, progress bar and slider roots: a
/// full-width grid with the [label] at the start and the [output] at the
/// end of the first row, and the [track] across the second row
/// (`grid-template-areas: "label output" "track track";
/// grid-template-columns: 1fr auto; gap-1`).
///
/// The label keeps its natural width (`w-fit`) and wraps when it meets the
/// output. Extra [children] follow the track as full-width rows.
///
/// The grid fills the available width (`w-full`); where the width is
/// unbounded (inside a [Row], for example) it is [fallbackWidth] wide, 256
/// by default (`w-64`, the width of HeroUI's examples).
class HeroRangeLayout extends StatelessWidget {
  /// Creates the grid.
  const HeroRangeLayout({
    super.key,
    required this.track,
    this.label,
    this.output,
    this.children = const <Widget>[],
    this.gap,
    this.fallbackWidth,
  });

  /// The label area (usually a `HeroLabel`).
  final Widget? label;

  /// The output area (the formatted value).
  final Widget? output;

  /// The track area.
  final Widget track;

  /// Extra rows below the track.
  final List<Widget> children;

  /// Space between the areas; defaults to `gap-1` (4).
  final double? gap;

  /// Width used when the incoming width is unbounded; defaults to `w-64`.
  final double? fallbackWidth;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double gap = this.gap ?? theme.spacing(1);
    final Widget? label = this.label;
    final Widget? output = this.output;
    return HeroFillExtent(
      fallback: fallbackWidth ?? theme.spacing(64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: gap,
        children: <Widget>[
          if (label != null || output != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: gap,
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    heightFactor: 1,
                    child: label ?? const SizedBox.shrink(),
                  ),
                ),
                ?output,
              ],
            ),
          track,
          ...children,
        ],
      ),
    );
  }
}

/// Sizes [child] to the full incoming extent along [axis] (`w-full` or
/// `h-full`), or to [fallback] when that extent is unbounded.
class HeroFillExtent extends SingleChildRenderObjectWidget {
  /// Creates a box that fills [axis].
  const HeroFillExtent({
    super.key,
    this.axis = Axis.horizontal,
    required this.fallback,
    required Widget super.child,
  });

  /// The axis to fill.
  final Axis axis;

  /// The extent used when the incoming extent is unbounded.
  final double fallback;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeroFillExtent(axis, fallback);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderHeroFillExtent)
      ..axis = axis
      ..fallback = fallback;
  }
}

class _RenderHeroFillExtent extends RenderProxyBox {
  _RenderHeroFillExtent(this._axis, this._fallback);

  Axis get axis => _axis;
  Axis _axis;
  set axis(Axis value) {
    if (value == _axis) return;
    _axis = value;
    markNeedsLayout();
  }

  double get fallback => _fallback;
  double _fallback;
  set fallback(double value) {
    if (value == _fallback) return;
    _fallback = value;
    markNeedsLayout();
  }

  BoxConstraints _childConstraints(BoxConstraints constraints) {
    switch (_axis) {
      case Axis.horizontal:
        final double width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : math.max(constraints.minWidth, _fallback);
        return constraints.copyWith(minWidth: width, maxWidth: width);
      case Axis.vertical:
        final double height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : math.max(constraints.minHeight, _fallback);
        return constraints.copyWith(minHeight: height, maxHeight: height);
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => _axis == Axis.horizontal
      ? _fallback
      : super.computeMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) => _axis == Axis.horizontal
      ? _fallback
      : super.computeMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) => _axis == Axis.vertical
      ? _fallback
      : super.computeMinIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _axis == Axis.vertical
      ? _fallback
      : super.computeMaxIntrinsicHeight(width);

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final RenderBox? child = this.child;
    final BoxConstraints inner = _childConstraints(constraints);
    if (child == null) return inner.smallest;
    return constraints.constrain(child.getDryLayout(inner));
  }

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) => child?.getDryBaseline(_childConstraints(constraints), baseline);

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    final BoxConstraints inner = _childConstraints(constraints);
    if (child == null) {
      size = constraints.constrain(inner.smallest);
      return;
    }
    child.layout(inner, parentUsesSize: true);
    size = constraints.constrain(child.size);
  }
}
