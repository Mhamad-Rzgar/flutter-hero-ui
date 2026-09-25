import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// A muted caption above an example (`text-sm text-muted`).
class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Text(
      text,
      style: theme.typography.sm.copyWith(color: theme.colors.muted),
    );
  }
}

Widget _captioned(String caption, Widget child) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 8,
  children: <Widget>[_Caption(caption), child],
);

/// First / Second / Third with separators.
List<Widget> _firstSecondThird({bool separators = true, bool? thirdEnabled}) =>
    <Widget>[
      HeroButton(onPressed: () {}, child: const Text('First')),
      if (separators) const HeroButtonGroupSeparator(),
      HeroButton(onPressed: () {}, child: const Text('Second')),
      if (separators) const HeroButtonGroupSeparator(),
      HeroButton(
        isDisabled: thirdEnabled == true ? false : null,
        onPressed: () {},
        child: Text(thirdEnabled == true ? 'Third (enabled)' : 'Third'),
      ),
    ];

const List<(String, HeroIconData)> _alignments = <(String, HeroIconData)>[
  ('Align left', HeroIcons.textAlignLeft),
  ('Align center', HeroIcons.textAlignCenter),
  ('Align right', HeroIcons.textAlignRight),
  ('Justify', HeroIcons.textAlignJustify),
];

List<Widget> _alignmentButtons({int count = 4}) => <Widget>[
  for (int i = 0; i < count; i++) ...<Widget>[
    if (i > 0) const HeroButtonGroupSeparator(),
    HeroButton(
      isIconOnly: true,
      semanticLabel: _alignments[i].$1,
      onPressed: () {},
      child: HeroIcon(_alignments[i].$2),
    ),
  ],
];

const String _firstSecondThirdCode = '''
    HeroButton(onPressed: () {}, child: const Text('First')),
    const HeroButtonGroupSeparator(),
    HeroButton(onPressed: () {}, child: const Text('Second')),
    const HeroButtonGroupSeparator(),
    HeroButton(onPressed: () {}, child: const Text('Third')),''';

const String _alignmentCode = '''
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Align left',
      onPressed: () {},
      child: const HeroIcon(HeroIcons.textAlignLeft),
    ),
    const HeroButtonGroupSeparator(),
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Align center',
      onPressed: () {},
      child: const HeroIcon(HeroIcons.textAlignCenter),
    ),
    const HeroButtonGroupSeparator(),
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Align right',
      onPressed: () {},
      child: const HeroIcon(HeroIcons.textAlignRight),
    ),
    const HeroButtonGroupSeparator(),
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Justify',
      onPressed: () {},
      child: const HeroIcon(HeroIcons.textAlignJustify),
    ),''';

/// Gallery page of `HeroButtonGroup`.
final ComponentDemo buttonGroupDemo = ComponentDemo(
  slug: 'button-group',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>[
        'primary',
        'secondary',
        'tertiary',
        'outline',
        'ghost',
        'danger',
        'dangerSoft',
      ]),
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      OptionsControl('orientation', <String>['horizontal', 'vertical']),
      ToggleControl('separators', initial: true),
      ToggleControl('fullWidth'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final Widget group = HeroButtonGroup(
        variant: values.pick('variant', HeroButtonVariant.values),
        size: values.pick('size', HeroSize.values),
        orientation: values.pick('orientation', Axis.values),
        fullWidth: values.toggle('fullWidth'),
        isDisabled: values.toggle('isDisabled'),
        children: _firstSecondThird(separators: values.toggle('separators')),
      );
      return values.toggle('fullWidth')
          ? SizedBox(width: 320, child: group)
          : group;
    },
    code: (PlaygroundValues values) {
      final bool separators = values.toggle('separators');
      final String sep = separators
          ? '\n    const HeroButtonGroupSeparator(),'
          : '';
      return '''
HeroButtonGroup(
  variant: HeroButtonVariant.${values.option('variant')},
  size: HeroSize.${values.option('size')},
  orientation: Axis.${values.option('orientation')},${values.toggle('fullWidth') ? '\n  fullWidth: true,' : ''}${values.toggle('isDisabled') ? '\n  isDisabled: true,' : ''}
  children: [
    HeroButton(onPressed: () {}, child: const Text('First')),$sep
    HeroButton(onPressed: () {}, child: const Text('Second')),$sep
    HeroButton(onPressed: () {}, child: const Text('Third')),
  ],
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Variants',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: <Widget>[
          for (final (String, HeroButtonVariant) v
              in const <(String, HeroButtonVariant)>[
                ('Primary', HeroButtonVariant.primary),
                ('Secondary', HeroButtonVariant.secondary),
                ('Tertiary', HeroButtonVariant.tertiary),
                ('Outline', HeroButtonVariant.outline),
                ('Ghost', HeroButtonVariant.ghost),
                ('Danger', HeroButtonVariant.danger),
              ])
            _captioned(
              v.$1,
              HeroButtonGroup(variant: v.$2, children: _firstSecondThird()),
            ),
        ],
      ),
      code:
          '''
// Primary, secondary, tertiary, outline, ghost and danger:
HeroButtonGroup(
  variant: HeroButtonVariant.primary,
  children: [
$_firstSecondThirdCode
  ],
)''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          for (final (String, HeroSize) s in const <(String, HeroSize)>[
            ('Small', HeroSize.sm),
            ('Medium (default)', HeroSize.md),
            ('Large', HeroSize.lg),
          ])
            _captioned(
              s.$1,
              HeroButtonGroup(
                size: s.$2,
                variant: HeroButtonVariant.secondary,
                children: _firstSecondThird(),
              ),
            ),
        ],
      ),
      code:
          '''
HeroButtonGroup(
  size: HeroSize.sm, // md, lg
  variant: HeroButtonVariant.secondary,
  children: [
$_firstSecondThirdCode
  ],
)''',
    ),
    DemoExample(
      title: 'Orientation',
      builder: (BuildContext context) => Wrap(
        spacing: 32,
        runSpacing: 16,
        children: <Widget>[
          _captioned(
            'Horizontal',
            HeroButtonGroup(
              variant: HeroButtonVariant.tertiary,
              children: _alignmentButtons(),
            ),
          ),
          _captioned(
            'Vertical',
            HeroButtonGroup(
              orientation: Axis.vertical,
              variant: HeroButtonVariant.tertiary,
              children: _alignmentButtons(),
            ),
          ),
        ],
      ),
      code:
          '''
HeroButtonGroup(
  orientation: Axis.vertical, // Axis.horizontal is the default
  variant: HeroButtonVariant.tertiary,
  children: [
$_alignmentCode
  ],
)''',
    ),
    DemoExample(
      title: 'With Icons',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: <Widget>[
          _captioned(
            'With icons',
            HeroButtonGroup(
              variant: HeroButtonVariant.secondary,
              children: <Widget>[
                HeroButton(
                  startContent: const HeroIcon(HeroIcons.globe),
                  onPressed: () {},
                  child: const Text('Search'),
                ),
                const HeroButtonGroupSeparator(),
                HeroButton(
                  startContent: const HeroIcon(HeroIcons.plus),
                  onPressed: () {},
                  child: const Text('Add'),
                ),
                const HeroButtonGroupSeparator(),
                HeroButton(
                  startContent: const HeroIcon(HeroIcons.trashBin),
                  onPressed: () {},
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
          _captioned(
            'Icon only buttons',
            HeroButtonGroup(
              variant: HeroButtonVariant.tertiary,
              children: <Widget>[
                HeroButton(
                  isIconOnly: true,
                  semanticLabel: 'Search',
                  onPressed: () {},
                  child: const HeroIcon(HeroIcons.globe),
                ),
                const HeroButtonGroupSeparator(),
                HeroButton(
                  isIconOnly: true,
                  semanticLabel: 'Add',
                  onPressed: () {},
                  child: const HeroIcon(HeroIcons.plus),
                ),
                const HeroButtonGroupSeparator(),
                HeroButton(
                  isIconOnly: true,
                  semanticLabel: 'Delete',
                  onPressed: () {},
                  child: const HeroIcon(HeroIcons.trashBin),
                ),
              ],
            ),
          ),
        ],
      ),
      code: '''
HeroButtonGroup(
  variant: HeroButtonVariant.secondary,
  children: [
    HeroButton(
      startContent: const HeroIcon(HeroIcons.globe),
      onPressed: () {},
      child: const Text('Search'),
    ),
    const HeroButtonGroupSeparator(),
    HeroButton(
      startContent: const HeroIcon(HeroIcons.plus),
      onPressed: () {},
      child: const Text('Add'),
    ),
    const HeroButtonGroupSeparator(),
    HeroButton(
      startContent: const HeroIcon(HeroIcons.trashBin),
      onPressed: () {},
      child: const Text('Delete'),
    ),
  ],
)

HeroButtonGroup(
  variant: HeroButtonVariant.tertiary,
  children: [
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Search',
      onPressed: () {},
      child: const HeroIcon(HeroIcons.globe),
    ),
    const HeroButtonGroupSeparator(),
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Add',
      onPressed: () {},
      child: const HeroIcon(HeroIcons.plus),
    ),
    const HeroButtonGroupSeparator(),
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Delete',
      onPressed: () {},
      child: const HeroIcon(HeroIcons.trashBin),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Full Width',
      builder: (BuildContext context) => SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            HeroButtonGroup(fullWidth: true, children: _firstSecondThird()),
            HeroButtonGroup(
              fullWidth: true,
              children: _alignmentButtons(count: 3),
            ),
          ],
        ),
      ),
      code:
          '''
SizedBox(
  width: 400,
  child: HeroButtonGroup(
    fullWidth: true,
    children: [
$_firstSecondThirdCode
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Disabled State',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: <Widget>[
          _captioned(
            'All buttons disabled',
            HeroButtonGroup(isDisabled: true, children: _firstSecondThird()),
          ),
          _captioned(
            'Group disabled, but one button overrides',
            HeroButtonGroup(
              isDisabled: true,
              children: _firstSecondThird(thirdEnabled: true),
            ),
          ),
        ],
      ),
      code: '''
HeroButtonGroup(
  isDisabled: true,
  children: [
    HeroButton(onPressed: () {}, child: const Text('First')),
    const HeroButtonGroupSeparator(),
    HeroButton(onPressed: () {}, child: const Text('Second')),
    const HeroButtonGroupSeparator(),
    // A button's own isDisabled wins over the group.
    HeroButton(
      isDisabled: false,
      onPressed: () {},
      child: const Text('Third (enabled)'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Without Separator',
      description: 'Leave out the HeroButtonGroupSeparator widgets.',
      builder: (BuildContext context) =>
          HeroButtonGroup(children: _firstSecondThird(separators: false)),
      code: '''
HeroButtonGroup(
  children: [
    HeroButton(onPressed: () {}, child: const Text('First')),
    HeroButton(onPressed: () {}, child: const Text('Second')),
    HeroButton(onPressed: () {}, child: const Text('Third')),
  ],
)''',
    ),
  ],
);
