import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  heroGoldenTest(
    'with a field',
    name: 'field',
    size: const Size(320, 160),
    builder: (HeroThemeData theme) => const SizedBox(
      width: 256,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: <Widget>[
          HeroLabel.text('Email'),
          HeroInput(placeholder: 'you@example.com', type: HeroInputType.email),
          HeroDescription.text(
            "We'll never share your email with anyone else.",
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'custom style, wrapping and RTL',
    name: 'custom',
    size: const Size(320, 200),
    builder: (HeroThemeData theme) => SizedBox(
      width: 256,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          HeroDescription.text(
            'Lowercase letters and hyphens only. Used in app.heroui.com/acme',
            style: theme.typography.style(
              HeroFontSize.xs,
              lineHeight: HeroFontSize.xs.fontSize * 1.625,
              tracking: 0.025,
            ),
          ),
          const HeroDescription.text(
            'Averyveryverylongwordthatdoesnotfitonasinglelineatall',
          ),
          const Directionality(
            textDirection: TextDirection.rtl,
            child: HeroDescription.text('Right to left description'),
          ),
        ],
      ),
    ),
  );
}
