import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// Matches a render object that fills a rect with [color] (compared at 8-bit
/// precision) and, optionally, [blendMode].
PaintPattern _paintsRect({Color? color, BlendMode? blendMode}) =>
    paints..something((Symbol method, List<dynamic> arguments) {
      if (method != #drawRect) return false;
      final Paint paint = arguments[1] as Paint;
      if (color != null && !_close(paint.color, color)) return false;
      if (blendMode != null && paint.blendMode != blendMode) return false;
      return true;
    });

bool _close(Color a, Color b) =>
    (a.a - b.a).abs() < 0.01 &&
    (a.r - b.r).abs() < 0.01 &&
    (a.g - b.g).abs() < 0.01 &&
    (a.b - b.b).abs() < 0.01;

Finder get _paint => find
    .descendant(
      of: find.byType(HeroSkeleton),
      matching: find.byType(CustomPaint),
    )
    .first;

bool get _ticking => SchedulerBinding.instance.transientCallbackCount > 0;

Future<void> _pumpFrames(WidgetTester tester, Widget widget) async {
  await pumpSkeleton(tester, widget);
}

Future<void> pumpSkeleton(
  WidgetTester tester,
  Widget widget, {
  HeroThemeData? theme,
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    heroTestApp(
      Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
          child: widget,
        ),
      ),
      theme: theme,
    ),
  );
  await tester.pump();
}

void main() {
  final HeroThemeData theme = HeroThemeData.light();
  final Color base = theme.colors.surfaceTertiary.withValues(
    alpha: theme.colors.surfaceTertiary.a * 0.7,
  );

  testWidgets('paints surface-tertiary at 70% with rounded-sm corners', (
    WidgetTester tester,
  ) async {
    await _pumpFrames(
      tester,
      const HeroSkeleton(
        width: 100,
        height: 12,
        animationType: HeroSkeletonAnimation.none,
      ),
    );
    expect(tester.getSize(find.byType(HeroSkeleton)), const Size(100, 12));
    expect(_paint, _paintsRect(color: base));
    // Rounded-sm corners: the very corner is clipped away.
    expect(
      _paint,
      paints..clipPath(
        pathMatcher: isPathThat(
          includes: <Offset>[const Offset(6, 6), const Offset(50, 1)],
          excludes: <Offset>[const Offset(0.3, 0.3)],
        ),
      ),
    );
    expect(_ticking, isFalse);
  });

  testWidgets('fills the available width like a block', (
    WidgetTester tester,
  ) async {
    await _pumpFrames(
      tester,
      const SizedBox(
        width: 240,
        child: Column(
          children: <Widget>[
            HeroSkeleton(height: 16, animationType: HeroSkeletonAnimation.none),
          ],
        ),
      ),
    );
    expect(tester.getSize(find.byType(HeroSkeleton)), const Size(240, 16));
  });

  testWidgets('takes the size of its hidden child', (
    WidgetTester tester,
  ) async {
    await _pumpFrames(
      tester,
      const HeroSkeleton(
        animationType: HeroSkeletonAnimation.none,
        child: SizedBox(width: 60, height: 20),
      ),
    );
    expect(tester.getSize(find.byType(HeroSkeleton)), const Size(60, 20));
    final Visibility visibility = tester.widget(find.byType(Visibility));
    expect(visibility.visible, isFalse);
  });

  testWidgets('does not break an unbounded row', (WidgetTester tester) async {
    await _pumpFrames(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroSkeleton(
            width: 40,
            height: 40,
            shape: BoxShape.circle,
            animationType: HeroSkeletonAnimation.none,
          ),
          HeroSkeleton(height: 12, animationType: HeroSkeletonAnimation.none),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(HeroSkeleton).first), const Size(40, 40));
    // A circle: the corners of the square are outside the shape.
    expect(
      find
          .descendant(
            of: find.byType(HeroSkeleton).first,
            matching: find.byType(CustomPaint),
          )
          .first,
      paints..clipPath(
        pathMatcher: isPathThat(
          includes: <Offset>[const Offset(20, 20)],
          excludes: <Offset>[const Offset(4, 4), const Offset(36, 36)],
        ),
      ),
    );
  });

  testWidgets('shimmer from the theme sweeps a highlight', (
    WidgetTester tester,
  ) async {
    await _pumpFrames(tester, const HeroSkeleton(width: 100, height: 20));
    expect(_ticking, isTrue);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(
      _paint,
      paints
        ..rect(color: base)
        ..rect(),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('theme can pick another default animation', (
    WidgetTester tester,
  ) async {
    await pumpSkeleton(
      tester,
      const HeroSkeleton(width: 100, height: 20),
      theme: theme.copyWith(skeletonAnimation: HeroSkeletonAnimation.none),
    );
    expect(_ticking, isFalse);
  });

  testWidgets('pulse fades to 50% at mid-cycle', (WidgetTester tester) async {
    await _pumpFrames(
      tester,
      const HeroSkeleton(
        width: 100,
        height: 20,
        animationType: HeroSkeletonAnimation.pulse,
      ),
    );
    await tester.pump(const Duration(milliseconds: 1000));
    expect(_paint, _paintsRect(color: base.withValues(alpha: base.a * 0.5)));
    await tester.pump(const Duration(milliseconds: 1000));
    expect(_paint, _paintsRect(color: base));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reduced motion stops the animation', (
    WidgetTester tester,
  ) async {
    await pumpSkeleton(
      tester,
      const HeroSkeleton(
        width: 100,
        height: 20,
        animationType: HeroSkeletonAnimation.pulse,
      ),
      disableAnimations: true,
    );
    expect(_ticking, isFalse);
  });

  testWidgets('respects TickerMode', (WidgetTester tester) async {
    await _pumpFrames(
      tester,
      const TickerMode(
        enabled: false,
        child: HeroSkeleton(width: 100, height: 20),
      ),
    );
    expect(_ticking, isFalse);
  });

  testWidgets('group plays one overlay sweep over its skeletons', (
    WidgetTester tester,
  ) async {
    await _pumpFrames(
      tester,
      const SizedBox(
        width: 300,
        child: HeroSkeletonGroup(
          child: Row(
            spacing: 16,
            children: <Widget>[
              Expanded(
                child: HeroSkeleton(
                  height: 96,
                  animationType: HeroSkeletonAnimation.none,
                ),
              ),
              Expanded(child: HeroSkeleton(height: 96)),
            ],
          ),
        ),
      ),
    );
    // Only the group animates; the children's own shimmer is suppressed.
    await tester.pump(const Duration(milliseconds: 1000));
    for (final Element element in find.byType(HeroSkeleton).evaluate()) {
      expect(
        find
            .descendant(
              of: find.byElementPredicate((Element e) => e == element),
              matching: find.byType(CustomPaint),
            )
            .first,
        _paintsRect(blendMode: BlendMode.overlay),
      );
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('decorative unless labelled', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pumpFrames(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroSkeleton(
            width: 10,
            height: 10,
            animationType: HeroSkeletonAnimation.none,
            child: Text('Hidden content'),
          ),
          HeroSkeleton(
            width: 10,
            height: 10,
            animationType: HeroSkeletonAnimation.none,
            semanticLabel: 'Loading',
          ),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Hidden content'), findsNothing);
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('custom color and RTL', (WidgetTester tester) async {
    const Color custom = Color(0xFF336699);
    await tester.pumpWidget(
      heroTestApp(
        const HeroSkeleton(
          width: 50,
          height: 10,
          color: custom,
          animationType: HeroSkeletonAnimation.none,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
    expect(_paint, _paintsRect(color: custom));
    expect(tester.takeException(), isNull);
  });
}
