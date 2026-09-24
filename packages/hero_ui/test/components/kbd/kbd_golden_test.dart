import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  heroGoldenTest(
    'kbd variants',
    name: 'kbd_variants',
    size: const Size(320, 160),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        for (final HeroKbdVariant variant in HeroKbdVariant.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              HeroKbd(
                keys: const <HeroKbdKey>[HeroKbdKey.command],
                text: 'K',
                variant: variant,
              ),
              HeroKbd(
                keys: const <HeroKbdKey>[HeroKbdKey.command, HeroKbdKey.shift],
                text: 'Z',
                variant: variant,
              ),
              HeroKbd(text: 'Esc', variant: variant),
              HeroKbd(
                keys: const <HeroKbdKey>[HeroKbdKey.up],
                variant: variant,
              ),
            ],
          ),
        HeroKbd(
          keys: const <HeroKbdKey>[HeroKbdKey.command],
          text: 'K',
          backgroundColor: theme.colors.accentSoft,
          foregroundColor: theme.colors.accentSoftForeground,
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'kbd keys',
    name: 'kbd_keys',
    size: const Size(360, 160),
    builder: (HeroThemeData theme) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final HeroKbdKey key in HeroKbdKey.values)
          HeroKbd(keys: <HeroKbdKey>[key]),
      ],
    ),
  );

  heroGoldenTest(
    'kbd inline',
    name: 'kbd_inline',
    size: const Size(360, 120),
    builder: (HeroThemeData theme) => Text.rich(
      TextSpan(
        children: <InlineSpan>[
          const TextSpan(text: 'Use '),
          HeroKbd.span(
            const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'K'),
          ),
          const TextSpan(text: ' to open the command palette, or '),
          HeroKbd.span(const HeroKbd(text: 'Esc')),
          const TextSpan(text: ' to close it.'),
        ],
      ),
      style: theme.typography.sm.copyWith(color: theme.colors.foreground),
    ),
  );
}
