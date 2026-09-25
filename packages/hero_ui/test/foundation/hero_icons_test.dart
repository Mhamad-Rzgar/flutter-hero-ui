import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

void main() {
  test('icons carry no clip-path rectangle covering the view box', () {
    // Gravity UI wraps some icons in a clip path whose rectangle must not be
    // painted as a shape.
    const List<HeroIconData> icons = <HeroIconData>[
      HeroIcons.chevronsExpandVertical,
      HeroIcons.rocket,
      HeroIcons.volumeFill,
      HeroIcons.volumeSlashFill,
      HeroIcons.chartColumn,
      HeroIcons.chartLine,
      HeroIcons.chartAreaStacked,
      HeroIcons.chartBar,
      HeroIcons.cloudArrowUpIn,
      HeroIcons.bug,
    ];
    for (final HeroIconData icon in icons) {
      expect(
        icon.paths.map((HeroIconPath path) => path.data),
        isNot(contains('M0 0h16v16H0z')),
      );
    }
  });
}
