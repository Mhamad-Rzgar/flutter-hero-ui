import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../helpers/hero_test_app.dart';

class _Harness extends StatefulWidget {
  const _Harness({this.isModal = false});
  final bool isModal;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  bool open = false;
  HeroOverlayGeometry? geometry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        HeroAnchoredOverlay(
          isOpen: open,
          isModal: widget.isModal,
          onDismiss: () => setState(() => open = false),
          overlayBuilder: (BuildContext context, HeroOverlayGeometry g) {
            geometry = g;
            return const SizedBox(key: Key('overlay'), width: 120, height: 60);
          },
          child: GestureDetector(
            key: const Key('trigger'),
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => open = !open),
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
        const SizedBox(height: 200),
        const ColoredBox(
          key: Key('outside'),
          color: Color(0xFF000000),
          child: SizedBox(width: 50, height: 50),
        ),
      ],
    );
  }
}

void main() {
  testWidgets('opens below the trigger and dismisses on outside tap', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const _Harness());
    expect(find.byKey(const Key('overlay')), findsNothing);

    await tester.tap(find.byKey(const Key('trigger')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('overlay')), findsOneWidget);

    final Rect trigger = tester.getRect(find.byKey(const Key('trigger')));
    final Rect overlay = tester.getRect(find.byKey(const Key('overlay')));
    expect(overlay.top, closeTo(trigger.bottom + 8, 0.5));
    expect(overlay.center.dx, closeTo(trigger.center.dx, 0.5));
    final _HarnessState state = tester.state(find.byType(_Harness));
    expect(state.geometry!.side, HeroOverlaySide.bottom);

    await tester.tap(find.byKey(const Key('outside')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('overlay')), findsNothing);
  });

  testWidgets('Escape dismisses', (WidgetTester tester) async {
    await pumpHero(tester, const _Harness());
    await tester.tap(find.byKey(const Key('trigger')));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('overlay')), findsNothing);
  });

  testWidgets('modal barrier dismisses and blocks the page', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const _Harness(isModal: true));
    await tester.tap(find.byKey(const Key('trigger')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('overlay')), findsNothing);
  });

  testWidgets('exit animation keeps the overlay until it finishes', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const _Harness());
    await tester.tap(find.byKey(const Key('trigger')));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.byKey(const Key('overlay')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('overlay')), findsNothing);
  });
}
