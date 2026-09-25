import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _xl(Widget child) => SizedBox(width: 480, child: child);

HeroThemeData _still() => HeroThemeData.light().copyWith(
  motion: const HeroMotion(reduceMotion: true),
);

Color? _textColor(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

void main() {
  testWidgets('lays out indicator, title and description', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _xl(
        const HeroAlert(
          title: Text('New features available'),
          description: Text('Check out our latest updates.'),
        ),
      ),
    );
    final HeroThemeData theme = HeroThemeData.light();
    final Rect alert = tester.getRect(find.byType(HeroAlert));
    final Rect indicator = tester.getRect(find.byType(HeroAlertIndicator));
    final Rect title = tester.getRect(find.text('New features available'));
    final Rect description = tester.getRect(
      find.text('Check out our latest updates.'),
    );
    expect(alert.width, 480);
    expect(indicator.size, const Size(24, 24));
    expect(indicator.topLeft, alert.topLeft + const Offset(16, 12));
    expect(title.left, indicator.right + 16);
    expect(title.top, alert.top + 12);
    expect(title.height, 24);
    expect(description.top, title.bottom);
    expect(alert.bottom, description.bottom + 12);
    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(HeroAlertIndicator),
          matching: find.byType(HeroIcon),
        ),
      ),
      const Size(16, 16),
    );
    expect(
      _textColor(tester, 'New features available'),
      theme.colors.foreground,
    );
    expect(
      _textColor(tester, 'Check out our latest updates.'),
      theme.colors.muted,
    );
    expect(tester.widget<HeroIcon>(find.byType(HeroIcon)).icon, HeroIcons.info);
  });

  testWidgets('each status has its icon and color', (
    WidgetTester tester,
  ) async {
    final HeroColors colors = HeroThemeData.light().colors;
    final Map<HeroColor, (HeroIconData, Color)> expected =
        <HeroColor, (HeroIconData, Color)>{
          HeroColor.standard: (HeroIcons.info, colors.foreground),
          HeroColor.accent: (HeroIcons.info, colors.accentSoftForeground),
          HeroColor.success: (HeroIcons.success, colors.successSoftForeground),
          HeroColor.warning: (HeroIcons.warning, colors.warningSoftForeground),
          HeroColor.danger: (HeroIcons.danger, colors.dangerSoftForeground),
        };
    for (final MapEntry<HeroColor, (HeroIconData, Color)> entry
        in expected.entries) {
      await pumpHero(
        tester,
        _xl(HeroAlert(status: entry.key, title: const Text('Title'))),
      );
      expect(HeroAlert.iconOf(entry.key), entry.value.$1);
      expect(
        tester.widget<HeroIcon>(find.byType(HeroIcon)).icon,
        entry.value.$1,
      );
      final IconThemeData icon = IconTheme.of(
        tester.element(find.byType(HeroIcon)),
      );
      expect(icon.color, entry.value.$2);
      expect(_textColor(tester, 'Title'), entry.value.$2);
    }
  });

  testWidgets('composes parts; the content takes the free width', (
    WidgetTester tester,
  ) async {
    int refreshed = 0;
    await pumpHero(
      tester,
      _xl(
        HeroAlert(
          status: HeroColor.accent,
          children: <Widget>[
            const HeroAlertIndicator(),
            const HeroAlertContent(
              children: <Widget>[
                HeroAlertTitle.text('Update available'),
                HeroAlertDescription.text('Please refresh.'),
              ],
            ),
            HeroButton(
              size: HeroSize.sm,
              onPressed: () => refreshed++,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
    final Rect alert = tester.getRect(find.byType(HeroAlert));
    final Rect content = tester.getRect(find.byType(HeroAlertContent));
    final Rect button = tester.getRect(find.byType(HeroButton));
    expect(button.right, alert.right - 16);
    expect(button.top, alert.top + 12);
    expect(content.right, button.left - 16);
    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();
    expect(refreshed, 1);
  });

  testWidgets('custom indicators, no indicator and end content', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _xl(
        const HeroAlert(
          status: HeroColor.accent,
          indicator: HeroSpinner(size: HeroSpinnerSize.sm),
          title: Text('Processing your request'),
        ),
      ),
      theme: _still(),
    );
    expect(find.byType(HeroSpinner), findsOneWidget);
    expect(find.byType(HeroIcon), findsNothing);
    expect(tester.getSize(find.byType(HeroAlertIndicator)), const Size(24, 24));

    bool closed = false;
    await pumpHero(
      tester,
      _xl(
        HeroAlert(
          status: HeroColor.success,
          showIndicator: false,
          title: const Text('Profile updated successfully'),
          endContent: HeroCloseButton(onPressed: () => closed = true),
        ),
      ),
    );
    expect(find.byType(HeroAlertIndicator), findsNothing);
    final Rect alert = tester.getRect(find.byType(HeroAlert));
    expect(
      tester.getRect(find.byType(HeroCloseButton)).right,
      alert.right - 16,
    );
    await tester.tap(find.byType(HeroCloseButton));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
  });

  testWidgets('provides a standard surface to its descendants', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _xl(const HeroAlert(title: Text('Title'))));
    expect(
      HeroSurfaceScope.variantOf(tester.element(find.text('Title'))),
      HeroSurfaceVariant.standard,
    );
  });

  testWidgets('announces changes when live', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      _xl(
        const HeroAlert(
          isLive: true,
          semanticLabel: 'Connection error',
          title: Text('Unable to connect'),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(HeroAlert)),
      isSemantics(label: 'Connection error', isLiveRegion: true),
    );
    await pumpHero(tester, _xl(const HeroAlert(title: Text('Quiet'))));
    expect(
      tester.getSemantics(find.byType(HeroAlert)),
      isNot(isSemantics(isLiveRegion: true)),
    );
    expect(find.bySemanticsLabel('Quiet'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('mirrors in right-to-left layouts', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _xl(const HeroAlert(title: Text('Title'), endContent: HeroCloseButton())),
      textDirection: TextDirection.rtl,
    );
    final Rect alert = tester.getRect(find.byType(HeroAlert));
    expect(
      tester.getRect(find.byType(HeroAlertIndicator)).right,
      alert.right - 16,
    );
    expect(tester.getRect(find.byType(HeroCloseButton)).left, alert.left + 16);
  });

  testWidgets('wraps at 2x text without overflow', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _xl(
        const HeroAlert(
          status: HeroColor.warning,
          title: Text('Scheduled maintenance'),
          description: Text(
            'Our services will be unavailable on Sunday, March 15th from '
            '2:00 AM to 6:00 AM UTC for scheduled maintenance.',
          ),
          endContent: HeroCloseButton(),
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('is 576 wide where the width is unbounded', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[HeroAlert(title: Text('Title'))],
      ),
      surfaceSize: const Size(800, 600),
    );
    expect(tester.getSize(find.byType(HeroAlert)).width, 576);
  });

  testWidgets('style overrides and a clipped background layer', (
    WidgetTester tester,
  ) async {
    const Color border = Color(0xFFFFAA00);
    await pumpHero(
      tester,
      _xl(
        const HeroAlert(
          status: HeroColor.warning,
          style: HeroAlertStyle(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            border: BorderSide(color: border),
            shadows: <BoxShadow>[],
          ),
          background: SizedBox.expand(key: Key('background')),
          title: Text('Payment method expires soon'),
        ),
      ),
    );
    // Like an absolutely positioned element, the layer covers the padding
    // box, inside the 1 px border.
    expect(
      tester.getRect(find.byKey(const Key('background'))),
      tester.getRect(find.byType(HeroAlert)).deflate(1),
    );
    final HeroSurface surface = tester.widget<HeroSurface>(
      find.byType(HeroSurface),
    );
    expect(surface.border, const BorderSide(color: border));
    expect(surface.clipBehavior, Clip.antiAlias);
    expect(surface.borderRadius, const BorderRadius.all(Radius.circular(12)));
  });

  testWidgets('the radius is min(32, --radius-3xl)', (
    WidgetTester tester,
  ) async {
    BorderRadiusGeometry? radius() =>
        tester.widget<HeroSurface>(find.byType(HeroSurface)).borderRadius;
    await pumpHero(tester, _xl(const HeroAlert(title: Text('Title'))));
    expect(radius(), const BorderRadius.all(Radius.circular(24)));
    await pumpHero(
      tester,
      _xl(const HeroAlert(title: Text('Title'))),
      theme: HeroThemeData.light().copyWith(radii: const HeroRadii(radius: 16)),
    );
    expect(radius(), const BorderRadius.all(Radius.circular(32)));
  });
}
