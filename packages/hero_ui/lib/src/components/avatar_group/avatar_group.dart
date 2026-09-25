import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/interaction/hero_focus_ring.dart';
import '../../foundation/theme/hero_theme.dart';
import '../../foundation/theme/hero_theme_data.dart';
import '../../foundation/variants/hero_variants.dart';
import '../avatar/avatar.dart';

/// How the stacked avatars of a [HeroAvatarGroup] are separated.
enum HeroAvatarGroupOverlap {
  /// A transparent crescent is cut out of each avatar where the next one
  /// overlaps it, so the page shows through the seam (the default).
  clip,

  /// Each avatar gets an outline in the page `background` color.
  ring,
}

/// A stacked or grid group of avatars with overflow counting (HeroUI
/// `AvatarGroup`).
///
/// ```dart
/// HeroAvatarGroup(
///   max: 3,
///   children: <Widget>[
///     for (final User user in users) HeroAvatar(src: user.photo, name: user.name),
///   ],
/// )
/// ```
///
/// Avatars overlap by [overlapDistance], later ones on top. With [max],
/// only the first avatars are shown followed by a `+N` count, unless a
/// [HeroAvatarGroupCount] is among [children]. [size], [color] and
/// [variant] apply to avatars that do not set their own.
class HeroAvatarGroup extends StatelessWidget {
  /// Creates an avatar group.
  const HeroAvatarGroup({
    super.key,
    required this.children,
    this.size = HeroSize.md,
    this.color,
    this.variant,
    this.max,
    this.isGrid = false,
    this.overlap = HeroAvatarGroupOverlap.clip,
    this.overlapDistance,
    this.seam,
    this.semanticLabel,
  });

  /// Avatars, optionally followed by a [HeroAvatarGroupCount].
  final List<Widget> children;

  /// Size of avatars (and the count) that do not set one.
  final HeroSize size;

  /// Color of avatars (and the count) that do not set one.
  final HeroColor? color;

  /// Variant of avatars (and the count) that do not set one.
  final HeroAvatarVariant? variant;

  /// Maximum number of avatars shown; the rest are summarized by a count.
  final int? max;

  /// Wraps the avatars in rows 12 apart instead of stacking them.
  final bool isGrid;

  /// How stacked avatars are separated; ignored in a grid.
  final HeroAvatarGroupOverlap overlap;

  /// How much each avatar overlaps the previous one
  /// (`--avatar-group-overlap`, 8 by default).
  final double? overlapDistance;

  /// Width of the seam between avatars (`--avatar-group-seam`, 2 by
  /// default).
  final double? seam;

  /// Accessibility label; when set the group is announced as one labelled
  /// container (`role="group"` with `aria-label`).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double distance = overlapDistance ?? theme.spacing(2);
    final double seamWidth = seam ?? theme.spacing(0.5);

    final List<Widget> avatars = <Widget>[];
    final List<Widget> counts = <Widget>[];
    for (final Widget child in children) {
      (child is HeroAvatarGroupCount ? counts : avatars).add(child);
    }
    final List<Widget> visible = max == null
        ? avatars
        : avatars.take(math.max(0, max!)).toList();
    final int remaining = avatars.length - visible.length;
    final List<Widget> items = <Widget>[
      ...visible,
      if (counts.isNotEmpty)
        ...counts
      else if (remaining > 0)
        HeroAvatarGroupCount(child: Text('+$remaining')),
    ];

    Widget result;
    if (isGrid) {
      result = Wrap(
        spacing: theme.spacing(3),
        runSpacing: theme.spacing(3),
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          for (final Widget item in items)
            HeroAvatarScope(
              size: size,
              color: color,
              variant: variant,
              child: item,
            ),
        ],
      );
    } else {
      final bool clip = overlap == HeroAvatarGroupOverlap.clip;
      final TextDirection direction = Directionality.of(context);
      result = _OverlapRow(
        overlap: distance,
        textDirection: direction,
        children: <Widget>[
          for (final (int index, Widget item) in items.indexed)
            _GroupItem(
              clip: clip && index < items.length - 1,
              ring: !clip,
              overlap: distance,
              seam: seamWidth,
              textDirection: direction,
              child: HeroAvatarScope(
                size: size,
                color: color,
                variant: variant,
                fallbackPadding: clip && index < items.length - 1
                    ? EdgeInsetsDirectional.only(end: distance * 0.35)
                    : null,
                child: item,
              ),
            ),
        ],
      );
    }
    if (semanticLabel != null) {
      result = Semantics(
        container: true,
        explicitChildNodes: true,
        label: semanticLabel,
        child: result,
      );
    }
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<HeroSize>('size', size))
      ..add(IntProperty('max', max, defaultValue: null))
      ..add(FlagProperty('isGrid', value: isGrid, ifTrue: 'grid'))
      ..add(EnumProperty<HeroAvatarGroupOverlap>('overlap', overlap));
  }
}

/// The overflow count of a [HeroAvatarGroup] (HeroUI `AvatarGroup.Count`):
/// an avatar whose fallback shows [child], for example `Text('+3')`.
///
/// Placing one in the group replaces the automatic count, and it is never
/// hidden by `max`. Size, color and variant default to the group's.
class HeroAvatarGroupCount extends StatelessWidget {
  /// Creates a count.
  const HeroAvatarGroupCount({
    super.key,
    required this.child,
    this.size,
    this.color,
    this.variant,
  });

  /// The count content, usually a [Text] such as `+3`.
  final Widget child;

  /// Overrides the group size.
  final HeroSize? size;

  /// Overrides the group color.
  final HeroColor? color;

  /// Overrides the group variant.
  final HeroAvatarVariant? variant;

  @override
  Widget build(BuildContext context) => HeroAvatar(
    size: size,
    color: color,
    variant: variant,
    children: <Widget>[HeroAvatarFallback(child: child)],
  );
}

/// Applies the clip crescent or the ring seam to one group item.
class _GroupItem extends StatelessWidget {
  const _GroupItem({
    required this.clip,
    required this.ring,
    required this.overlap,
    required this.seam,
    required this.textDirection,
    required this.child,
  });

  final bool clip;
  final bool ring;
  final double overlap;
  final double seam;
  final TextDirection textDirection;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    Widget result = child;
    if (clip) {
      result = ClipPath(
        clipper: HeroAvatarGroupClipper(
          overlap: overlap,
          seam: seam,
          textDirection: textDirection,
        ),
        child: result,
      );
    }
    if (ring) {
      result = CustomPaint(
        painter: _RingPainter(
          color: theme.colors.background,
          seam: seam,
          theme: theme,
          textDirection: textDirection,
        ),
        child: result,
      );
    }
    return result;
  }
}

/// Cuts HeroUI's clip crescent out of an avatar: a circle centered
/// `size / 2 - overlap` beyond the avatar's end edge, `size / 2 + seam` in
/// radius, where the next avatar sits.
class HeroAvatarGroupClipper extends CustomClipper<Path> {
  /// Creates the clipper.
  const HeroAvatarGroupClipper({
    required this.overlap,
    required this.seam,
    required this.textDirection,
  });

  /// The group overlap distance.
  final double overlap;

  /// The seam width.
  final double seam;

  /// Direction of the group; the cut sits on the end edge.
  final TextDirection textDirection;

  @override
  Path getClip(Size size) {
    final double avatar = size.width;
    final double centerX = textDirection == TextDirection.rtl
        ? -avatar / 2 + overlap
        : avatar + avatar / 2 - overlap;
    final Path box = Path()..addRect(Offset.zero & size);
    final Path cut = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(centerX, size.height / 2),
          radius: avatar / 2 + seam,
        ),
      );
    return Path.combine(PathOperation.difference, box, cut);
  }

  @override
  bool shouldReclip(HeroAvatarGroupClipper oldClipper) =>
      oldClipper.overlap != overlap ||
      oldClipper.seam != seam ||
      oldClipper.textDirection != textDirection;
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.color,
    required this.seam,
    required this.theme,
    required this.textDirection,
  });

  final Color color;
  final double seam;
  final HeroThemeData theme;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    // The avatar's own radius: `rounded-2xl` up to the small size,
    // `rounded-3xl` above.
    final double radius =
        size.width <= HeroAvatar.dimensionOf(theme, HeroSize.sm)
        ? theme.radii.xl2
        : theme.radii.xl3;
    canvas.drawPath(
      heroInflatedShapePath(
        theme.shapeAll(radius),
        Offset.zero & size,
        seam,
        textDirection,
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.seam != seam ||
      oldDelegate.theme != theme ||
      oldDelegate.textDirection != textDirection;
}

/// Lays children out in a row where each overlaps the previous one by
/// [overlap]; later children paint on top.
class _OverlapRow extends MultiChildRenderObjectWidget {
  const _OverlapRow({
    required this.overlap,
    required this.textDirection,
    required super.children,
  });

  final double overlap;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderOverlapRow(overlap: overlap, textDirection: textDirection);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderOverlapRow renderObject,
  ) {
    renderObject
      ..overlap = overlap
      ..textDirection = textDirection;
  }
}

class _OverlapParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderOverlapRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OverlapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OverlapParentData> {
  _RenderOverlapRow({
    required double overlap,
    required TextDirection textDirection,
  }) : _overlap = overlap,
       _textDirection = textDirection;

  double _overlap;
  set overlap(double value) {
    if (value == _overlap) return;
    _overlap = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OverlapParentData) {
      child.parentData = _OverlapParentData();
    }
  }

  double _sumWidths(double Function(RenderBox child) width) {
    double total = 0;
    int count = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      total += width(child);
      count++;
      child = childAfter(child);
    }
    return math.max(0, total - _overlap * math.max(0, count - 1));
  }

  double _maxHeight(double Function(RenderBox child) height) {
    double result = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      result = math.max(result, height(child));
      child = childAfter(child);
    }
    return result;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _sumWidths((RenderBox c) => c.getMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _sumWidths((RenderBox c) => c.getMaxIntrinsicWidth(height));

  @override
  double computeMinIntrinsicHeight(double width) =>
      _maxHeight((RenderBox c) => c.getMinIntrinsicHeight(double.infinity));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _maxHeight((RenderBox c) => c.getMaxIntrinsicHeight(double.infinity));

  Size _layout(BoxConstraints constraints, {required bool dry}) {
    final BoxConstraints childConstraints = BoxConstraints(
      maxHeight: constraints.maxHeight,
    );
    double width = 0;
    double height = 0;
    int count = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final Size childSize = dry
          ? child.getDryLayout(childConstraints)
          : (child..layout(childConstraints, parentUsesSize: true)).size;
      width += childSize.width;
      height = math.max(height, childSize.height);
      count++;
      child = childAfter(child);
    }
    width = math.max(0, width - _overlap * math.max(0, count - 1));
    return constraints.constrain(Size(width, height));
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      _layout(constraints, dry: true);

  @override
  void performLayout() {
    size = _layout(constraints, dry: false);
    final bool rtl = _textDirection == TextDirection.rtl;
    double x = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final _OverlapParentData data = child.parentData! as _OverlapParentData;
      final Size childSize = child.size;
      final double dy = (size.height - childSize.height) / 2;
      data.offset = Offset(rtl ? size.width - x - childSize.width : x, dy);
      x += childSize.width - _overlap;
      child = data.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
