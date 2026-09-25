import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// Diagonal stripes that make the transparent clip seam visible.
class _Stripes extends CustomPainter {
  const _Stripes(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (double c = -size.height; c < size.width; c += 8) {
      canvas.drawLine(
        Offset(c, size.height),
        Offset(c + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_Stripes oldDelegate) => oldDelegate.color != color;
}

void main() {
  List<Widget> people(HeroSize? size) => <Widget>[
    HeroAvatar(size: size, color: HeroColor.accent, fallback: const Text('JD')),
    HeroAvatar(size: size, fallback: const Text('AB')),
    HeroAvatar(
      size: size,
      color: HeroColor.success,
      fallback: const Text('EC'),
    ),
    HeroAvatar(
      size: size,
      variant: HeroAvatarVariant.soft,
      color: HeroColor.warning,
      fallback: const Text('SM'),
    ),
    const HeroAvatarGroupCount(child: Text('+2')),
  ];

  heroGoldenTest(
    'avatar group overlap modes',
    name: 'avatar_group_overlap',
    size: const Size(320, 200),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        for (final HeroAvatarGroupOverlap overlap
            in HeroAvatarGroupOverlap.values)
          CustomPaint(
            painter: _Stripes(theme.colors.danger.withValues(alpha: 0.3)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: HeroAvatarGroup(
                size: HeroSize.lg,
                overlap: overlap,
                children: people(null),
              ),
            ),
          ),
      ],
    ),
  );

  heroGoldenTest(
    'avatar group sizes, max and grid',
    name: 'avatar_group_layouts',
    size: const Size(320, 300),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final HeroSize size in HeroSize.values)
          HeroAvatarGroup(
            size: size,
            max: 3,
            children: people(null).take(4).toList(),
          ),
        SizedBox(
          width: 150,
          child: HeroAvatarGroup(isGrid: true, children: people(HeroSize.sm)),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'avatar group in right-to-left',
    name: 'avatar_group_rtl',
    size: const Size(240, 100),
    builder: (HeroThemeData theme) => Directionality(
      textDirection: TextDirection.rtl,
      child: HeroAvatarGroup(children: people(null)),
    ),
  );
}
