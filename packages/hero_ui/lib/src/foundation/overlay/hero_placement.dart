import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Where an anchored overlay is placed relative to its trigger.
///
/// Mirrors React Aria's `placement` prop. `start`/`end` placements are
/// logical and follow the text direction; `left`/`right` are physical.
enum HeroPlacement {
  /// `top`.
  top(HeroPlacementSide.top, HeroPlacementAlign.center),

  /// `top start`.
  topStart(HeroPlacementSide.top, HeroPlacementAlign.start),

  /// `top end`.
  topEnd(HeroPlacementSide.top, HeroPlacementAlign.end),

  /// `top left`.
  topLeft(HeroPlacementSide.top, HeroPlacementAlign.left),

  /// `top right`.
  topRight(HeroPlacementSide.top, HeroPlacementAlign.right),

  /// `bottom`.
  bottom(HeroPlacementSide.bottom, HeroPlacementAlign.center),

  /// `bottom start`.
  bottomStart(HeroPlacementSide.bottom, HeroPlacementAlign.start),

  /// `bottom end`.
  bottomEnd(HeroPlacementSide.bottom, HeroPlacementAlign.end),

  /// `bottom left`.
  bottomLeft(HeroPlacementSide.bottom, HeroPlacementAlign.left),

  /// `bottom right`.
  bottomRight(HeroPlacementSide.bottom, HeroPlacementAlign.right),

  /// `left`.
  left(HeroPlacementSide.left, HeroPlacementAlign.center),

  /// `left top`.
  leftTop(HeroPlacementSide.left, HeroPlacementAlign.top),

  /// `left bottom`.
  leftBottom(HeroPlacementSide.left, HeroPlacementAlign.bottom),

  /// `right`.
  right(HeroPlacementSide.right, HeroPlacementAlign.center),

  /// `right top`.
  rightTop(HeroPlacementSide.right, HeroPlacementAlign.top),

  /// `right bottom`.
  rightBottom(HeroPlacementSide.right, HeroPlacementAlign.bottom),

  /// `start` (left in LTR, right in RTL).
  start(HeroPlacementSide.start, HeroPlacementAlign.center),

  /// `start top`.
  startTop(HeroPlacementSide.start, HeroPlacementAlign.top),

  /// `start bottom`.
  startBottom(HeroPlacementSide.start, HeroPlacementAlign.bottom),

  /// `end` (right in LTR, left in RTL).
  end(HeroPlacementSide.end, HeroPlacementAlign.center),

  /// `end top`.
  endTop(HeroPlacementSide.end, HeroPlacementAlign.top),

  /// `end bottom`.
  endBottom(HeroPlacementSide.end, HeroPlacementAlign.bottom);

  const HeroPlacement(this.side, this.align);

  /// The side of the trigger the overlay sits on.
  final HeroPlacementSide side;

  /// The alignment along the trigger's edge.
  final HeroPlacementAlign align;
}

/// The side component of a [HeroPlacement].
enum HeroPlacementSide {
  /// Above the trigger.
  top,

  /// Below the trigger.
  bottom,

  /// Left of the trigger.
  left,

  /// Right of the trigger.
  right,

  /// Before the trigger in reading order.
  start,

  /// After the trigger in reading order.
  end,
}

/// The alignment component of a [HeroPlacement].
enum HeroPlacementAlign {
  /// Centered on the trigger.
  center,

  /// Aligned to the trigger's reading-order start edge.
  start,

  /// Aligned to the trigger's reading-order end edge.
  end,

  /// Aligned to the trigger's left edge.
  left,

  /// Aligned to the trigger's right edge.
  right,

  /// Aligned to the trigger's top edge.
  top,

  /// Aligned to the trigger's bottom edge.
  bottom,
}

/// A physical side, after resolving logical placements.
enum HeroOverlaySide {
  /// Above the trigger.
  top,

  /// Below the trigger.
  bottom,

  /// Left of the trigger.
  left,

  /// Right of the trigger.
  right;

  /// Whether the overlay sits above or below the trigger.
  bool get isVertical => this == top || this == bottom;

  /// The opposite side.
  HeroOverlaySide get opposite => switch (this) {
    top => bottom,
    bottom => top,
    left => right,
    right => left,
  };
}

/// The result of positioning an anchored overlay.
@immutable
class HeroOverlayGeometry {
  /// Creates a geometry.
  const HeroOverlayGeometry({
    required this.rect,
    required this.side,
    required this.anchorPoint,
    required this.maxHeight,
  });

  /// The overlay's rectangle in overlay coordinates.
  final Rect rect;

  /// The side of the trigger the overlay ended up on (after flipping).
  final HeroOverlaySide side;

  /// The point on the overlay's edge closest to the trigger's centre, in the
  /// overlay's local coordinates. Arrows are centred here and enter/exit
  /// zoom animations use it as the transform origin
  /// (`--trigger-anchor-point`).
  final Offset anchorPoint;

  /// The available height on [side].
  final double maxHeight;

  /// The anchor point as an [Alignment] within the overlay, for transforms.
  Alignment get anchorAlignment {
    if (rect.width == 0 || rect.height == 0) return Alignment.center;
    return Alignment(
      (anchorPoint.dx / rect.width) * 2 - 1,
      (anchorPoint.dy / rect.height) * 2 - 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HeroOverlayGeometry &&
      other.rect == rect &&
      other.side == side &&
      other.anchorPoint == anchorPoint &&
      other.maxHeight == maxHeight;

  @override
  int get hashCode => Object.hash(rect, side, anchorPoint, maxHeight);

  @override
  String toString() =>
      'HeroOverlayGeometry(rect: $rect, side: $side, anchorPoint: $anchorPoint, maxHeight: $maxHeight)';
}

/// Resolves a [HeroPlacement] into a physical side for [direction].
HeroOverlaySide resolveHeroPlacementSide(
  HeroPlacement placement,
  TextDirection direction,
) {
  final bool rtl = direction == TextDirection.rtl;
  return switch (placement.side) {
    HeroPlacementSide.top => HeroOverlaySide.top,
    HeroPlacementSide.bottom => HeroOverlaySide.bottom,
    HeroPlacementSide.left => HeroOverlaySide.left,
    HeroPlacementSide.right => HeroOverlaySide.right,
    HeroPlacementSide.start =>
      rtl ? HeroOverlaySide.right : HeroOverlaySide.left,
    HeroPlacementSide.end => rtl ? HeroOverlaySide.left : HeroOverlaySide.right,
  };
}

/// Available space around [anchor] inside [viewport] on each side.
double _space(HeroOverlaySide side, Rect anchor, Rect viewport) =>
    switch (side) {
      HeroOverlaySide.top => anchor.top - viewport.top,
      HeroOverlaySide.bottom => viewport.bottom - anchor.bottom,
      HeroOverlaySide.left => anchor.left - viewport.left,
      HeroOverlaySide.right => viewport.right - anchor.right,
    };

/// Chooses the side an overlay of [size] should use, flipping to the
/// opposite side when it does not fit and the opposite side has more room
/// (React Aria's `shouldFlip`).
HeroOverlaySide chooseHeroOverlaySide({
  required HeroOverlaySide preferred,
  required Size size,
  required Rect anchor,
  required Rect viewport,
  required double offset,
  required bool shouldFlip,
}) {
  if (!shouldFlip) return preferred;
  final double needed =
      (preferred.isVertical ? size.height : size.width) + offset;
  final double available = _space(preferred, anchor, viewport);
  if (needed <= available) return preferred;
  final double opposite = _space(preferred.opposite, anchor, viewport);
  return opposite > available ? preferred.opposite : preferred;
}

/// Maximum overlay extent along the main axis on [side].
double heroOverlayMaxExtent({
  required HeroOverlaySide side,
  required Rect anchor,
  required Rect viewport,
  required double offset,
}) => math.max(0, _space(side, anchor, viewport) - offset);

/// Computes the geometry of an overlay of [size] anchored to [anchor].
///
/// [viewport] is the area the overlay must stay inside (already inset by the
/// container padding). [offset] is the gap between trigger and overlay along
/// the main axis and [crossOffset] shifts it along the cross axis.
HeroOverlayGeometry computeHeroOverlayGeometry({
  required Rect anchor,
  required Size size,
  required Rect viewport,
  required HeroPlacement placement,
  required TextDirection direction,
  double offset = 8,
  double crossOffset = 0,
  bool shouldFlip = true,
}) {
  final HeroOverlaySide preferred = resolveHeroPlacementSide(
    placement,
    direction,
  );
  final HeroOverlaySide side = chooseHeroOverlaySide(
    preferred: preferred,
    size: size,
    anchor: anchor,
    viewport: viewport,
    offset: offset,
    shouldFlip: shouldFlip,
  );
  final bool rtl = direction == TextDirection.rtl;

  double x;
  double y;
  if (side.isVertical) {
    y = side == HeroOverlaySide.top
        ? anchor.top - offset - size.height
        : anchor.bottom + offset;
    final HeroPlacementAlign align = placement.align;
    final bool alignLeft =
        align == HeroPlacementAlign.left ||
        (align == HeroPlacementAlign.start && !rtl) ||
        (align == HeroPlacementAlign.end && rtl);
    final bool alignRight =
        align == HeroPlacementAlign.right ||
        (align == HeroPlacementAlign.end && !rtl) ||
        (align == HeroPlacementAlign.start && rtl);
    if (alignLeft) {
      x = anchor.left;
    } else if (alignRight) {
      x = anchor.right - size.width;
    } else {
      x = anchor.center.dx - size.width / 2;
    }
    x += crossOffset;
    x = _clamp(x, viewport.left, viewport.right - size.width);
  } else {
    x = side == HeroOverlaySide.left
        ? anchor.left - offset - size.width
        : anchor.right + offset;
    final HeroPlacementAlign align = placement.align;
    if (align == HeroPlacementAlign.top) {
      y = anchor.top;
    } else if (align == HeroPlacementAlign.bottom) {
      y = anchor.bottom - size.height;
    } else {
      y = anchor.center.dy - size.height / 2;
    }
    y += crossOffset;
    y = _clamp(y, viewport.top, viewport.bottom - size.height);
  }

  final Rect rect = Rect.fromLTWH(x, y, size.width, size.height);
  final Offset anchorPoint = switch (side) {
    HeroOverlaySide.top => Offset(
      _clamp(anchor.center.dx - x, 0, size.width),
      size.height,
    ),
    HeroOverlaySide.bottom => Offset(
      _clamp(anchor.center.dx - x, 0, size.width),
      0,
    ),
    HeroOverlaySide.left => Offset(
      size.width,
      _clamp(anchor.center.dy - y, 0, size.height),
    ),
    HeroOverlaySide.right => Offset(
      0,
      _clamp(anchor.center.dy - y, 0, size.height),
    ),
  };
  return HeroOverlayGeometry(
    rect: rect,
    side: side,
    anchorPoint: anchorPoint,
    maxHeight: side.isVertical
        ? heroOverlayMaxExtent(
            side: side,
            anchor: anchor,
            viewport: viewport,
            offset: offset,
          )
        : viewport.height,
  );
}

double _clamp(double value, double min, double max) {
  if (max < min) return min;
  return value.clamp(min, max);
}
