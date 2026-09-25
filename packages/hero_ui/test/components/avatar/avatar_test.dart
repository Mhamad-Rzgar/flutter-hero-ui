import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// An image provider completed on demand by the test.
class _ControlledImage extends ImageProvider<_ControlledImage> {
  final Completer<ImageInfo> _completer = Completer<ImageInfo>();

  void complete(ui.Image image) => _completer.complete(ImageInfo(image: image));

  void fail() => _completer.completeError(StateError('broken image'));

  @override
  Future<_ControlledImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_ControlledImage>(this);

  @override
  ImageStreamCompleter loadImage(
    _ControlledImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(_completer.future);
}

void main() {
  final HeroThemeData theme = HeroThemeData.light();

  setUp(() => PaintingBinding.instance.imageCache.clear());

  Color fallbackBackground(WidgetTester tester) =>
      (tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(HeroAvatarFallback),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration)
          .color!;

  testWidgets('sizes and fallback text follow the CSS', (
    WidgetTester tester,
  ) async {
    for (final (HeroSize size, double dimension, double font)
        in <(HeroSize, double, double)>[
          (HeroSize.sm, 32, 12),
          (HeroSize.md, 40, 14),
          (HeroSize.lg, 48, 16),
        ]) {
      await pumpHero(
        tester,
        HeroAvatar(size: size, fallback: const Text('JD')),
        theme: theme,
      );
      expect(tester.getSize(find.byType(HeroAvatar)), Size.square(dimension));
      final TextStyle style = DefaultTextStyle.of(
        tester.element(find.text('JD')),
      ).style;
      expect(style.fontSize, font);
      expect(style.fontWeight, FontWeight.w500);
      expect(style.color, theme.colors.defaultSoftForeground);
      expect(fallbackBackground(tester), theme.colors.defaultColor);
    }
  });

  testWidgets('colors and the soft variant', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const HeroAvatar(color: HeroColor.accent, fallback: Text('AC')),
      theme: theme,
    );
    expect(
      DefaultTextStyle.of(tester.element(find.text('AC'))).style.color,
      theme.colors.accentSoftForeground,
    );
    expect(fallbackBackground(tester), theme.colors.defaultColor);

    await pumpHero(
      tester,
      const HeroAvatar(
        color: HeroColor.success,
        variant: HeroAvatarVariant.soft,
        fallback: Text('SC'),
      ),
      theme: theme,
    );
    expect(fallbackBackground(tester), theme.colors.successSoft);
    final ColoredBox root = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(HeroAvatar),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(root.color.a, 0);

    await pumpHero(
      tester,
      const HeroAvatar(
        variant: HeroAvatarVariant.soft,
        children: <Widget>[
          HeroAvatarFallback(color: HeroColor.danger, child: Text('DG')),
        ],
      ),
      theme: theme,
    );
    expect(fallbackBackground(tester), theme.colors.dangerSoft);
  });

  testWidgets('name gives initials and the accessibility label', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, const HeroAvatar(name: 'John Doe'));
    expect(find.text('JD'), findsOneWidget);
    expect(find.bySemanticsLabel('John Doe'), findsOneWidget);
    handle.dispose();
    expect(HeroAvatar.initialsOf('Ada'), 'A');
    expect(HeroAvatar.initialsOf('  mary  jane watson '), 'MW');
    expect(HeroAvatar.initialsOf(''), '');
  });

  testWidgets('image replaces the fallback once loaded and fades in', (
    WidgetTester tester,
  ) async {
    final _ControlledImage image = _ControlledImage();
    int loads = 0;
    await pumpHero(
      tester,
      HeroAvatar(
        children: <Widget>[
          HeroAvatarImage(
            image: image,
            semanticLabel: 'Jane',
            onLoad: () => loads++,
          ),
          const HeroAvatarFallback(child: Text('JD')),
        ],
      ),
    );
    expect(find.text('JD'), findsOneWidget);
    expect(find.byType(RawImage), findsNothing);

    final ui.Image decoded = (await tester.runAsync(
      () => createTestImage(width: 8, height: 8),
    ))!;
    image.complete(decoded);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(loads, 1);
    expect(find.byType(RawImage), findsOneWidget);
    expect(find.text('JD'), findsNothing);
    final Opacity fade = tester.widget<Opacity>(
      find.ancestor(of: find.byType(RawImage), matching: find.byType(Opacity)),
    );
    expect(fade.opacity, 0);
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(
              of: find.byType(RawImage),
              matching: find.byType(Opacity),
            ),
          )
          .opacity,
      1,
    );
    expect(tester.widget<RawImage>(find.byType(RawImage)).fit, BoxFit.cover);
  });

  testWidgets('cached images show immediately without a fade', (
    WidgetTester tester,
  ) async {
    final _ControlledImage image = _ControlledImage();
    final ui.Image decoded = (await tester.runAsync(
      () => createTestImage(width: 8, height: 8),
    ))!;
    image.complete(decoded);
    await pumpHero(tester, HeroAvatar(image: image, fallback: const Text('A')));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsOneWidget);

    // A second avatar gets the image from the cache synchronously.
    await pumpHero(
      tester,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroAvatar(image: image, fallback: const Text('B')),
          HeroAvatar(
            children: <Widget>[
              const HeroAvatarFallback(child: Text('C')),
              HeroAvatarImage(image: image),
            ],
          ),
        ],
      ),
    );
    expect(find.text('B'), findsNothing);
    expect(find.text('C'), findsNothing);
    expect(find.byType(RawImage), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed images keep the fallback and report the error', (
    WidgetTester tester,
  ) async {
    final _ControlledImage image = _ControlledImage();
    Object? error;
    await pumpHero(
      tester,
      HeroAvatar(
        children: <Widget>[
          HeroAvatarImage(
            image: image,
            onError: (Object e, StackTrace? _) => error = e,
          ),
          const HeroAvatarFallback(child: Text('NA')),
        ],
      ),
    );
    image.fail();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(error, isA<StateError>());
    expect(find.text('NA'), findsOneWidget);
    expect(find.byType(RawImage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('network errors fall back silently', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const HeroAvatar(src: 'https://example.com/missing.jpg', name: 'N A'),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    expect(find.text('NA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fallback delay', (WidgetTester tester) async {
    final _ControlledImage image = _ControlledImage();
    await pumpHero(
      tester,
      HeroAvatar(
        image: image,
        fallback: const Text('NA'),
        fallbackDelay: const Duration(milliseconds: 600),
      ),
    );
    expect(find.text('NA'), findsNothing);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('NA'), findsOneWidget);
  });

  testWidgets('scope provides group defaults and the fallback nudge', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroAvatarScope(
        size: HeroSize.lg,
        color: HeroColor.warning,
        variant: HeroAvatarVariant.soft,
        fallbackPadding: EdgeInsetsDirectional.only(end: 3),
        child: HeroAvatar(fallback: Text('WR')),
      ),
      theme: theme,
    );
    expect(tester.getSize(find.byType(HeroAvatar)), const Size.square(48));
    expect(fallbackBackground(tester), theme.colors.warningSoft);
    expect(
      tester.getCenter(find.text('WR')).dx,
      closeTo(tester.getCenter(find.byType(HeroAvatar)).dx - 1.5, 0.01),
    );

    await pumpHero(
      tester,
      const HeroAvatarScope(
        size: HeroSize.lg,
        child: HeroAvatar(size: HeroSize.sm, fallback: Text('S')),
      ),
    );
    expect(tester.getSize(find.byType(HeroAvatar)), const Size.square(32));
  });

  testWidgets('icons in the fallback take the foreground color', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroAvatar(
        color: HeroColor.accent,
        fallback: HeroIcon(HeroIcons.person),
      ),
      theme: theme,
    );
    expect(
      IconTheme.of(tester.element(find.byType(HeroIcon))).color,
      theme.colors.accentSoftForeground,
    );
  });

  testWidgets('custom radius, gradient and 2x text scale in RTL', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroAvatar(
        radius: 8,
        children: <Widget>[
          HeroAvatarFallback(
            gradient: LinearGradient(
              colors: <Color>[theme.colors.accent, theme.colors.danger],
            ),
            foregroundColor: theme.colors.white,
            child: const Text('GB'),
          ),
        ],
      ),
      theme: theme,
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    final ShapeBorderClipper clipper =
        tester
                .widget<ClipPath>(
                  find.descendant(
                    of: find.byType(HeroAvatar),
                    matching: find.byType(ClipPath),
                  ),
                )
                .clipper!
            as ShapeBorderClipper;
    expect((clipper.shape as OutlinedBorder), theme.shapeAll(8));
  });
}
