import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

HeroCheckbox _checkbox(
  String label, {
  bool selected = false,
  bool indeterminate = false,
  bool? invalid,
  bool disabled = false,
  HeroFieldVariant? variant,
  String? description,
  String? error,
}) {
  return HeroCheckbox(
    label: label,
    description: description,
    errorMessage: error,
    isSelected: selected,
    isIndeterminate: indeterminate,
    isInvalid: invalid,
    isDisabled: disabled,
    variant: variant,
  );
}

Widget _column(List<Widget> children, {double spacing = 16}) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: spacing,
  children: children,
);

void main() {
  heroGoldenTest(
    'unchecked, checked, indeterminate and description',
    name: 'states',
    size: const Size(360, 240),
    builder: (HeroThemeData theme) => _column(<Widget>[
      _checkbox('Accept terms and conditions'),
      _checkbox('Enable email notifications', selected: true),
      _checkbox('Select all', indeterminate: true),
      _checkbox(
        'Email notifications',
        selected: true,
        description: 'Get notified when someone mentions you in a comment',
      ),
    ]),
  );

  heroGoldenTest(
    'primary and secondary variants on a surface',
    name: 'variants',
    size: const Size(400, 280),
    builder: (HeroThemeData theme) => HeroSurface(
      padding: EdgeInsets.all(theme.spacing(6)),
      borderRadius: BorderRadius.circular(theme.radii.xl3),
      child: _column(<Widget>[
        _checkbox('Primary checkbox', description: 'Standard styling'),
        _checkbox('Primary checked', selected: true),
        _checkbox(
          'Secondary checkbox',
          variant: HeroFieldVariant.secondary,
          description: 'Lower emphasis variant for use in surfaces',
        ),
        _checkbox(
          'Secondary checked',
          selected: true,
          variant: HeroFieldVariant.secondary,
        ),
      ]),
    ),
  );

  heroGoldenTest(
    'invalid and disabled',
    name: 'invalid_disabled',
    size: const Size(360, 300),
    builder: (HeroThemeData theme) => _column(<Widget>[
      _checkbox(
        'I agree to the terms',
        invalid: true,
        error: 'You must accept the terms to continue',
      ),
      _checkbox('Invalid checked', selected: true, invalid: true),
      _checkbox('Invalid indeterminate', indeterminate: true, invalid: true),
      _checkbox(
        'Premium Feature',
        disabled: true,
        description: 'This feature is coming soon',
      ),
      _checkbox('Disabled checked', selected: true, disabled: true),
    ]),
  );

  heroGoldenTest(
    'rounded sizes and custom styles',
    name: 'custom',
    size: const Size(360, 260),
    builder: (HeroThemeData theme) {
      HeroCheckbox rounded(String label, double size, double? mark) =>
          HeroCheckbox(
            defaultSelected: true,
            children: <Widget>[
              HeroCheckboxContent(
                children: <Widget>[
                  HeroCheckboxControl(
                    size: size,
                    borderRadius: BorderRadius.circular(theme.radii.full),
                    child: HeroCheckboxIndicator(size: mark),
                  ),
                  Text(label),
                ],
              ),
            ],
          );
      return _column(<Widget>[
        rounded('Small size', theme.spacing(3), theme.spacing(2)),
        rounded('Default size', theme.spacing(4), null),
        rounded('Large size', theme.spacing(5), null),
        rounded('Extra large size', theme.spacing(6), theme.spacing(4)),
        HeroCheckbox(
          defaultSelected: true,
          children: <Widget>[
            HeroCheckboxContent(
              children: <Widget>[
                HeroCheckboxControl(
                  color: theme.colors.successSoft,
                  selectedColor: theme.colors.success,
                  child: HeroCheckboxIndicator(
                    color: theme.colors.successForeground,
                  ),
                ),
                const Text('Custom styled checkbox'),
              ],
            ),
          ],
        ),
      ]);
    },
  );

  heroGoldenTest(
    'hover and keyboard focus',
    name: 'interaction',
    size: const Size(320, 140),
    builder: (HeroThemeData theme) => _column(<Widget>[
      _checkbox('Hovered checked', selected: true),
      _checkbox('Focused'),
    ]),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Hovered checked')));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(const Duration(milliseconds: 200));
    },
  );
}
