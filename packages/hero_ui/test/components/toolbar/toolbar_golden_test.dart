import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

List<Widget> _textStyle({
  HeroToggleButtonStyle? style,
  bool separators = true,
}) => <Widget>[
  HeroToggleButton(
    id: 'bold',
    isIconOnly: true,
    semanticLabel: 'Bold',
    style: style,
    child: const HeroIcon(HeroIcons.bold),
  ),
  HeroToggleButton(
    id: 'italic',
    isIconOnly: true,
    semanticLabel: 'Italic',
    style: style,
    separator: separators ? const HeroToggleButtonGroupSeparator() : null,
    child: const HeroIcon(HeroIcons.italic),
  ),
  HeroToggleButton(
    id: 'underline',
    isIconOnly: true,
    semanticLabel: 'Underline',
    style: style,
    separator: separators ? const HeroToggleButtonGroupSeparator() : null,
    child: const HeroIcon(HeroIcons.underline),
  ),
];

Widget _toolbar({
  Axis orientation = Axis.horizontal,
  bool isAttached = false,
  List<Widget>? end,
}) => HeroToolbar(
  orientation: orientation,
  isAttached: isAttached,
  semanticLabel: 'Text formatting',
  children: <Widget>[
    HeroToggleButtonGroup(
      selectionMode: HeroSelectionMode.multiple,
      defaultSelectedKeys: const <Object>{'bold'},
      children: _textStyle(),
    ),
    const HeroSeparator(),
    HeroButtonGroup(
      variant: HeroButtonVariant.tertiary,
      children:
          end ??
          <Widget>[
            HeroButton(
              isIconOnly: true,
              semanticLabel: 'Copy',
              onPressed: () {},
              child: const HeroIcon(HeroIcons.copy),
            ),
            const HeroButtonGroupSeparator(),
            HeroButton(
              isIconOnly: true,
              semanticLabel: 'Cut',
              onPressed: () {},
              child: const HeroIcon(HeroIcons.scissors),
            ),
          ],
    ),
  ],
);

void main() {
  heroGoldenTest(
    'toolbar basic and attached',
    name: 'toolbar_basic',
    size: const Size(300, 160),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.spacing(6),
      children: <Widget>[_toolbar(), _toolbar(isAttached: true)],
    ),
  );

  heroGoldenTest(
    'toolbar vertical',
    name: 'toolbar_vertical',
    size: const Size(200, 300),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.spacing(8),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _toolbar(
          orientation: Axis.vertical,
          end: <Widget>[
            HeroButton(
              isIconOnly: true,
              semanticLabel: 'Undo',
              onPressed: () {},
              child: const HeroIcon(HeroIcons.arrowUturnCcwLeft),
            ),
            const HeroButtonGroupSeparator(),
            HeroButton(
              isIconOnly: true,
              semanticLabel: 'Redo',
              onPressed: () {},
              child: const HeroIcon(HeroIcons.arrowUturnCwRight),
            ),
          ],
        ),
        _toolbar(orientation: Axis.vertical, isAttached: true),
      ],
    ),
  );

  heroGoldenTest(
    'toolbar focus',
    name: 'toolbar_focus',
    size: const Size(300, 90),
    builder: (HeroThemeData theme) => _toolbar(),
    whilePerforming: (WidgetTester tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    },
  );

  heroGoldenTest(
    'toolbar custom styles',
    name: 'toolbar_custom',
    size: const Size(220, 90),
    builder: (HeroThemeData theme) {
      final HeroColors colors = theme.colors;
      bool selected(Set<WidgetState> states) =>
          states.contains(WidgetState.selected);
      return HeroToolbar(
        gap: theme.spacing(1),
        padding: EdgeInsets.all(theme.spacing(1.5)),
        decoration: ShapeDecoration(
          color: colors.surfaceSecondary,
          shape: theme.shapeAll(
            theme.radii.xl,
            side: BorderSide(
              color: colors.border.withValues(alpha: colors.border.a * 0.8),
            ),
          ),
        ),
        children: <Widget>[
          HeroToggleButtonGroup(
            selectionMode: HeroSelectionMode.multiple,
            defaultSelectedKeys: const <Object>{'italic'},
            gap: theme.spacing(0.5),
            children: _textStyle(
              separators: false,
              style: HeroToggleButtonStyle(
                borderRadius: BorderRadius.all(Radius.circular(theme.radii.lg)),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (Set<WidgetState> states) =>
                      selected(states) ? colors.accent : null,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (Set<WidgetState> states) =>
                      selected(states) ? colors.accentForeground : null,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
