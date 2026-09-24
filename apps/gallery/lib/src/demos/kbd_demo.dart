import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

final ComponentDemo kbdDemo = ComponentDemo(
  slug: 'kbd',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['standard', 'light']),
      OptionsControl('key', <String>[
        'command',
        'shift',
        'ctrl',
        'option',
        'enter',
        'escape',
        'tab',
        'space',
      ]),
      TextControl('text', initial: 'K'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroKbd(
      keys: <HeroKbdKey>[values.pick('key', HeroKbdKey.values)],
      text: values.text('text'),
      variant: values.pick('variant', HeroKbdVariant.values),
    ),
    code: (PlaygroundValues values) {
      final String variant = values.option('variant');
      return '''
HeroKbd(
  keys: <HeroKbdKey>[HeroKbdKey.${values.option('key')}],
  text: '${values.text('text')}',${variant == 'standard' ? '' : '\n  variant: HeroKbdVariant.$variant,'}
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'K'),
          HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.shift], text: 'P'),
          HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.ctrl], text: 'C'),
          HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.option], text: 'D'),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: <Widget>[
    HeroKbd(
      children: <Widget>[
        HeroKbdAbbr(HeroKbdKey.command),
        HeroKbdContent(Text('K')),
      ],
    ),
    // Shorthand for the same structure:
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.shift], text: 'P'),
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.ctrl], text: 'C'),
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.option], text: 'D'),
  ],
)''',
    ),
    DemoExample(
      title: 'Variants',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final TextStyle label = theme.typography.base.copyWith(
          color: theme.colors.foreground,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            for (final (String name, List<HeroKbdKey> keys, String text)
                in _shortcuts)
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: <Widget>[
                  Text('$name:', style: label),
                  HeroKbd(keys: keys, text: text),
                  HeroKbd(
                    keys: keys,
                    text: text,
                    variant: HeroKbdVariant.light,
                  ),
                ],
              ),
          ],
        );
      },
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 8,
  children: <Widget>[
    Text('Copy:'),
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'C'),
    HeroKbd(
      keys: <HeroKbdKey>[HeroKbdKey.command],
      text: 'C',
      variant: HeroKbdVariant.light,
    ),
  ],
)
// Paste (V), Cut (X), Undo (Z) and Redo (command + shift + Z) follow the
// same pattern.''',
    ),
    DemoExample(
      title: 'Navigation Keys',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final TextStyle label = theme.typography.sm.copyWith(
          color: theme.colors.muted,
        );
        Widget row(String name, List<HeroKbdKey> keys) => Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(name, style: label),
            for (final HeroKbdKey key in keys) HeroKbd(keys: <HeroKbdKey>[key]),
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            row('Arrow Keys:', const <HeroKbdKey>[
              HeroKbdKey.up,
              HeroKbdKey.down,
              HeroKbdKey.left,
              HeroKbdKey.right,
            ]),
            row('Page Navigation:', const <HeroKbdKey>[
              HeroKbdKey.pageup,
              HeroKbdKey.pagedown,
              HeroKbdKey.home,
              HeroKbdKey.end,
            ]),
          ],
        );
      },
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 8,
  children: <Widget>[
    Text('Arrow Keys:', style: mutedSmall),
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.up]),
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.down]),
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.left]),
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.right]),
  ],
)
// Page Navigation: pageup, pagedown, home, end.''',
    ),
    DemoExample(
      title: 'Inline Usage',
      builder: (BuildContext context) => _Sentences(
        spacing: 16,
        sentences: <List<InlineSpan>>[
          <InlineSpan>[
            const TextSpan(text: 'Press '),
            HeroKbd.span(const HeroKbd(text: 'Esc')),
            const TextSpan(text: ' to close the dialog.'),
          ],
          <InlineSpan>[
            const TextSpan(text: 'Use '),
            HeroKbd.span(
              const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'K'),
            ),
            const TextSpan(text: ' to open the command palette.'),
          ],
          <InlineSpan>[
            const TextSpan(text: 'Navigate with '),
            HeroKbd.span(const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.up])),
            const TextSpan(text: ' and '),
            HeroKbd.span(const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.down])),
            const TextSpan(text: ' arrow keys.'),
          ],
          <InlineSpan>[
            const TextSpan(text: 'Save your work with '),
            HeroKbd.span(
              const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'S'),
            ),
            const TextSpan(text: ' regularly.'),
          ],
        ],
      ),
      code: '''
Text.rich(
  TextSpan(
    children: <InlineSpan>[
      TextSpan(text: 'Press '),
      HeroKbd.span(HeroKbd(text: 'Esc')),
      TextSpan(text: ' to close the dialog.'),
    ],
  ),
  style: theme.typography.sm,
)''',
    ),
    DemoExample(
      title: 'Instructional Text',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final TextStyle item = theme.typography.sm.copyWith(
          color: theme.colors.foreground,
        );
        return DecoratedBox(
          decoration: ShapeDecoration(
            color: theme.colors.surface,
            shape: theme.shapeAll(theme.radii.lg),
          ),
          child: Padding(
            padding: EdgeInsets.all(theme.spacing(4)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Quick Actions',
                  style: item.copyWith(fontWeight: HeroTypography.semibold),
                ),
                SizedBox(height: theme.spacing(2)),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: theme.spacing(2),
                  children: <Widget>[
                    for (final (String action, String key)
                        in const <(String, String)>[
                          ('Open search', 'K'),
                          ('Toggle sidebar', 'B'),
                          ('New file', 'N'),
                          ('Quick save', 'S'),
                        ])
                      Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            TextSpan(text: '• $action: '),
                            HeroKbd.span(
                              HeroKbd(
                                keys: const <HeroKbdKey>[HeroKbdKey.command],
                                text: key,
                              ),
                            ),
                          ],
                        ),
                        style: item,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      code: r'''
DecoratedBox(
  decoration: ShapeDecoration(
    color: theme.colors.surface,
    shape: theme.shapeAll(theme.radii.lg),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Text('Quick Actions', style: semiboldSmall),
        for (final (String action, String key) in actions)
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: '• $action: '),
                HeroKbd.span(
                  HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: key),
                ),
              ],
            ),
          ),
      ],
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Special Keys',
      builder: (BuildContext context) => _Sentences(
        spacing: 12,
        sentences: <List<InlineSpan>>[
          <InlineSpan>[
            const TextSpan(text: 'Press '),
            HeroKbd.span(const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.enter])),
            const TextSpan(text: ' to confirm or '),
            HeroKbd.span(const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.escape])),
            const TextSpan(text: ' to cancel.'),
          ],
          <InlineSpan>[
            const TextSpan(text: 'Use '),
            HeroKbd.span(const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.tab])),
            const TextSpan(text: ' to navigate between form fields and '),
            HeroKbd.span(
              const HeroKbd(
                keys: <HeroKbdKey>[HeroKbdKey.shift, HeroKbdKey.tab],
              ),
            ),
            const TextSpan(text: ' to go back.'),
          ],
          <InlineSpan>[
            const TextSpan(text: 'Hold '),
            HeroKbd.span(const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.space])),
            const TextSpan(text: ' to temporarily enable panning mode.'),
          ],
        ],
      ),
      code: '''
Text.rich(
  TextSpan(
    children: <InlineSpan>[
      TextSpan(text: 'Press '),
      HeroKbd.span(HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.enter])),
      TextSpan(text: ' to confirm or '),
      HeroKbd.span(HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.escape])),
      TextSpan(text: ' to cancel.'),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final EdgeInsets padding = EdgeInsets.symmetric(
          horizontal: theme.spacing(2.5),
        );
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.spacing(3),
          children: <Widget>[
            HeroKbd(
              keys: const <HeroKbdKey>[HeroKbdKey.command],
              text: 'K',
              backgroundColor: theme.colors.accentSoft,
              foregroundColor: theme.colors.accentSoftForeground,
              padding: padding,
            ),
            HeroKbd(
              keys: const <HeroKbdKey>[HeroKbdKey.shift],
              text: 'P',
              backgroundColor: theme.colors.defaultColor,
              foregroundColor: theme.colors.muted,
              padding: padding,
            ),
          ],
        );
      },
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: <Widget>[
    HeroKbd(
      keys: <HeroKbdKey>[HeroKbdKey.command],
      text: 'K',
      backgroundColor: theme.colors.accentSoft,
      foregroundColor: theme.colors.accentSoftForeground,
      padding: EdgeInsets.symmetric(horizontal: 10),
    ),
    HeroKbd(
      keys: <HeroKbdKey>[HeroKbdKey.shift],
      text: 'P',
      backgroundColor: theme.colors.defaultColor,
      foregroundColor: theme.colors.muted,
      padding: EdgeInsets.symmetric(horizontal: 10),
    ),
  ],
)''',
    ),
  ],
);

const List<(String, List<HeroKbdKey>, String)> _shortcuts =
    <(String, List<HeroKbdKey>, String)>[
      ('Copy', <HeroKbdKey>[HeroKbdKey.command], 'C'),
      ('Paste', <HeroKbdKey>[HeroKbdKey.command], 'V'),
      ('Cut', <HeroKbdKey>[HeroKbdKey.command], 'X'),
      ('Undo', <HeroKbdKey>[HeroKbdKey.command], 'Z'),
      ('Redo', <HeroKbdKey>[HeroKbdKey.command, HeroKbdKey.shift], 'Z'),
    ];

class _Sentences extends StatelessWidget {
  const _Sentences({required this.sentences, required this.spacing});

  final List<List<InlineSpan>> sentences;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle style = theme.typography.sm.copyWith(
      color: theme.colors.foreground,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing,
      children: <Widget>[
        for (final List<InlineSpan> sentence in sentences)
          Text.rich(TextSpan(children: sentence), style: style),
      ],
    );
  }
}
