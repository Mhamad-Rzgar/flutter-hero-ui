import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Finder get _control => find.byType(HeroSwitchControl);

Finder get _thumb => find.byType(HeroSwitchThumb);

SemanticsNode _node(WidgetTester tester) =>
    tester.getSemantics(find.byType(HeroInteractable).first);

bool _on(WidgetTester tester) =>
    _node(tester).flagsCollection.isToggled == Tristate.isTrue;

/// The painted thumb pill (the animated container inside the thumb).
Rect _thumbRect(WidgetTester tester) => tester.getRect(
  find.descendant(of: _thumb, matching: find.byType(AnimatedContainer)),
);

void main() {
  group('HeroSwitch layout', () {
    testWidgets('sizes follow switch.css', (WidgetTester tester) async {
      for (final (HeroSize size, Size track, Size thumb, double on)
          in <(HeroSize, Size, Size, double)>[
            (HeroSize.sm, const Size(32, 16), const Size(16.5, 12), 13.5),
            (HeroSize.md, const Size(40, 20), const Size(22, 16), 16),
            (HeroSize.lg, const Size(48, 24), const Size(27.5, 20), 18.5),
          ]) {
        await pumpHero(
          tester,
          HeroSwitch(
            key: ValueKey<HeroSize>(size),
            size: size,
            label: 'Switch',
          ),
        );
        expect(tester.getSize(_control), track);
        expect(_thumbRect(tester).size, thumb);
        // `ms-0.5` while off, vertically centred.
        expect(
          _thumbRect(tester).topLeft - tester.getTopLeft(_control),
          Offset(2, (track.height - thumb.height) / 2),
        );
        await tester.tap(find.text('Switch'));
        await tester.pumpAndSettle();
        expect(_thumbRect(tester).left - tester.getTopLeft(_control).dx, on);
      }
    });

    testWidgets('the description is indented by the track and gap', (
      WidgetTester tester,
    ) async {
      for (final (HeroSize size, double indent) in <(HeroSize, double)>[
        (HeroSize.sm, 44),
        (HeroSize.md, 52),
        (HeroSize.lg, 60),
      ]) {
        await pumpHero(
          tester,
          HeroSwitch(size: size, label: 'Public', description: 'Visible'),
        );
        expect(
          tester.getTopLeft(find.text('Visible')).dx -
              tester.getTopLeft(_control).dx,
          indent,
        );
      }
    });

    testWidgets('the label can sit before the control', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroSwitch(
          label: 'Label before',
          labelPosition: HeroSwitchLabelPosition.start,
        ),
      );
      expect(
        tester.getTopLeft(_control).dx -
            tester.getTopRight(find.text('Label before')).dx,
        12,
      );
    });

    testWidgets('RTL starts the thumb on the right', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroSwitch(label: 'RTL'),
        textDirection: TextDirection.rtl,
      );
      expect(tester.getTopRight(_control).dx - _thumbRect(tester).right, 2);
      expect(
        tester.getTopLeft(_control).dx,
        greaterThan(tester.getTopRight(find.text('RTL')).dx),
      );
    });

    testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 200,
          child: HeroSwitch(
            label: 'Enable push notifications',
            description: 'Allow others to see your profile information',
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a switch group stacks or rows its switches', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroSwitchGroup(
          children: <Widget>[
            HeroSwitch(label: 'One'),
            HeroSwitch(label: 'Two'),
          ],
        ),
      );
      final Finder switches = find.byType(HeroSwitch);
      expect(
        tester.getTopLeft(switches.at(1)).dy -
            tester.getBottomLeft(switches.first).dy,
        16,
      );
      await pumpHero(
        tester,
        const HeroSwitchGroup(
          orientation: Axis.horizontal,
          children: <Widget>[
            HeroSwitch(label: 'One'),
            HeroSwitch(label: 'Two'),
          ],
        ),
      );
      expect(
        tester.getTopLeft(switches.at(1)).dx -
            tester.getTopRight(switches.first).dx,
        16,
      );
    });
  });

  group('HeroSwitch interaction', () {
    testWidgets('press toggles and calls onPressed', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];
      int presses = 0;
      await pumpHero(
        tester,
        HeroSwitch(
          label: 'Notifications',
          onChanged: changes.add,
          onPressed: () => presses++,
        ),
      );
      expect(_on(tester), isFalse);
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(changes, <bool>[true]);
      expect(presses, 1);
      expect(_on(tester), isTrue);
    });

    testWidgets('the thumb slides over 300 ms', (WidgetTester tester) async {
      await pumpHero(tester, const HeroSwitch(label: 'Slide'));
      final double start = _thumbRect(tester).left;
      await tester.tap(find.text('Slide'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final double mid = _thumbRect(tester).left;
      expect(mid, greaterThan(start));
      expect(mid, lessThan(start + 14));
      await tester.pump(const Duration(milliseconds: 250));
      expect(_thumbRect(tester).left, start + 14);
    });

    testWidgets('reduced motion moves the thumb instantly', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroSwitch(label: 'Instant'),
        theme: HeroThemeData.light().copyWith(
          motion: const HeroMotion(reduceMotion: true),
        ),
      );
      final double start = _thumbRect(tester).left;
      await tester.tap(find.text('Instant'));
      await tester.pump();
      await tester.pump();
      expect(_thumbRect(tester).left, start + 14);
    });

    testWidgets('controlled follows isSelected', (WidgetTester tester) async {
      bool on = false;
      await pumpHero(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroSwitch(
                label: 'Controlled',
                isSelected: on,
                onChanged: (bool value) => setState(() => on = value),
              ),
              Text('Switch is ${on ? 'on' : 'off'}'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Controlled'));
      await tester.pumpAndSettle();
      expect(find.text('Switch is on'), findsOneWidget);
    });

    testWidgets('Space toggles, Enter does not', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];
      await pumpHero(tester, HeroSwitch(label: 'Keys', onChanged: changes.add));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(changes, <bool>[true]);
    });

    testWidgets('dragging the thumb across toggles', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];
      await pumpHero(tester, HeroSwitch(label: 'Drag', onChanged: changes.add));
      final Offset center = tester.getCenter(_control);
      // A drag that returns before the middle snaps back.
      final TestGesture back = await tester.startGesture(center);
      await back.moveBy(const Offset(20, 0));
      await back.moveBy(const Offset(-15, 0));
      await tester.pump(const Duration(milliseconds: 300));
      await back.up();
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(_on(tester), isFalse);
      // The thumb follows the finger while dragging.
      final TestGesture gesture = await tester.startGesture(
        center - const Offset(8, 0),
      );
      // Past the touch slop, then 10 px along the track.
      await gesture.moveBy(const Offset(20, 0));
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump();
      expect(
        _thumbRect(tester).left - tester.getTopLeft(_control).dx,
        greaterThan(2),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(changes, <bool>[true]);
      expect(_on(tester), isTrue);
    });

    testWidgets('RTL drags toggle towards the left', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];
      await pumpHero(
        tester,
        HeroSwitch(label: 'Drag', onChanged: changes.add),
        textDirection: TextDirection.rtl,
      );
      await tester.timedDrag(
        find.byType(HeroSwitchControl),
        const Offset(-30, 0),
        const Duration(milliseconds: 400),
      );
      await tester.pumpAndSettle();
      expect(changes, <bool>[true]);
    });

    testWidgets('disabled and read-only ignore input', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];
      await pumpHero(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroSwitch(
              label: 'Disabled',
              isDisabled: true,
              onChanged: changes.add,
            ),
            HeroSwitch(
              label: 'Read-only',
              isReadOnly: true,
              onChanged: changes.add,
            ),
          ],
        ),
      );
      await tester.tap(find.text('Disabled'));
      await tester.tap(find.text('Read-only'));
      await tester.timedDrag(
        find.byType(HeroSwitchControl).last,
        const Offset(30, 0),
        const Duration(milliseconds: 400),
      );
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      final SemanticsNode disabled = _node(tester);
      expect(disabled.flagsCollection.isEnabled, Tristate.isFalse);
      final SemanticsNode readOnly = tester.getSemantics(
        find.byType(HeroInteractable).last,
      );
      expect(readOnly.flagsCollection.isReadOnly, isTrue);
    });

    testWidgets('builder receives selection and hover', (
      WidgetTester tester,
    ) async {
      final List<HeroSwitchState> states = <HeroSwitchState>[];
      await pumpHero(
        tester,
        HeroSwitch(
          builder: (BuildContext context, HeroSwitchState state) {
            states.add(state);
            return <Widget>[
              HeroSwitchContent(
                children: <Widget>[
                  const HeroSwitchControl(),
                  Text(state.isSelected ? 'Enabled' : 'Disabled'),
                ],
              ),
            ];
          },
        ),
      );
      expect(find.text('Disabled'), findsOneWidget);
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: tester.getCenter(find.text('Disabled')));
      await tester.pump();
      expect(states.last.isHovered, isTrue);
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();
      expect(find.text('Enabled'), findsOneWidget);
    });

    testWidgets('thumb icons take the glyph color', (
      WidgetTester tester,
    ) async {
      final HeroColors colors = HeroThemeData.light().colors;
      await pumpHero(
        tester,
        const HeroSwitch(
          size: HeroSize.lg,
          semanticLabel: 'Dark mode',
          children: <Widget>[
            HeroSwitchContent(
              children: <Widget>[
                HeroSwitchControl(
                  child: HeroSwitchThumb(
                    child: HeroSwitchIcon(child: HeroIcon(HeroIcons.moon)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      IconThemeData icon() =>
          IconTheme.of(tester.element(find.byType(HeroIcon)));
      expect(icon().color, colors.black);
      expect(icon().size, 12);
      expect(_node(tester).label, 'Dark mode');
      await tester.tap(_control);
      await tester.pumpAndSettle();
      expect(icon().color, colors.accent);
    });
  });

  group('HeroSwitch validation', () {
    testWidgets('required blocks a form until on; values submit', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      final List<Map<String, Object?>> submitted = <Map<String, Object?>>[];
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          onSubmit: submitted.add,
          child: const HeroSwitchGroup(
            children: <Widget>[
              HeroSwitch(name: 'terms', label: 'Terms', isRequired: true),
              HeroSwitch(
                name: 'newsletter',
                label: 'Newsletter',
                defaultSelected: true,
              ),
            ],
          ),
        ),
      );
      form.currentState!.submit();
      await tester.pumpAndSettle();
      expect(submitted, isEmpty);
      const String message = 'Please check this box if you want to proceed.';
      expect(find.text(message), findsOneWidget);
      await tester.tap(find.text('Terms'));
      await tester.pumpAndSettle();
      expect(find.text(message), findsNothing);
      form.currentState!.submit();
      expect(submitted.single, <String, Object?>{
        'terms': 'on',
        'newsletter': 'on',
      });
      form.currentState!.reset();
      await tester.pumpAndSettle();
      expect(form.currentState!.save(), <String, Object?>{'newsletter': 'on'});
    });
  });
}
