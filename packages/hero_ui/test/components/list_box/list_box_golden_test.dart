import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

List<Widget> _users({Widget? indicator = const HeroListBoxItemIndicator()}) =>
    <Widget>[
      for (final (String id, String name, HeroColor color)
          in <(String, String, HeroColor)>[
            ('1', 'Bob', HeroColor.accent),
            ('2', 'Fred', HeroColor.success),
            ('3', 'Martha', HeroColor.warning),
          ])
        HeroListBoxItem(
          id: id,
          textValue: name,
          startContent: HeroAvatar(
            size: HeroSize.sm,
            color: color,
            fallback: Text(name[0]),
          ),
          label: name,
          description: '${name.toLowerCase()}@heroui.com',
          indicator: indicator,
        ),
    ];

Widget _fileActions(
  HeroThemeData theme, {
  Set<Object> disabled = const <Object>{},
  double width = 256,
}) {
  Widget icon(HeroIconData data, Color color) => SizedBox(
    height: theme.spacing(8),
    child: Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 1),
        child: HeroIcon(data, color: color),
      ),
    ),
  );
  return HeroSurface(
    width: width,
    borderRadius: BorderRadius.circular(theme.radii.xl3),
    shadow: theme.shadows.surface,
    child: HeroListBox(
      semanticLabel: 'File actions',
      padding: EdgeInsets.all(theme.spacing(2)),
      disabledKeys: disabled,
      children: <Widget>[
        HeroListBoxSection(
          header: const HeroHeader.text('Actions'),
          children: <Widget>[
            HeroListBoxItem(
              id: 'new-file',
              startContent: icon(HeroIcons.squarePlus, theme.colors.muted),
              label: 'New file',
              description: 'Create a new file',
              endContent: const HeroKbd(
                variant: HeroKbdVariant.light,
                keys: <HeroKbdKey>[HeroKbdKey.command],
                text: 'N',
              ),
            ),
            HeroListBoxItem(
              id: 'edit-file',
              startContent: icon(HeroIcons.pencil, theme.colors.muted),
              label: 'Edit file',
              description: 'Make changes',
              endContent: const HeroKbd(
                variant: HeroKbdVariant.light,
                keys: <HeroKbdKey>[HeroKbdKey.command],
                text: 'E',
              ),
            ),
          ],
        ),
        const HeroSeparator(),
        HeroListBoxSection(
          header: const HeroHeader.text('Danger zone'),
          children: <Widget>[
            HeroListBoxItem(
              id: 'delete-file',
              variant: HeroListBoxVariant.danger,
              startContent: icon(HeroIcons.trashBin, theme.colors.danger),
              label: 'Delete file',
              description: 'Move to trash',
              endContent: const HeroKbd(
                variant: HeroKbdVariant.light,
                keys: <HeroKbdKey>[HeroKbdKey.command, HeroKbdKey.shift],
                text: 'D',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void main() {
  heroGoldenTest(
    'single and multiple selection',
    name: 'selection',
    size: const Size(520, 260),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        SizedBox(
          width: 220,
          child: HeroListBox(
            semanticLabel: 'Users',
            selectionMode: HeroSelectionMode.single,
            defaultSelectedKeys: const <Object>{'1'},
            children: _users(),
          ),
        ),
        HeroSurface(
          width: 240,
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          shadow: theme.shadows.surface,
          child: HeroListBox(
            semanticLabel: 'Users',
            selectionMode: HeroSelectionMode.multiple,
            defaultSelectedKeys: const <Object>{'1', '3'},
            children: _users(
              indicator: HeroListBoxItemIndicator(
                builder: (BuildContext context, bool isSelected) => isSelected
                    ? HeroIcon(
                        HeroIcons.check,
                        color: theme.colors.accentSoftForeground,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'sections, shortcuts, danger and disabled',
    name: 'sections',
    size: const Size(520, 300),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        _fileActions(theme, width: 236),
        _fileActions(
          theme,
          width: 236,
          disabled: const <Object>{'delete-file'},
        ),
      ],
    ),
  );

  heroGoldenTest(
    'hover, keyboard focus and RTL',
    name: 'states',
    size: const Size(520, 260),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        SizedBox(
          width: 220,
          child: HeroListBox(
            semanticLabel: 'Hover',
            selectionMode: HeroSelectionMode.single,
            children: _users(),
          ),
        ),
        SizedBox(
          width: 220,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: HeroListBox(
              semanticLabel: 'Keyboard',
              selectionMode: HeroSelectionMode.single,
              defaultSelectedKeys: const <Object>{'2'},
              children: _users(),
            ),
          ),
        ),
      ],
    ),
    whilePerforming: (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(
        location: tester.getCenter(find.text('Fred').first),
      );
      addTearDown(mouse.removePointer);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    },
  );

  heroGoldenTest(
    'custom styles',
    name: 'custom',
    size: const Size(320, 200),
    builder: (HeroThemeData theme) => SizedBox(
      width: 224,
      child: HeroSurface(
        borderRadius: BorderRadius.circular(theme.radii.xl),
        border: BorderSide(
          color: theme.colors.border.withValues(
            alpha: theme.colors.border.a * 0.8,
          ),
        ),
        shadow: theme.shadows.surface,
        child: HeroListBox(
          semanticLabel: 'Assignee',
          selectionMode: HeroSelectionMode.single,
          defaultSelectedKeys: const <Object>{'1'},
          itemStyle: HeroListBoxItemStyle(
            borderRadius: BorderRadius.circular(theme.radii.lg),
            backgroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) => states.contains(WidgetState.focused)
                  ? theme.colors.accent.withValues(alpha: 0.1)
                  : states.contains(WidgetState.selected)
                  ? theme.colors.accent.withValues(alpha: 0.05)
                  : null,
            ),
          ),
          children: _users().take(2).toList(),
        ),
      ),
    ),
  );

  heroGoldenTest(
    'virtualized rows and empty state',
    name: 'virtualized',
    size: const Size(520, 360),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        SizedBox(
          width: 260,
          height: 320,
          child: HeroListBox.builder(
            semanticLabel: 'Virtualized',
            virtualized: true,
            rowHeight: 50,
            itemCount: 1000,
            itemBuilder: (BuildContext context, int index) => HeroListBoxItem(
              id: index,
              label: 'User ${index + 1}',
              description: 'user${index + 1}@acme.com',
              indicator: const HeroListBoxItemIndicator(),
            ),
          ),
        ),
        SizedBox(
          width: 200,
          child: HeroSurface(
            borderRadius: BorderRadius.circular(theme.radii.xl3),
            shadow: theme.shadows.surface,
            child: HeroListBox(
              semanticLabel: 'Empty',
              emptyStateBuilder: (BuildContext context) =>
                  const HeroEmptyState(),
            ),
          ),
        ),
      ],
    ),
  );
}
