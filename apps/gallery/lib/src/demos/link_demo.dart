import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gravity UI `arrow-up-right-from-square`, declared from its SVG path.
const HeroIconData _arrowUpRightFromSquare = HeroIconData(<HeroIconPath>[
  HeroIconPath(
    'M10 1.5A.75.75 0 0 0 10 3h1.94L6.97 7.97a.75.75 0 0 0 1.06 1.06L13 '
    '4.06V6a.75.75 0 0 0 1.5 0V2.25a.75.75 0 0 0-.75-.75zM7.5 3.25a.75.75 0 '
    '0 0-.75-.75H4.5a3 3 0 0 0-3 3v6a3 3 0 0 0 3 3h6a3 3 0 0 0 3-3V9.25a.75.75 '
    '0 0 0-1.5 0v2.25a1.5 1.5 0 0 1-1.5 1.5h-6A1.5 1.5 0 0 1 3 11.5v-6A1.5 '
    '1.5 0 0 1 4.5 4h2.25a.75.75 0 0 0 .75-.75',
    evenOdd: true,
  ),
]);

final ComponentDemo linkDemo = ComponentDemo(
  slug: 'link',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('underline', <String>['hover', 'always', 'none']),
      OptionsControl('icon', <String>['end', 'start', 'none']),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final String icon = values.option('icon');
      return HeroLink(
        href: Uri.parse('https://heroui.com'),
        underline: values.pick('underline', HeroLinkUnderline.values),
        isDisabled: values.toggle('isDisabled'),
        gap: icon == 'start' ? 4 : 0,
        children: <Widget>[
          if (icon == 'start') const HeroLinkIcon(),
          const Text('Call to action'),
          if (icon == 'end') const HeroLinkIcon(),
        ],
      );
    },
    code: (PlaygroundValues values) {
      final String icon = values.option('icon');
      final String underline = values.option('underline');
      return '''
HeroLink(
  href: Uri.parse('https://heroui.com'),${underline == 'hover' ? '' : '\n  underline: HeroLinkUnderline.$underline,'}${values.toggle('isDisabled') ? '\n  isDisabled: true,' : ''}${icon == 'start' ? '\n  gap: 4,' : ''}
  children: <Widget>[${icon == 'start' ? '\n    HeroLinkIcon(),' : ''}
    Text('Call to action'),${icon == 'end' ? '\n    HeroLinkIcon(),' : ''}
  ],
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const HeroLink(
        children: <Widget>[Text('Call to action'), HeroLinkIcon()],
      ),
      code: '''
HeroLink(
  href: Uri.parse('#'),
  children: <Widget>[
    Text('Call to action'),
    HeroLinkIcon(),
  ],
)''',
    ),
    DemoExample(
      title: 'Icon Placement',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          HeroLink(
            children: <Widget>[Text('Icon at end (default)'), HeroLinkIcon()],
          ),
          HeroLink(
            gap: 4,
            children: <Widget>[HeroLinkIcon(), Text('Icon at start')],
          ),
        ],
      ),
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 12,
  children: <Widget>[
    HeroLink(
      children: <Widget>[Text('Icon at end (default)'), HeroLinkIcon()],
    ),
    HeroLink(
      gap: 4,
      children: <Widget>[HeroLinkIcon(), Text('Icon at start')],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Text Decoration',
      description:
          'Links underline on hover by default. `underline` makes the '
          'underline always visible or removes it; `underlineOffset` and '
          '`decorationColor` customize it.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        Widget group(String title, Widget child) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            Text(
              title,
              style: theme.typography
                  .style(HeroFontSize.sm, weight: HeroTypography.medium)
                  .copyWith(color: theme.colors.muted),
            ),
            child,
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: <Widget>[
            group(
              'Default hover underline',
              const HeroLink(
                children: <Widget>[
                  Text('Hover to see the underline'),
                  HeroLinkIcon(),
                ],
              ),
            ),
            group(
              'Always visible underline',
              const HeroLink(
                underline: HeroLinkUnderline.always,
                children: <Widget>[
                  Text('Underline always visible'),
                  HeroLinkIcon(),
                ],
              ),
            ),
            group(
              'No underline',
              const HeroLink(
                underline: HeroLinkUnderline.none,
                children: <Widget>[
                  Text('Link without any underline'),
                  HeroLinkIcon(),
                ],
              ),
            ),
            group(
              'Changing the underline offset',
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: <Widget>[
                  for (final int offset in <int>[1, 2, 3, 4])
                    HeroLink(
                      underline: HeroLinkUnderline.always,
                      underlineOffset: offset.toDouble(),
                      children: <Widget>[
                        Text('Offset $offset (${offset}px space)'),
                        const HeroLinkIcon(),
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
      code: r'''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 12,
  children: <Widget>[
    HeroLink(
      children: <Widget>[Text('Hover to see the underline'), HeroLinkIcon()],
    ),
    HeroLink(
      underline: HeroLinkUnderline.always,
      children: <Widget>[Text('Underline always visible'), HeroLinkIcon()],
    ),
    HeroLink(
      underline: HeroLinkUnderline.none,
      children: <Widget>[Text('Link without any underline'), HeroLinkIcon()],
    ),
    for (final int offset in <int>[1, 2, 3, 4])
      HeroLink(
        underline: HeroLinkUnderline.always,
        underlineOffset: offset.toDouble(),
        children: <Widget>[
          Text('Offset $offset (${offset}px space)'),
          HeroLinkIcon(),
        ],
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Custom Icon',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: <Widget>[
            HeroLink(
              children: <Widget>[
                const Text('External link'),
                HeroLinkIcon(
                  size: theme.spacing(3),
                  margin: EdgeInsetsDirectional.only(start: theme.spacing(1.5)),
                  child: const HeroIcon(_arrowUpRightFromSquare),
                ),
              ],
            ),
            HeroLink(
              gap: theme.spacing(1),
              children: <Widget>[
                const Text('Go to page'),
                HeroLinkIcon(
                  size: theme.spacing(3),
                  child: const HeroIcon(HeroIcons.link),
                ),
              ],
            ),
          ],
        );
      },
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 12,
  children: <Widget>[
    HeroLink(
      children: <Widget>[
        Text('External link'),
        HeroLinkIcon(
          size: 12,
          margin: EdgeInsetsDirectional.only(start: 6),
          child: HeroIcon(arrowUpRightFromSquare),
        ),
      ],
    ),
    HeroLink(
      gap: 4,
      children: <Widget>[
        Text('Go to page'),
        HeroLinkIcon(size: 12, child: HeroIcon(HeroIcons.link)),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'builder receives the interaction state (hovered, pressed, '
          'focus-visible, disabled) and returns the link content.',
      builder: (BuildContext context) => HeroLink(
        builder: (BuildContext context, HeroInteractionState state) =>
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[Text('Call to action'), HeroLinkIcon()],
            ),
      ),
      code: '''
HeroLink(
  href: Uri.parse('#'),
  builder: (BuildContext context, HeroInteractionState state) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[Text('Call to action'), HeroLinkIcon()],
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroLink(
          underline: HeroLinkUnderline.always,
          color: WidgetStateColor.resolveWith(
            (Set<WidgetState> states) => states.contains(WidgetState.hovered)
                ? theme.colors.foreground
                : theme.colors.foreground.withValues(alpha: 0.8),
          ),
          decorationColor: theme.colors.border.withValues(alpha: 0.8),
          children: const <Widget>[Text('Call to action'), HeroLinkIcon()],
        );
      },
      code: '''
HeroLink(
  underline: HeroLinkUnderline.always,
  color: WidgetStateColor.resolveWith(
    (Set<WidgetState> states) => states.contains(WidgetState.hovered)
        ? theme.colors.foreground
        : theme.colors.foreground.withValues(alpha: 0.8),
  ),
  decorationColor: theme.colors.border.withValues(alpha: 0.8),
  children: <Widget>[Text('Call to action'), HeroLinkIcon()],
)''',
    ),
  ],
);
