import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  Widget tabs({
    HeroTabsVariant variant = HeroTabsVariant.primary,
    Axis orientation = Axis.horizontal,
    HeroTabsAlign align = HeroTabsAlign.center,
    List<String> labels = const <String>['Overview', 'Analytics', 'Reports'],
    Object? selected,
    bool separators = false,
    Set<Object> disabled = const <Object>{},
    bool panels = true,
  }) {
    return HeroTabs(
      variant: variant,
      orientation: orientation,
      align: align,
      defaultSelectedKey: selected,
      disabledKeys: disabled,
      children: <Widget>[
        HeroTabListContainer(
          child: HeroTabList(
            semanticLabel: 'Options',
            children: <Widget>[
              for (int i = 0; i < labels.length; i++)
                HeroTab(
                  id: labels[i],
                  separator: separators && i > 0
                      ? const HeroTabSeparator()
                      : null,
                  child: Text(labels[i]),
                ),
            ],
          ),
        ),
        if (panels)
          for (final String label in labels)
            HeroTabPanel(id: label, child: Text('$label panel')),
      ],
    );
  }

  heroGoldenTest(
    'primary horizontal',
    name: 'tabs_primary',
    size: const Size(420, 260),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        tabs(),
        tabs(
          selected: 'Analytics',
          separators: true,
          labels: const <String>['Overview', 'Analytics', 'Reports', 'Logs'],
          panels: false,
        ),
        tabs(disabled: const <Object>{'Analytics'}, panels: false),
      ],
    ),
  );

  heroGoldenTest(
    'secondary horizontal',
    name: 'tabs_secondary',
    size: const Size(420, 140),
    builder: (HeroThemeData theme) =>
        tabs(variant: HeroTabsVariant.secondary, selected: 'Analytics'),
  );

  heroGoldenTest(
    'vertical primary and secondary',
    name: 'tabs_vertical',
    size: const Size(400, 340),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        tabs(
          orientation: Axis.vertical,
          labels: const <String>['Account', 'Security', 'Notifications'],
          separators: true,
          selected: 'Notifications',
        ),
        tabs(
          variant: HeroTabsVariant.secondary,
          orientation: Axis.vertical,
          align: HeroTabsAlign.start,
          labels: const <String>['General', 'Appearance', 'Privacy'],
          selected: 'Appearance',
        ),
      ],
    ),
  );

  heroGoldenTest(
    'overflow with fades and chevrons',
    name: 'tabs_overflow',
    size: const Size(420, 140),
    whilePerforming: (WidgetTester tester) async {
      await tester.drag(find.text('Reports'), const Offset(-150, 0));
    },
    builder: (HeroThemeData theme) => tabs(
      labels: const <String>[
        'Overview',
        'Analytics',
        'Reports',
        'Performance',
        'Engagement',
        'Audience',
      ],
      panels: false,
    ),
  );

  heroGoldenTest(
    'focus ring and hover',
    name: 'tabs_states',
    size: const Size(420, 100),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      Focus.of(tester.element(find.text('Overview'))).requestFocus();
    },
    builder: (HeroThemeData theme) => tabs(panels: false),
  );

  for (final Brightness brightness in Brightness.values) {
    final String mode = brightness == Brightness.dark ? 'dark' : 'light';
    testWidgets('indicator mid-transition ($mode)', skip: !Platform.isLinux, (
      WidgetTester tester,
    ) async {
      final HeroThemeData theme = HeroThemeData.fromPreset(
        HeroThemePreset.standard,
        brightness: brightness,
      );
      tester.view.physicalSize = const Size(420, 80);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      debugDisableShadows = false;
      try {
        await tester.pumpWidget(
          RepaintBoundary(
            child: heroTestApp(
              Padding(
                padding: const EdgeInsets.all(16),
                child: tabs(panels: false),
              ),
              theme: theme,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reports'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 40));
        await expectLater(
          find.byType(RepaintBoundary).first,
          matchesGoldenFile('goldens/tabs_transition_$mode.png'),
        );
        await tester.pumpAndSettle();
      } finally {
        debugDisableShadows = true;
      }
    });
  }
}
