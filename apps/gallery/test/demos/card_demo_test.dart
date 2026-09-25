import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/card_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    HeroApp(
      debugShowCheckedModeBanner: false,
      // A Column builds every example (a ListView would skip those outside
      // the viewport).
      home: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 24,
          children: <Widget>[
            PlaygroundView(playground: cardDemo.playground!),
            for (final DemoExample example in cardDemo.examples)
              Center(child: Builder(builder: example.builder)),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('card demo renders every example on a phone', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const Size(390, 6000));
    expect(cardDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Variants',
      'Horizontal Layout',
      'With Avatar',
      'With Images',
      'With Form',
      'Customization',
    ]);
    for (final DemoExample example in cardDemo.examples) {
      expect(example.code, isNotEmpty);
    }
    expect(find.byType(HeroCard), findsWidgets);
    expect(find.text('Become an Acme Creator!'), findsNWidgets(2));
    expect(find.text('Sound Electro | Beyond art'), findsOneWidget);
  });

  testWidgets('card demo lays the grid out in columns on wide screens', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const Size(1200, 4000));
    // From md the horizontal card is a row: the text follows the image.
    final Rect title = tester.getRect(
      find.text('Become an ACME Creator!').first,
    );
    final Rect card = tester.getRect(
      find
          .ancestor(
            of: find.text('Become an ACME Creator!').first,
            matching: find.byType(HeroCard),
          )
          .first,
    );
    // padding 16 + image 120 + gap 12
    expect(title.left, card.left + 148);
  });

  testWidgets('the login card submits', (WidgetTester tester) async {
    await _pump(tester, const Size(390, 6000));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Form submitted successfully!'), findsOneWidget);
  });
}
