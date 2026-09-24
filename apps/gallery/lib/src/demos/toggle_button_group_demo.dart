import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const List<(String, String, HeroIconData)> _formatting =
    <(String, String, HeroIconData)>[
      ('bold', 'Bold', HeroIcons.bold),
      ('italic', 'Italic', HeroIcons.italic),
      ('underline', 'Underline', HeroIcons.underline),
      ('strikethrough', 'Strikethrough', HeroIcons.strikethrough),
    ];

/// The formatting buttons used throughout the docs examples.
List<Widget> _formattingButtons({
  int count = 4,
  bool separators = true,
  Set<String> disabled = const <String>{},
  HeroToggleButtonStyle? style,
}) => <Widget>[
  for (int i = 0; i < count; i++)
    HeroToggleButton(
      id: _formatting[i].$1,
      isIconOnly: true,
      semanticLabel: _formatting[i].$2,
      isDisabled: disabled.contains(_formatting[i].$1) ? true : null,
      style: style,
      separator: separators && i > 0
          ? const HeroToggleButtonGroupSeparator()
          : null,
      child: HeroIcon(_formatting[i].$3),
    ),
];

List<Widget> _alignmentButtons() => const <Widget>[
  HeroToggleButton(
    id: 'left',
    startContent: HeroIcon(HeroIcons.textAlignLeft),
    child: Text('Left'),
  ),
  HeroToggleButton(
    id: 'center',
    separator: HeroToggleButtonGroupSeparator(),
    startContent: HeroIcon(HeroIcons.textAlignCenter),
    child: Text('Center'),
  ),
  HeroToggleButton(
    id: 'right',
    separator: HeroToggleButtonGroupSeparator(),
    startContent: HeroIcon(HeroIcons.textAlignRight),
    child: Text('Right'),
  ),
];

const String _formattingCode = '''
HeroToggleButtonGroup(
  selectionMode: HeroSelectionMode.multiple,
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
    HeroToggleButton(
      id: 'strikethrough',
      isIconOnly: true,
      semanticLabel: 'Strikethrough',
      separator: HeroToggleButtonGroupSeparator(),
      child: HeroIcon(HeroIcons.strikethrough),
    ),
  ],
)''';

/// A muted caption above a variant, like the docs' `text-sm text-muted`.
class _Captioned extends StatelessWidget {
  const _Captioned(this.caption, this.child);

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Text(
          caption,
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
        child,
      ],
    );
  }
}

final ComponentDemo toggleButtonGroupDemo = ComponentDemo(
  slug: 'toggle-button-group',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('selectionMode', <String>['single', 'multiple']),
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      OptionsControl('orientation', <String>['horizontal', 'vertical']),
      ToggleControl('isDetached'),
      ToggleControl('fullWidth'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final bool detached = values.toggle('isDetached');
      return HeroToggleButtonGroup(
        key: ValueKey<String>(values.option('selectionMode')),
        selectionMode: values.pick('selectionMode', HeroSelectionMode.values),
        size: values.pick('size', HeroSize.values),
        orientation: values.pick('orientation', Axis.values),
        isDetached: detached,
        fullWidth: values.toggle('fullWidth'),
        isDisabled: values.toggle('isDisabled'),
        children: _formattingButtons(separators: !detached),
      );
    },
    code: (PlaygroundValues values) =>
        '''
HeroToggleButtonGroup(
  selectionMode: HeroSelectionMode.${values.option('selectionMode')},
  size: HeroSize.${values.option('size')},
  orientation: Axis.${values.option('orientation')},
  isDetached: ${values.toggle('isDetached')},
  fullWidth: ${values.toggle('fullWidth')},
  isDisabled: ${values.toggle('isDisabled')},
  children: <Widget>[
    HeroToggleButton(
      id: 'bold',
      isIconOnly: true,
      semanticLabel: 'Bold',
      child: const HeroIcon(HeroIcons.bold),
    ),
    HeroToggleButton(
      id: 'italic',
      isIconOnly: true,
      semanticLabel: 'Italic',
      separator: const HeroToggleButtonGroupSeparator(),
      child: const HeroIcon(HeroIcons.italic),
    ),
    // ...
  ],
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => HeroToggleButtonGroup(
        selectionMode: HeroSelectionMode.multiple,
        children: _formattingButtons(),
      ),
      code: _formattingCode,
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: <Widget>[
          for (final (HeroSize size, String caption) in <(HeroSize, String)>[
            (HeroSize.sm, 'Small'),
            (HeroSize.md, 'Medium (default)'),
            (HeroSize.lg, 'Large'),
          ])
            _Captioned(
              caption,
              HeroToggleButtonGroup(
                selectionMode: HeroSelectionMode.multiple,
                size: size,
                children: _formattingButtons(),
              ),
            ),
        ],
      ),
      code: '''
HeroToggleButtonGroup(
  selectionMode: HeroSelectionMode.multiple,
  size: HeroSize.sm, // HeroSize.md, HeroSize.lg
  children: formattingButtons,
)''',
    ),
    DemoExample(
      title: 'Orientation',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 32,
        children: <Widget>[
          _Captioned(
            'Horizontal',
            HeroToggleButtonGroup(
              selectionMode: HeroSelectionMode.multiple,
              children: _formattingButtons(count: 3),
            ),
          ),
          _Captioned(
            'Vertical',
            HeroToggleButtonGroup(
              orientation: Axis.vertical,
              selectionMode: HeroSelectionMode.multiple,
              children: _formattingButtons(count: 3),
            ),
          ),
        ],
      ),
      code: '''
HeroToggleButtonGroup(
  orientation: Axis.vertical,
  selectionMode: HeroSelectionMode.multiple,
  children: <Widget>[
    HeroToggleButton(
      id: 'bold',
      isIconOnly: true,
      semanticLabel: 'Bold',
      child: const HeroIcon(HeroIcons.bold),
    ),
    HeroToggleButton(
      id: 'italic',
      isIconOnly: true,
      semanticLabel: 'Italic',
      separator: const HeroToggleButtonGroupSeparator(),
      child: const HeroIcon(HeroIcons.italic),
    ),
    HeroToggleButton(
      id: 'underline',
      isIconOnly: true,
      semanticLabel: 'Underline',
      separator: const HeroToggleButtonGroupSeparator(),
      child: const HeroIcon(HeroIcons.underline),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Full Width',
      builder: (BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 448),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            HeroToggleButtonGroup(
              fullWidth: true,
              selectionMode: HeroSelectionMode.multiple,
              children: _formattingButtons(),
            ),
            HeroToggleButtonGroup(
              fullWidth: true,
              children: _alignmentButtons(),
            ),
          ],
        ),
      ),
      code: '''
HeroToggleButtonGroup(
  fullWidth: true,
  children: <Widget>[
    HeroToggleButton(
      id: 'left',
      startContent: const HeroIcon(HeroIcons.textAlignLeft),
      child: const Text('Left'),
    ),
    HeroToggleButton(
      id: 'center',
      separator: const HeroToggleButtonGroupSeparator(),
      startContent: const HeroIcon(HeroIcons.textAlignCenter),
      child: const Text('Center'),
    ),
    HeroToggleButton(
      id: 'right',
      separator: const HeroToggleButtonGroupSeparator(),
      startContent: const HeroIcon(HeroIcons.textAlignRight),
      child: const Text('Right'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: <Widget>[
          _Captioned(
            'All buttons disabled',
            HeroToggleButtonGroup(
              isDisabled: true,
              selectionMode: HeroSelectionMode.multiple,
              children: _formattingButtons(count: 3),
            ),
          ),
          _Captioned(
            'Individual button disabled',
            HeroToggleButtonGroup(
              selectionMode: HeroSelectionMode.multiple,
              children: _formattingButtons(
                count: 3,
                disabled: const <String>{'italic'},
              ),
            ),
          ),
        ],
      ),
      code: '''
// The whole group.
HeroToggleButtonGroup(
  isDisabled: true,
  selectionMode: HeroSelectionMode.multiple,
  children: formattingButtons,
)

// One button.
HeroToggleButton(
  id: 'italic',
  isDisabled: true,
  isIconOnly: true,
  semanticLabel: 'Italic',
  separator: const HeroToggleButtonGroupSeparator(),
  child: const HeroIcon(HeroIcons.italic),
)''',
    ),
    DemoExample(
      title: 'Without Separator',
      description:
          'Leave out the separator of the buttons to remove the dividers.',
      builder: (BuildContext context) => HeroToggleButtonGroup(
        selectionMode: HeroSelectionMode.multiple,
        children: _formattingButtons(separators: false),
      ),
      code: '''
HeroToggleButtonGroup(
  selectionMode: HeroSelectionMode.multiple,
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
      child: HeroIcon(HeroIcons.italic),
    ),
    // ...
  ],
)''',
    ),
    DemoExample(
      title: 'Detached',
      description:
          'Use isDetached to separate buttons with gaps instead of connecting '
          'them.',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: <Widget>[
          _Captioned(
            'Attached (default)',
            HeroToggleButtonGroup(
              selectionMode: HeroSelectionMode.multiple,
              children: _formattingButtons(),
            ),
          ),
          _Captioned(
            'Detached',
            HeroToggleButtonGroup(
              isDetached: true,
              selectionMode: HeroSelectionMode.multiple,
              children: _formattingButtons(separators: false),
            ),
          ),
        ],
      ),
      code: '''
HeroToggleButtonGroup(
  isDetached: true,
  selectionMode: HeroSelectionMode.multiple,
  children: const <Widget>[
    HeroToggleButton(
      id: 'bold',
      isIconOnly: true,
      semanticLabel: 'Bold',
      child: HeroIcon(HeroIcons.bold),
    ),
    // ...
  ],
)''',
    ),
    DemoExample(
      title: 'Selection Mode',
      description:
          'Use single selection for mutually exclusive choices or multiple '
          'selection for independent toggles.',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: <Widget>[
          _Captioned(
            'Single selection',
            HeroToggleButtonGroup(
              defaultSelectedKeys: const <Object>{'center'},
              children: _alignmentButtons(),
            ),
          ),
          _Captioned(
            'Multiple selection',
            HeroToggleButtonGroup(
              selectionMode: HeroSelectionMode.multiple,
              defaultSelectedKeys: const <Object>{'bold', 'underline'},
              children: _formattingButtons(),
            ),
          ),
        ],
      ),
      code: '''
HeroToggleButtonGroup(
  defaultSelectedKeys: const <Object>{'center'},
  children: alignmentButtons,
)

HeroToggleButtonGroup(
  selectionMode: HeroSelectionMode.multiple,
  defaultSelectedKeys: const <Object>{'bold', 'underline'},
  children: formattingButtons,
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _ControlledGroup(),
      code: r'''
Set<Object> selectedKeys = <Object>{'bold'};

Column(
  spacing: 16,
  children: <Widget>[
    HeroToggleButtonGroup(
      selectionMode: HeroSelectionMode.multiple,
      selectedKeys: selectedKeys,
      onSelectionChanged: (Set<Object> keys) =>
          setState(() => selectedKeys = keys),
      children: formattingButtons,
    ),
    Text(
      'Selected: ${selectedKeys.isEmpty ? 'None' : selectedKeys.join(', ')}',
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A toolbar look: a bordered surface container with rounded-square '
          'buttons.',
      builder: (BuildContext context) => const _CustomGroup(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final HeroColors colors = theme.colors;
final HeroToggleButtonStyle style = HeroToggleButtonStyle(
  borderRadius: BorderRadius.all(Radius.circular(theme.radii.lg)),
  backgroundColor: WidgetStateProperty.resolveWith(
    (Set<WidgetState> states) =>
        states.contains(WidgetState.selected) ? colors.accentSoft : null,
  ),
  foregroundColor: WidgetStateProperty.resolveWith(
    (Set<WidgetState> states) => states.contains(WidgetState.selected)
        ? colors.accentSoftForeground
        : colors.muted,
  ),
);

DecoratedBox(
  decoration: ShapeDecoration(
    color: colors.surface,
    shadows: theme.shadows.surface.boxShadows,
    shape: theme.shapeAll(
      theme.radii.xl,
      side: BorderSide(color: colors.border.withValues(alpha: 0.8)),
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(4),
    child: HeroToggleButtonGroup(
      semanticLabel: 'Text formatting',
      isDetached: true,
      selectionMode: HeroSelectionMode.multiple,
      children: <Widget>[
        HeroToggleButton(
          id: 'bold',
          isIconOnly: true,
          semanticLabel: 'Bold',
          style: style,
          child: const HeroIcon(HeroIcons.bold),
        ),
        // Italic and Underline alike.
      ],
    ),
  ),
)''',
    ),
  ],
);

class _ControlledGroup extends StatefulWidget {
  const _ControlledGroup();

  @override
  State<_ControlledGroup> createState() => _ControlledGroupState();
}

class _ControlledGroupState extends State<_ControlledGroup> {
  Set<Object> _selectedKeys = <Object>{'bold'};

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        HeroToggleButtonGroup(
          selectionMode: HeroSelectionMode.multiple,
          selectedKeys: _selectedKeys,
          onSelectionChanged: (Set<Object> keys) =>
              setState(() => _selectedKeys = keys),
          children: _formattingButtons(),
        ),
        Text.rich(
          TextSpan(
            text: 'Selected: ',
            children: <InlineSpan>[
              TextSpan(
                text: _selectedKeys.isEmpty ? 'None' : _selectedKeys.join(', '),
                style: const TextStyle(fontWeight: HeroTypography.medium),
              ),
            ],
          ),
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
      ],
    );
  }
}

class _CustomGroup extends StatelessWidget {
  const _CustomGroup();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final HeroToggleButtonStyle style = HeroToggleButtonStyle(
      borderRadius: BorderRadius.all(Radius.circular(theme.radii.lg)),
      backgroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.selected) ? colors.accentSoft : null,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? colors.accentSoftForeground
            : colors.muted,
      ),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.surface,
        shadows: theme.shadows.surface.boxShadows,
        shape: theme.shapeAll(
          theme.radii.xl,
          side: BorderSide(
            color: colors.border.withValues(alpha: colors.border.a * 0.8),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.spacing(1)),
        child: HeroToggleButtonGroup(
          semanticLabel: 'Text formatting',
          isDetached: true,
          selectionMode: HeroSelectionMode.multiple,
          children: _formattingButtons(
            count: 3,
            separators: false,
            style: style,
          ),
        ),
      ),
    );
  }
}
