import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// An image provider that serves an already decoded image.
class _PortraitImage extends ImageProvider<_PortraitImage> {
  _PortraitImage(this.image);

  final ui.Image image;

  @override
  Future<_PortraitImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_PortraitImage>(this);

  @override
  ImageStreamCompleter loadImage(
    _PortraitImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(
    SynchronousFuture<ImageInfo>(ImageInfo(image: image.clone())),
  );
}

Future<ui.Image> _portrait(Color background, Color figure) {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  canvas
    ..drawRect(const Rect.fromLTWH(0, 0, 96, 96), Paint()..color = background)
    ..drawCircle(const Offset(48, 38), 18, Paint()..color = figure)
    ..drawOval(const Rect.fromLTWH(18, 62, 60, 56), Paint()..color = figure);
  return recorder.endRecording().toImage(96, 96);
}

void main() {
  final List<ui.Image> portraits = <ui.Image>[];

  setUpAll(() async {
    portraits.addAll(<ui.Image>[
      await _portrait(const Color(0xFF93C5FD), const Color(0xFF1E3A8A)),
      await _portrait(const Color(0xFFC4B5FD), const Color(0xFF4C1D95)),
      await _portrait(const Color(0xFFFCA5A5), const Color(0xFF7F1D1D)),
    ]);
  });

  heroGoldenTest(
    'avatar fallbacks by size, color and variant',
    name: 'avatar_fallbacks',
    size: const Size(360, 240),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        const Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            HeroAvatar(size: HeroSize.sm, fallback: Text('SM')),
            HeroAvatar(fallback: Text('MD')),
            HeroAvatar(size: HeroSize.lg, fallback: Text('LG')),
            HeroAvatar(fallback: HeroIcon(HeroIcons.person)),
          ],
        ),
        for (final HeroAvatarVariant variant in HeroAvatarVariant.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              for (final HeroColor color in HeroColor.values)
                HeroAvatar(
                  color: color,
                  variant: variant,
                  fallback: const Text('AG'),
                ),
            ],
          ),
      ],
    ),
  );

  heroGoldenTest(
    'avatar images and customization',
    name: 'avatar_images',
    size: const Size(360, 160),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        HeroAvatar(
          size: HeroSize.sm,
          image: _PortraitImage(portraits[0]),
          fallback: const Text('SM'),
        ),
        HeroAvatar(
          image: _PortraitImage(portraits[1]),
          fallback: const Text('MD'),
        ),
        HeroAvatar(
          size: HeroSize.lg,
          image: _PortraitImage(portraits[2]),
          fallback: const Text('LG'),
        ),
        HeroAvatar(
          radius: theme.radii.lg,
          image: _PortraitImage(portraits[0]),
          fallback: const Text('JD'),
        ),
        HeroAvatar(
          children: <Widget>[
            HeroAvatarFallback(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[theme.colors.danger, theme.colors.accent],
              ),
              foregroundColor: theme.colors.white,
              child: const Text('GB'),
            ),
          ],
        ),
      ],
    ),
  );
}
