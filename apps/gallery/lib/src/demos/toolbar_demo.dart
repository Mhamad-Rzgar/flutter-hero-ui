import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Bold / Italic / Underline toggles with group separators.
HeroToggleButtonGroup _textStyle({
  HeroToggleButtonStyle? style,
  bool separators = true,
  double? gap,
}) => HeroToggleButtonGroup(
  selectionMode: HeroSelectionMode.multiple,
  semanticLabel: 'Text style',
  gap: gap,
  children: <Widget>[
    HeroToggleButton(
      id: 'bold',
      isIconOnly: true,
      semanticLabel: 'Bold',
      style: style,
      child: const HeroIcon(HeroIcons.bold),
    ),
    HeroToggleButton(
      id: 'italic',
      isIconOnly: true,
      semanticLabel: 'Italic',
      style: style,
      separator: separators ? const HeroToggleButtonGroupSeparator() : null,
      child: const HeroIcon(HeroIcons.italic),
    ),
    HeroToggleButton(
      id: 'underline',
      isIconOnly: true,
      semanticLabel: 'Underline',
      style: style,
      separator: separators ? const HeroToggleButtonGroupSeparator() : null,
      child: const HeroIcon(HeroIcons.underline),
    ),
  ],
);

/// A tertiary group of icon-only buttons with separators.
HeroButtonGroup _iconGroup(List<(String, HeroIconData)> buttons) =>
    HeroButtonGroup(
      variant: HeroButtonVariant.tertiary,
      children: <Widget>[
        for (int i = 0; i < buttons.length; i++) ...<Widget>[
          if (i > 0) const HeroButtonGroupSeparator(),
          HeroButton(
            isIconOnly: true,
            semanticLabel: buttons[i].$1,
            onPressed: () {},
            child: HeroIcon(buttons[i].$2),
          ),
        ],
      ],
    );

const List<(String, HeroIconData)> _clipboard = <(String, HeroIconData)>[
  ('Copy', HeroIcons.copy),
  ('Cut', HeroIcons.scissors),
];

const List<(String, HeroIconData)> _history = <(String, HeroIconData)>[
  ('Undo', HeroIcons.arrowUturnCcwLeft),
  ('Redo', HeroIcons.arrowUturnCwRight),
];

const List<(String, HeroIconData)> _alignment = <(String, HeroIconData)>[
  ('Align left', HeroIcons.textAlignLeft),
  ('Align center', HeroIcons.textAlignCenter),
  ('Align right', HeroIcons.textAlignRight),
];

const String _textStyleCode = '''
HeroToggleButtonGroup(
      selectionMode: HeroSelectionMode.multiple,
      semanticLabel: 'Text style',
      children: const <Widget>[
        HeroToggleButton(
          id: 'bold',
          isIconOnly: true,
          semanticLabel: 'Bold',
          child: HeroIcon(HeroIcons.bold),
        ),
        HeroToggleButton(
          id: 'italic',
          isIconOnly: true,
          semanticLabel: 'Italic',
          separator: HeroToggleButtonGroupSeparator(),
          child: HeroIcon(HeroIcons.italic),
        ),
        HeroToggleButton(
          id: 'underline',
          isIconOnly: true,
          semanticLabel: 'Underline',
          separator: HeroToggleButtonGroupSeparator(),
          child: HeroIcon(HeroIcons.underline),
        ),
      ],
    )''';

String _iconGroupCode(List<(String, String)> buttons) {
  final StringBuffer out = StringBuffer()
    ..writeln('HeroButtonGroup(')
    ..writeln('      variant: HeroButtonVariant.tertiary,')
    ..writeln('      children: <Widget>[');
  for (int i = 0; i < buttons.length; i++) {
    if (i > 0) out.writeln('        const HeroButtonGroupSeparator(),');
    out
      ..writeln('        HeroButton(')
      ..writeln('          isIconOnly: true,')
      ..writeln("          semanticLabel: '${buttons[i].$1}',")
      ..writeln('          onPressed: () {},')
      ..writeln('          child: const HeroIcon(HeroIcons.${buttons[i].$2}),')
      ..writeln('        ),');
  }
  out.write('      ],\n    )');
  return out.toString();
}

final String _basicCode =
    '''
HeroToolbar(
  semanticLabel: 'Text formatting',
  children: <Widget>[
    $_textStyleCode,
    const HeroSeparator(),
    ${_iconGroupCode(const <(String, String)>[('Copy', 'copy'), ('Cut', 'scissors')])},
  ],
)''';

/// Gallery page of `HeroToolbar`.
final ComponentDemo toolbarDemo = ComponentDemo(
  slug: 'toolbar',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('orientation', <String>[
        'horizontal',
        'vertical',
      ], initial: 'horizontal'),
      ToggleControl('isAttached'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroToolbar(
      orientation: values.pick('orientation', Axis.values),
      isAttached: values.toggle('isAttached'),
      semanticLabel: 'Text formatting',
      children: <Widget>[
        _textStyle(),
        const HeroSeparator(),
        _iconGroup(_clipboard),
      ],
    ),
    code: (PlaygroundValues values) => _basicCode.replaceFirst(
      'HeroToolbar(\n',
      'HeroToolbar(\n'
          '  orientation: Axis.${values.option('orientation')},\n'
          '  isAttached: ${values.toggle('isAttached')},\n',
    ),
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => HeroToolbar(
        semanticLabel: 'Text formatting',
        children: <Widget>[
          _textStyle(),
          const HeroSeparator(),
          _iconGroup(_clipboard),
        ],
      ),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Vertical',
      builder: (BuildContext context) => HeroToolbar(
        orientation: Axis.vertical,
        semanticLabel: 'Tools',
        children: <Widget>[
          _textStyle(),
          const HeroSeparator(),
          _iconGroup(_history),
        ],
      ),
      code:
          '''
HeroToolbar(
  orientation: Axis.vertical,
  semanticLabel: 'Tools',
  children: <Widget>[
    $_textStyleCode,
    const HeroSeparator(),
    ${_iconGroupCode(const <(String, String)>[('Undo', 'arrowUturnCcwLeft'), ('Redo', 'arrowUturnCwRight')])},
  ],
)''',
    ),
    DemoExample(
      title: 'Attached',
      builder: (BuildContext context) => HeroToolbar(
        isAttached: true,
        semanticLabel: 'Text formatting',
        children: <Widget>[
          _textStyle(),
          const HeroSeparator(),
          _iconGroup(_clipboard),
        ],
      ),
      code: _basicCode.replaceFirst(
        'HeroToolbar(\n',
        'HeroToolbar(\n  isAttached: true,\n',
      ),
    ),
    DemoExample(
      title: 'With ButtonGroup',
      builder: (BuildContext context) => HeroToolbar(
        semanticLabel: 'Editor toolbar',
        children: <Widget>[
          HeroButtonGroup(
            variant: HeroButtonVariant.tertiary,
            children: <Widget>[
              HeroButton(
                onPressed: () {},
                startContent: const HeroIcon(HeroIcons.arrowUturnCcwLeft),
                child: const Text('Undo'),
              ),
              const HeroButtonGroupSeparator(),
              HeroButton(
                onPressed: () {},
                startContent: const HeroIcon(HeroIcons.arrowUturnCwRight),
                child: const Text('Redo'),
              ),
            ],
          ),
          const HeroSeparator(),
          _textStyle(),
          const HeroSeparator(),
          _iconGroup(_alignment),
        ],
      ),
      code:
          '''
HeroToolbar(
  semanticLabel: 'Editor toolbar',
  children: <Widget>[
    HeroButtonGroup(
      variant: HeroButtonVariant.tertiary,
      children: <Widget>[
        HeroButton(
          onPressed: undo,
          startContent: const HeroIcon(HeroIcons.arrowUturnCcwLeft),
          child: const Text('Undo'),
        ),
        const HeroButtonGroupSeparator(),
        HeroButton(
          onPressed: redo,
          startContent: const HeroIcon(HeroIcons.arrowUturnCwRight),
          child: const Text('Redo'),
        ),
      ],
    ),
    const HeroSeparator(),
    $_textStyleCode,
    const HeroSeparator(),
    ${_iconGroupCode(const <(String, String)>[('Align left', 'textAlignLeft'), ('Align center', 'textAlignCenter'), ('Align right', 'textAlignRight')])},
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A compact toolbar on a bordered secondary surface whose selected '
          'toggles turn accent.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final HeroColors colors = theme.colors;
        bool selected(Set<WidgetState> states) =>
            states.contains(WidgetState.selected);
        return HeroToolbar(
          semanticLabel: 'Formatting toolbar',
          gap: theme.spacing(1),
          padding: EdgeInsets.all(theme.spacing(1.5)),
          decoration: ShapeDecoration(
            color: colors.surfaceSecondary,
            shape: theme.shapeAll(
              theme.radii.xl,
              side: BorderSide(
                color: colors.border.withValues(alpha: colors.border.a * 0.8),
              ),
            ),
          ),
          children: <Widget>[
            _textStyle(
              separators: false,
              gap: theme.spacing(0.5),
              style: HeroToggleButtonStyle(
                borderRadius: BorderRadius.all(Radius.circular(theme.radii.lg)),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (Set<WidgetState> states) =>
                      selected(states) ? colors.accent : null,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (Set<WidgetState> states) =>
                      selected(states) ? colors.accentForeground : null,
                ),
              ),
            ),
          ],
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final HeroColors colors = theme.colors;
bool selected(Set<WidgetState> states) =>
    states.contains(WidgetState.selected);
final HeroToggleButtonStyle toggle = HeroToggleButtonStyle(
  borderRadius: BorderRadius.circular(theme.radii.lg),
  backgroundColor: WidgetStateProperty.resolveWith(
    (Set<WidgetState> s) => selected(s) ? colors.accent : null,
  ),
  foregroundColor: WidgetStateProperty.resolveWith(
    (Set<WidgetState> s) => selected(s) ? colors.accentForeground : null,
  ),
);

HeroToolbar(
  semanticLabel: 'Formatting toolbar',
  gap: 4,
  padding: const EdgeInsets.all(6),
  decoration: ShapeDecoration(
    color: colors.surfaceSecondary,
    shape: theme.shapeAll(
      theme.radii.xl,
      side: BorderSide(color: colors.border.withValues(alpha: 0.8)),
    ),
  ),
  children: <Widget>[
    HeroToggleButtonGroup(
      selectionMode: HeroSelectionMode.multiple,
      semanticLabel: 'Text style',
      gap: 2,
      children: <Widget>[
        HeroToggleButton(id: 'bold', isIconOnly: true, semanticLabel: 'Bold', style: toggle, child: const HeroIcon(HeroIcons.bold)),
        HeroToggleButton(id: 'italic', isIconOnly: true, semanticLabel: 'Italic', style: toggle, child: const HeroIcon(HeroIcons.italic)),
        HeroToggleButton(id: 'underline', isIconOnly: true, semanticLabel: 'Underline', style: toggle, child: const HeroIcon(HeroIcons.underline)),
      ],
    ),
  ],
)''',
    ),
  ],
);
