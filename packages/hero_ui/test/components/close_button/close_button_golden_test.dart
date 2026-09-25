import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _labelled(HeroThemeData theme, String label, Widget child) => Column(
  mainAxisSize: MainAxisSize.min,
  spacing: 8,
  children: <Widget>[
    child,
    Text(label, style: theme.typography.xs.copyWith(color: theme.colors.muted)),
  ],
);

void main() {
  heroGoldenTest(
    'close button states',
    name: 'close_button_states',
    size: const Size(380, 100),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        _labelled(theme, 'rest', HeroCloseButton(onPressed: () {})),
        _labelled(theme, 'hover', HeroCloseButton(onPressed: () {})),
        _labelled(theme, 'pressed', HeroCloseButton(onPressed: () {})),
        _labelled(theme, 'focus', HeroCloseButton(onPressed: () {})),
        _labelled(
          theme,
          'disabled',
          HeroCloseButton(isDisabled: true, onPressed: () {}),
        ),
      ],
    ),
    whilePerforming: (WidgetTester tester) async {
      final List<Element> buttons = find
          .byType(HeroCloseButton)
          .evaluate()
          .toList();
      Offset center(int i) =>
          tester.getCenter(find.byWidget(buttons[i].widget));
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: center(1));
      addTearDown(mouse.removePointer);
      final TestGesture finger = await tester.startGesture(center(2));
      addTearDown(finger.up);
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      for (int i = 0; i < 4; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 300));
    },
  );

  heroGoldenTest(
    'close button icons and custom styles',
    name: 'close_button_custom',
    size: const Size(320, 100),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        _labelled(
          theme,
          'Custom Icon',
          HeroCloseButton(
            onPressed: () {},
            child: const HeroIcon(HeroIcons.circleXmark),
          ),
        ),
        _labelled(
          theme,
          'Alternative Icon',
          HeroCloseButton(
            onPressed: () {},
            child: const HeroIcon(HeroIcons.xmark),
          ),
        ),
        _labelled(
          theme,
          'Custom',
          HeroCloseButton(
            onPressed: () {},
            style: HeroButtonStyle(
              height: theme.spacing(8),
              borderRadius: BorderRadius.circular(theme.radii.full),
            ),
          ),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'close button enlarged',
    name: 'close_button_enlarged',
    size: const Size(120, 120),
    builder: (HeroThemeData theme) =>
        Transform.scale(scale: 3, child: HeroCloseButton(onPressed: () {})),
  );
}
