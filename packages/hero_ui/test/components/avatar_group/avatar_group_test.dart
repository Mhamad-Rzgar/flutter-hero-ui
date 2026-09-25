import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroThemeData theme = HeroThemeData.light();

  List<Widget> avatars(int count) => <Widget>[
    for (int i = 0; i < count; i++) HeroAvatar(fallback: Text('U$i')),
  ];

  testWidgets('stacks avatars with an 8 px overlap', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, HeroAvatarGroup(children: avatars(4)));
    expect(
      tester.getSize(find.byType(HeroAvatarGroup)),
      const Size(4 * 40 - 3 * 8, 40),
    );
    final double first = tester.getTopLeft(find.byType(HeroAvatar).at(0)).dx;
    final double second = tester.getTopLeft(find.byType(HeroAvatar).at(1)).dx;
    expect(second - first, 32);
  });

  testWidgets('max truncates and adds a +N count', (WidgetTester tester) async {
    await pumpHero(tester, HeroAvatarGroup(max: 3, children: avatars(5)));
    expect(find.text('U2'), findsOneWidget);
    expect(find.text('U3'), findsNothing);
    expect(find.text('+2'), findsOneWidget);
    expect(find.byType(HeroAvatarGroupCount), findsOneWidget);

    await pumpHero(tester, HeroAvatarGroup(max: 5, children: avatars(5)));
    expect(find.byType(HeroAvatarGroupCount), findsNothing);
  });

  testWidgets('an explicit count replaces the automatic one', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroAvatarGroup(
        max: 2,
        size: HeroSize.sm,
        children: <Widget>[
          ...avatars(3),
          const HeroAvatarGroupCount(child: Text('+9')),
        ],
      ),
    );
    expect(find.text('+9'), findsOneWidget);
    expect(find.text('+1'), findsNothing);
    expect(
      tester.getSize(find.byType(HeroAvatarGroupCount)),
      const Size.square(32),
    );
  });

  testWidgets('group size, color and variant apply to avatars', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroAvatarGroup(
        size: HeroSize.lg,
        color: HeroColor.accent,
        variant: HeroAvatarVariant.soft,
        children: <Widget>[
          HeroAvatar(fallback: Text('A')),
          HeroAvatar(size: HeroSize.sm, fallback: Text('B')),
        ],
      ),
      theme: theme,
    );
    expect(tester.getSize(find.byType(HeroAvatar).first), const Size(48, 48));
    expect(tester.getSize(find.byType(HeroAvatar).last), const Size(32, 32));
    expect(
      DefaultTextStyle.of(tester.element(find.text('A'))).style.color,
      theme.colors.accentSoftForeground,
    );
  });

  testWidgets('clip cuts every avatar but the last', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, HeroAvatarGroup(children: avatars(3)));
    final Iterable<ClipPath> clips = tester.widgetList<ClipPath>(
      find.byWidgetPredicate(
        (Widget w) => w is ClipPath && w.clipper is HeroAvatarGroupClipper,
      ),
    );
    expect(clips, hasLength(2));
    final Path path = const HeroAvatarGroupClipper(
      overlap: 8,
      seam: 2,
      textDirection: TextDirection.ltr,
    ).getClip(const Size(40, 40));
    // Cut radius 22 around (52, 20): (31, 20) is inside the cut.
    expect(path.contains(const Offset(29, 20)), isTrue);
    expect(path.contains(const Offset(31, 20)), isFalse);
    expect(path.contains(const Offset(35, 2)), isTrue);
    final Path rtl = const HeroAvatarGroupClipper(
      overlap: 8,
      seam: 2,
      textDirection: TextDirection.rtl,
    ).getClip(const Size(40, 40));
    expect(rtl.contains(const Offset(9, 20)), isFalse);
    expect(rtl.contains(const Offset(11, 20)), isTrue);
  });

  testWidgets('fallbacks of clipped avatars get the optical nudge', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, HeroAvatarGroup(children: avatars(2)));
    final double firstOffset =
        tester.getCenter(find.text('U0')).dx -
        tester.getCenter(find.byType(HeroAvatar).at(0)).dx;
    final double lastOffset =
        tester.getCenter(find.text('U1')).dx -
        tester.getCenter(find.byType(HeroAvatar).at(1)).dx;
    expect(firstOffset, closeTo(-8 * 0.35 / 2, 0.01));
    expect(lastOffset, 0);
  });

  testWidgets('ring overlap paints a background seam on every avatar', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroAvatarGroup(
        overlap: HeroAvatarGroupOverlap.ring,
        children: avatars(3),
      ),
    );
    expect(
      find.byWidgetPredicate(
        (Widget w) => w is ClipPath && w.clipper is HeroAvatarGroupClipper,
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(HeroAvatarGroup),
        matching: find.byWidgetPredicate(
          (Widget w) =>
              w is CustomPaint &&
              w.painter.runtimeType.toString() == '_RingPainter',
        ),
      ),
      findsNWidgets(3),
    );
  });

  testWidgets('custom overlap distance and grid layout', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroAvatarGroup(overlapDistance: 11.2, children: avatars(2)),
    );
    expect(tester.getSize(find.byType(HeroAvatarGroup)).width, 80 - 11.2);

    await pumpHero(
      tester,
      SizedBox(
        width: 150,
        child: HeroAvatarGroup(isGrid: true, max: 5, children: avatars(5)),
      ),
    );
    final Offset a = tester.getTopLeft(find.byType(HeroAvatar).at(0));
    final Offset b = tester.getTopLeft(find.byType(HeroAvatar).at(1));
    final Offset d = tester.getTopLeft(find.byType(HeroAvatar).at(3));
    expect(b.dx - a.dx, 52);
    expect(d.dy - a.dy, 52);
    expect(
      find.byWidgetPredicate(
        (Widget w) => w is ClipPath && w.clipper is HeroAvatarGroupClipper,
      ),
      findsNothing,
    );
  });

  testWidgets('RTL stacks from the right; later avatars are hit first', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroAvatarGroup(children: avatars(2)),
      textDirection: TextDirection.rtl,
    );
    expect(
      tester.getCenter(find.byType(HeroAvatar).at(0)).dx,
      greaterThan(tester.getCenter(find.byType(HeroAvatar).at(1)).dx),
    );
    final Rect group = tester.getRect(find.byType(HeroAvatarGroup));
    expect(tester.getTopRight(find.byType(HeroAvatar).at(0)).dx, group.right);
  });

  testWidgets('semantic label wraps the group', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      HeroAvatarGroup(semanticLabel: 'Assignees', children: avatars(2)),
    );
    expect(find.bySemanticsLabel('Assignees'), findsOneWidget);
    expect(find.bySemanticsLabel('U0'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('2x text scale keeps avatar sizes without overflow', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroAvatarGroup(max: 2, children: avatars(4)),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(HeroAvatarGroup)).height, 40);
  });
}
