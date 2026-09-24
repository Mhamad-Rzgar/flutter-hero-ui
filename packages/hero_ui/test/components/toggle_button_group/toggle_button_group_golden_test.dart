import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  const List<(String, HeroIconData)> formattingItems = <(String, HeroIconData)>[
    ('bold', HeroIcons.bold),
    ('italic', HeroIcons.italic),
    ('underline', HeroIcons.underline),
    ('strikethrough', HeroIcons.strikethrough),
  ];

  List<Widget> formatting({bool separators = true, int count = 4}) => <Widget>[
    for (int i = 0; i < count; i++)
      HeroToggleButton(
        id: formattingItems[i].$1,
        isIconOnly: true,
        semanticLabel: formattingItems[i].$1,
        separator: separators && i > 0
            ? const HeroToggleButtonGroupSeparator()
            : null,
        child: HeroIcon(formattingItems[i].$2),
      ),
  ];

  List<Widget> alignment() => const <Widget>[
    HeroToggleButton(
      id: 'left',
      startContent: HeroIcon(HeroIcons.textAlignLeft),
      child: Text('Left'),
    ),
    HeroToggleButton(
      id: 'center',
      separator: HeroToggleButtonGroupSeparator(),
      startContent: HeroIcon(HeroIcons.textAlignCenter),
      child: Text('Center'),
    ),
    HeroToggleButton(
      id: 'right',
      separator: HeroToggleButtonGroupSeparator(),
      startContent: HeroIcon(HeroIcons.textAlignRight),
      child: Text('Right'),
    ),
  ];

  heroGoldenTest(
    'attached, without separators and detached',
    name: 'toggle_button_group_layouts',
    size: const Size(360, 220),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        HeroToggleButtonGroup(
          selectionMode: HeroSelectionMode.multiple,
          defaultSelectedKeys: const <Object>{'bold', 'underline'},
          children: formatting(),
        ),
        HeroToggleButtonGroup(
          selectionMode: HeroSelectionMode.multiple,
          children: formatting(separators: false),
        ),
        HeroToggleButtonGroup(
          isDetached: true,
          selectionMode: HeroSelectionMode.multiple,
          defaultSelectedKeys: const <Object>{'italic'},
          children: formatting(separators: false),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'sizes',
    name: 'toggle_button_group_sizes',
    size: const Size(360, 220),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final HeroSize size in HeroSize.values)
          HeroToggleButtonGroup(
            size: size,
            selectionMode: HeroSelectionMode.multiple,
            defaultSelectedKeys: const <Object>{'italic'},
            children: formatting(),
          ),
      ],
    ),
  );

  heroGoldenTest(
    'orientation and single selection',
    name: 'toggle_button_group_orientation',
    size: const Size(420, 200),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: <Widget>[
        HeroToggleButtonGroup(
          orientation: Axis.vertical,
          selectionMode: HeroSelectionMode.multiple,
          defaultSelectedKeys: const <Object>{'bold'},
          children: formatting(count: 3),
        ),
        HeroToggleButtonGroup(
          defaultSelectedKeys: const <Object>{'center'},
          children: alignment(),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'full width and disabled',
    name: 'toggle_button_group_full_width',
    size: const Size(400, 220),
    builder: (HeroThemeData theme) => SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          HeroToggleButtonGroup(
            fullWidth: true,
            selectionMode: HeroSelectionMode.multiple,
            children: formatting(),
          ),
          HeroToggleButtonGroup(
            fullWidth: true,
            defaultSelectedKeys: const <Object>{'center'},
            children: alignment(),
          ),
          HeroToggleButtonGroup(
            isDisabled: true,
            selectionMode: HeroSelectionMode.multiple,
            defaultSelectedKeys: const <Object>{'bold'},
            children: formatting(count: 3),
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'inset focus ring',
    name: 'toggle_button_group_focus',
    size: const Size(300, 100),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      Focus.of(tester.element(find.byType(HeroIcon).at(1))).requestFocus();
    },
    builder: (HeroThemeData theme) => HeroToggleButtonGroup(
      selectionMode: HeroSelectionMode.multiple,
      defaultSelectedKeys: const <Object>{'bold'},
      children: formatting(),
    ),
  );
}
