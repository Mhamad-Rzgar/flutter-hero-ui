import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

List<Widget> _tags(List<String> names, {bool icons = false}) => <Widget>[
  for (final String name in names)
    HeroTag(
      id: name.toLowerCase(),
      startContent: icons ? HeroIcon(_icons[name]!) : null,
      label: name,
    ),
];

const Map<String, HeroIconData> _icons = <String, HeroIconData>{
  'News': HeroIcons.squareArticle,
  'Travel': HeroIcons.planetEarth,
  'Gaming': HeroIcons.rocket,
  'Shopping': HeroIcons.shoppingBag,
};

void main() {
  heroGoldenTest(
    'sizes and variants',
    name: 'sizes',
    size: const Size(420, 360),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        for (final (HeroSize size, String label) in <(HeroSize, String)>[
          (HeroSize.sm, 'Small'),
          (HeroSize.md, 'Medium'),
          (HeroSize.lg, 'Large'),
        ])
          HeroTagGroup(
            label: label,
            size: size,
            selectionMode: HeroSelectionMode.single,
            defaultSelectedKeys: const <Object>{'travel'},
            children: <Widget>[
              HeroTagGroupList(
                children: _tags(<String>['News', 'Travel', 'Gaming']),
              ),
            ],
          ),
        HeroSurface(
          variant: HeroSurfaceVariant.secondary,
          padding: EdgeInsets.all(theme.spacing(3)),
          borderRadius: BorderRadius.circular(theme.radii.xl2),
          child: HeroTagGroup(
            label: 'Surface',
            variant: HeroTagVariant.surface,
            selectionMode: HeroSelectionMode.single,
            defaultSelectedKeys: const <Object>{'news'},
            children: <Widget>[
              HeroTagGroupList(
                children: _tags(<String>['News', 'Travel', 'Gaming']),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'icons, disabled, remove buttons and description',
    name: 'states',
    size: const Size(420, 320),
    builder: (HeroThemeData theme) => SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroTagGroup(
            semanticLabel: 'Tags',
            selectionMode: HeroSelectionMode.single,
            defaultSelectedKeys: const <Object>{'news'},
            children: <Widget>[
              HeroTagGroupList(
                children: _tags(<String>[
                  'News',
                  'Travel',
                  'Gaming',
                  'Shopping',
                ], icons: true),
              ),
            ],
          ),
          HeroTagGroup(
            label: 'Disabled Tags',
            description: 'Some tags are disabled',
            selectionMode: HeroSelectionMode.single,
            disabledKeys: const <Object>{'travel'},
            children: <Widget>[
              HeroTagGroupList(
                children: _tags(<String>['News', 'Travel', 'Gaming']),
              ),
            ],
          ),
          HeroTagGroup(
            label: 'Removable',
            selectionMode: HeroSelectionMode.multiple,
            defaultSelectedKeys: const <Object>{'vue'},
            onRemove: (_) {},
            children: <Widget>[
              HeroTagGroupList(
                children: <Widget>[
                  const HeroTag(id: 'react', label: 'React'),
                  const HeroTag(id: 'vue', label: 'Vue'),
                  const HeroTag(
                    id: 'svelte',
                    label: 'Svelte',
                    removeButton: HeroTagRemoveButton(
                      child: HeroIcon(HeroIcons.circleXmarkFill),
                    ),
                  ),
                  HeroTag(
                    id: 'solid',
                    builder: (BuildContext context, HeroTagState state) =>
                        Text(state.allowsRemoving ? 'Solid (removable)' : ''),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'hover, keyboard focus, RTL and empty state',
    name: 'interaction',
    size: const Size(420, 220),
    builder: (HeroThemeData theme) => SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroTagGroup(
            semanticLabel: 'Hover',
            selectionMode: HeroSelectionMode.single,
            defaultSelectedKeys: const <Object>{'gaming'},
            children: <Widget>[
              HeroTagGroupList(
                children: _tags(<String>['News', 'Travel', 'Gaming']),
              ),
            ],
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: HeroTagGroup(
              label: 'Keyboard',
              onRemove: (_) {},
              children: <Widget>[
                HeroTagGroupList(
                  children: _tags(<String>['News', 'Travel', 'Gaming']),
                ),
              ],
            ),
          ),
          HeroTagGroup(
            label: 'Empty',
            children: <Widget>[
              HeroTagGroupList(
                emptyStateBuilder: (BuildContext context) => HeroEmptyState(
                  padding: EdgeInsets.all(theme.spacing(1)),
                  child: const Text('No categories found'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    whilePerforming: (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(
        location: tester.getCenter(find.text('Travel').first),
      );
      addTearDown(mouse.removePointer);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    },
  );

  heroGoldenTest(
    'custom styles',
    name: 'custom',
    size: const Size(420, 120),
    builder: (HeroThemeData theme) {
      final HeroColors colors = theme.colors;
      final HeroTagStyle style = HeroTagStyle(
        borderRadius: BorderRadius.circular(theme.radii.full),
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing(2.5),
          vertical: theme.spacing(1),
        ),
        gap: theme.spacing(1.5),
        textStyle: theme.typography.sm,
        iconSize: theme.spacing(4),
        shadows: theme.shadows.surface.boxShadows,
        backgroundColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? colors.foreground
              : colors.surface,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? colors.background
              : colors.foreground,
        ),
        iconColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.selected) ? null : colors.muted,
        ),
        side: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? colors.muted
                : colors.border,
          ),
        ),
      );
      return HeroTagGroup(
        semanticLabel: 'Topics',
        selectionMode: HeroSelectionMode.single,
        defaultSelectedKeys: const <Object>{'travel'},
        children: <Widget>[
          HeroTagGroupList(
            spacing: theme.spacing(2),
            children: <Widget>[
              for (final MapEntry<String, HeroIconData> entry in _icons.entries)
                HeroTag(
                  id: entry.key.toLowerCase(),
                  style: style,
                  startContent: HeroIcon(entry.value),
                  label: entry.key,
                ),
            ],
          ),
        ],
      );
    },
  );
}
