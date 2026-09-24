import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _column(List<Widget> children) => SizedBox(
  width: 260,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: children,
  ),
);

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  heroGoldenTest(
    'variants',
    name: 'variants',
    size: const Size(320, 240),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroInput(placeholder: 'Primary input'),
      HeroInput(
        placeholder: 'Secondary input',
        variant: HeroFieldVariant.secondary,
      ),
      HeroInput(defaultValue: 'Jane Doe'),
      HeroInput(defaultValue: 'Jane Doe', variant: HeroFieldVariant.secondary),
    ]),
  );

  heroGoldenTest(
    'states',
    name: 'states',
    size: const Size(320, 300),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroInput(placeholder: 'Invalid', isInvalid: true),
      HeroInput(defaultValue: 'Disabled', isDisabled: true),
      HeroInput(defaultValue: 'Read only', isReadOnly: true),
      HeroInput(
        defaultValue: 'Secondary invalid',
        variant: HeroFieldVariant.secondary,
        isInvalid: true,
      ),
      HeroInput(type: HeroInputType.password, defaultValue: 'secret'),
    ]),
  );

  heroGoldenTest(
    'focused',
    name: 'focused',
    size: const Size(320, 160),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroInput(placeholder: 'Focused', autofocus: true),
      HeroInput(placeholder: 'Resting'),
    ]),
  );

  heroGoldenTest(
    'focused invalid',
    name: 'focused_invalid',
    size: const Size(320, 100),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroInput(defaultValue: 'jr', isInvalid: true, autofocus: true),
    ]),
  );

  heroGoldenTest(
    'hovered',
    name: 'hovered',
    size: const Size(320, 160),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroInput(placeholder: 'Hovered primary'),
      HeroInput(placeholder: 'Secondary', variant: HeroFieldVariant.secondary),
    ]),
    whilePerforming: (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(HeroInput).first));
    },
  );

  heroGoldenTest(
    'text sizes',
    name: 'sizes',
    size: const Size(320, 160),
    builder: (HeroThemeData theme) => _column(<Widget>[
      const HeroInput(defaultValue: 'text-base (below sm)'),
      HeroTheme(
        data: theme.copyWith(density: HeroDensity.desktop),
        child: const HeroInput(defaultValue: 'sm:text-sm (from sm)'),
      ),
    ]),
  );

  heroGoldenTest(
    'custom style and RTL',
    name: 'custom',
    size: const Size(320, 160),
    builder: (HeroThemeData theme) => _column(<Widget>[
      HeroInput(
        placeholder: 'Search projects...',
        style: HeroFieldStyle(
          backgroundColor: theme.colors.defaultColor,
          borderWidth: theme.borderWidth,
          borderColor: theme.colors.border.withValues(alpha: 0.8),
          placeholderStyle: TextStyle(color: theme.colors.muted),
        ),
      ),
      const Directionality(
        textDirection: TextDirection.rtl,
        child: HeroInput(defaultValue: 'Right to left'),
      ),
    ]),
  );

  heroGoldenTest(
    'selection and context menu',
    name: 'context_menu',
    size: const Size(320, 200),
    builder: (HeroThemeData theme) => const Padding(
      padding: EdgeInsets.only(top: 56),
      child: HeroInput(defaultValue: 'hello world', width: 260),
    ),
    whilePerforming: (WidgetTester tester) async {
      await tester.longPressAt(
        tester.getTopLeft(find.byType(EditableText)) + const Offset(12, 10),
      );
    },
  );
}
