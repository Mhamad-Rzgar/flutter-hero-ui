import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/app.dart';
import 'package:hero_ui_gallery/src/catalog.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/registry.dart';
import 'package:hero_ui_gallery/src/gallery_state.dart';

void main() {
  testWidgets('home lists every catalog category', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    expect(find.text('HeroUI for Flutter'), findsOneWidget);
    expect(find.text('BUTTONS'), findsOneWidget);
    expect(catalog.length, greaterThanOrEqualTo(72));
  });

  testWidgets('search filters the index', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'calendar');
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Button'), findsNothing);
  });

  testWidgets('theme state switches brightness and preset', (
    WidgetTester tester,
  ) async {
    final GalleryState state = GalleryState();
    addTearDown(state.dispose);
    await tester.pumpWidget(GalleryApp(state: state));
    state
      ..mode = HeroThemeMode.dark
      ..theme = state.themes[1];
    await tester.pumpAndSettle();
    final BuildContext context = tester.element(
      find.text('HeroUI for Flutter'),
    );
    expect(HeroTheme.of(context).isDark, isTrue);
    expect(HeroTheme.of(context).preset, HeroThemePreset.sky);
  });

  testWidgets('wide layout shows index and detail side by side', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    expect(
      find.text('Pick a component from the index to explore its variants.'),
      findsOneWidget,
    );
  });

  testWidgets('Pro demos appear in a Pro group of the index', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    demoRegistry['pro-sample'] = ComponentDemo(
      slug: 'pro-sample',
      pro: const ProComponentInfo(
        name: 'Sample',
        category: 'Testing',
        description: 'A sample Pro component',
      ),
      examples: <DemoExample>[
        DemoExample(
          title: 'Usage',
          builder: (BuildContext context) => const Text('sample body'),
          code: 'HeroProSample()',
        ),
      ],
    );
    addTearDown(() => demoRegistry.remove('pro-sample'));
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'sample');
    await tester.pumpAndSettle();
    expect(find.text('PRO · TESTING'), findsOneWidget);
    await tester.tap(find.text('Sample'));
    await tester.pumpAndSettle();
    expect(find.text('Testing · HeroProSample'), findsOneWidget);
    expect(find.text('sample body'), findsOneWidget);
  });
}
