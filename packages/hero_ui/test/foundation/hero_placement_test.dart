import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

void main() {
  const Rect viewport = Rect.fromLTWH(12, 12, 376, 776);

  test('bottom placement centres below the anchor', () {
    final HeroOverlayGeometry g = computeHeroOverlayGeometry(
      anchor: const Rect.fromLTWH(150, 100, 100, 40),
      size: const Size(200, 100),
      viewport: viewport,
      placement: HeroPlacement.bottom,
      direction: TextDirection.ltr,
    );
    expect(g.side, HeroOverlaySide.bottom);
    expect(g.rect, const Rect.fromLTWH(100, 148, 200, 100));
    expect(g.anchorPoint, const Offset(100, 0));
  });

  test('flips to the top when there is no room below', () {
    final HeroOverlayGeometry g = computeHeroOverlayGeometry(
      anchor: const Rect.fromLTWH(150, 700, 100, 40),
      size: const Size(200, 200),
      viewport: viewport,
      placement: HeroPlacement.bottom,
      direction: TextDirection.ltr,
    );
    expect(g.side, HeroOverlaySide.top);
    expect(g.rect.bottom, 692);
  });

  test('does not flip when shouldFlip is false', () {
    final HeroOverlayGeometry g = computeHeroOverlayGeometry(
      anchor: const Rect.fromLTWH(150, 700, 100, 40),
      size: const Size(200, 200),
      viewport: viewport,
      placement: HeroPlacement.bottom,
      direction: TextDirection.ltr,
      shouldFlip: false,
    );
    expect(g.side, HeroOverlaySide.bottom);
  });

  test('shifts along the cross axis to stay in the viewport', () {
    final HeroOverlayGeometry g = computeHeroOverlayGeometry(
      anchor: const Rect.fromLTWH(0, 100, 40, 40),
      size: const Size(200, 100),
      viewport: viewport,
      placement: HeroPlacement.bottom,
      direction: TextDirection.ltr,
    );
    expect(g.rect.left, 12);
    expect(g.anchorPoint.dx, 8);
  });

  test('start/end placements follow the text direction', () {
    expect(
      resolveHeroPlacementSide(HeroPlacement.start, TextDirection.ltr),
      HeroOverlaySide.left,
    );
    expect(
      resolveHeroPlacementSide(HeroPlacement.start, TextDirection.rtl),
      HeroOverlaySide.right,
    );
    final HeroOverlayGeometry g = computeHeroOverlayGeometry(
      anchor: const Rect.fromLTWH(150, 100, 100, 40),
      size: const Size(80, 100),
      viewport: viewport,
      placement: HeroPlacement.bottomStart,
      direction: TextDirection.rtl,
    );
    expect(g.rect.right, 250);
  });

  test('side placements centre vertically', () {
    final HeroOverlayGeometry g = computeHeroOverlayGeometry(
      anchor: const Rect.fromLTWH(150, 300, 40, 40),
      size: const Size(100, 60),
      viewport: viewport,
      placement: HeroPlacement.right,
      direction: TextDirection.ltr,
      offset: 4,
    );
    expect(g.side, HeroOverlaySide.right);
    expect(g.rect, const Rect.fromLTWH(194, 290, 100, 60));
    expect(g.anchorAlignment.x, -1);
  });
}
