import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// Like [heroGoldenTest], but captures one frame of a running animation
/// [elapsed] after the first frame instead of waiting for it to settle.
void _frameGolden(
  String description, {
  required String name,
  required Size size,
  required Duration elapsed,
  required Widget Function(HeroThemeData theme) builder,
}) {
  for (final Brightness brightness in Brightness.values) {
    final String mode = brightness == Brightness.dark ? 'dark' : 'light';
    testWidgets('$description ($mode)', skip: !Platform.isLinux, (
      WidgetTester tester,
    ) async {
      final HeroThemeData theme = HeroThemeData.fromPreset(
        HeroThemePreset.standard,
        brightness: brightness,
      );
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        RepaintBoundary(
          child: heroTestApp(
            Padding(padding: const EdgeInsets.all(16), child: builder(theme)),
            theme: theme,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(elapsed);
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/${name}_$mode.png'),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

Widget _lines(List<double> factors, {double height = 12, double? radius}) =>
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        for (final double factor in factors)
          FractionallySizedBox(
            widthFactor: factor,
            child: HeroSkeleton(
              height: height,
              animationType: HeroSkeletonAnimation.none,
              borderRadius: radius == null
                  ? null
                  : BorderRadius.all(Radius.circular(radius)),
            ),
          ),
      ],
    );

Widget _card(HeroThemeData theme, HeroSkeletonAnimation type) => SizedBox(
  width: 140,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: <Widget>[
      HeroSkeleton(
        height: 80,
        animationType: type,
        borderRadius: BorderRadius.circular(theme.radii.lg),
      ),
      FractionallySizedBox(
        widthFactor: 0.6,
        child: HeroSkeleton(
          height: 12,
          animationType: type,
          borderRadius: BorderRadius.circular(theme.radii.lg),
        ),
      ),
      FractionallySizedBox(
        widthFactor: 0.8,
        child: HeroSkeleton(
          height: 12,
          animationType: type,
          borderRadius: BorderRadius.circular(theme.radii.lg),
        ),
      ),
    ],
  ),
);

void main() {
  heroGoldenTest(
    'shapes',
    name: 'shapes',
    size: const Size(360, 340),
    builder: (HeroThemeData theme) => SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: <Widget>[
          HeroSkeleton(
            height: 96,
            animationType: HeroSkeletonAnimation.none,
            borderRadius: BorderRadius.circular(theme.radii.lg),
          ),
          _lines(<double>[0.6, 0.8, 0.4], radius: theme.radii.lg),
          Row(
            spacing: 12,
            children: <Widget>[
              const HeroSkeleton(
                width: 40,
                height: 40,
                shape: BoxShape.circle,
                animationType: HeroSkeletonAnimation.none,
              ),
              Expanded(child: _lines(<double>[1, 0.8])),
            ],
          ),
          const HeroSkeleton(
            animationType: HeroSkeletonAnimation.none,
            child: Text('Sized by its child'),
          ),
        ],
      ),
    ),
  );

  _frameGolden(
    'shimmer, pulse and none mid-animation',
    name: 'animations',
    size: const Size(500, 180),
    elapsed: const Duration(milliseconds: 1000),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        _card(theme, HeroSkeletonAnimation.shimmer),
        _card(theme, HeroSkeletonAnimation.pulse),
        _card(theme, HeroSkeletonAnimation.none),
      ],
    ),
  );

  _frameGolden(
    'single shimmer group',
    name: 'group',
    size: const Size(420, 160),
    elapsed: const Duration(milliseconds: 900),
    builder: (HeroThemeData theme) => SizedBox(
      width: 360,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: theme.shapeAll(theme.radii.xl)),
        child: HeroSkeletonGroup(
          child: Row(
            spacing: 16,
            children: <Widget>[
              for (int i = 0; i < 3; i++)
                Expanded(
                  child: HeroSkeleton(
                    height: 96,
                    animationType: HeroSkeletonAnimation.none,
                    borderRadius: BorderRadius.circular(theme.radii.xl),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
