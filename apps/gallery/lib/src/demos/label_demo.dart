import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroLabel`, reproducing heroui.com/docs/components/label.
final ComponentDemo labelDemo = ComponentDemo(
  slug: 'label',
  playground: Playground(
    controls: const <PlaygroundControl>[
      ToggleControl('isRequired'),
      ToggleControl('isDisabled'),
      ToggleControl('isInvalid'),
      TextControl('text', initial: 'Name'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => _LabeledField(
      builder: (BuildContext context, FocusNode focusNode) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: <Widget>[
          HeroLabel.text(
            values.text('text'),
            focusNode: focusNode,
            isRequired: values.toggle('isRequired'),
            isDisabled: values.toggle('isDisabled'),
            isInvalid: values.toggle('isInvalid'),
          ),
          HeroInput(
            focusNode: focusNode,
            width: 256,
            placeholder: 'Enter your name',
            isDisabled: values.toggle('isDisabled'),
            isInvalid: values.toggle('isInvalid'),
          ),
        ],
      ),
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer(
        "HeroLabel.text(\n  '${values.text('text')}',\n  focusNode: focusNode,\n",
      );
      for (final String flag in <String>[
        'isRequired',
        'isDisabled',
        'isInvalid',
      ]) {
        if (values.toggle(flag)) out.writeln('  $flag: true,');
      }
      out.write(')');
      return out.toString();
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => _LabeledField(
        builder: (BuildContext context, FocusNode focusNode) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: <Widget>[
            HeroLabel.text('Name', focusNode: focusNode),
            HeroInput(
              focusNode: focusNode,
              width: 256,
              placeholder: 'Enter your name',
            ),
          ],
        ),
      ),
      code: '''
// A FocusNode owned by your State (dispose it in dispose()).
final FocusNode nameFocus = FocusNode();

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 4,
  children: <Widget>[
    HeroLabel.text('Name', focusNode: nameFocus),
    HeroInput(
      focusNode: nameFocus,
      width: 256,
      placeholder: 'Enter your name',
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'With Required Indicator',
      builder: (BuildContext context) => _LabeledField(
        builder: (BuildContext context, FocusNode focusNode) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: <Widget>[
            HeroLabel.text(
              'Email Address',
              focusNode: focusNode,
              isRequired: true,
            ),
            HeroInput(focusNode: focusNode, type: HeroInputType.email),
          ],
        ),
      ),
      code: '''
HeroLabel.text('Email Address', focusNode: emailFocus, isRequired: true),
HeroInput(focusNode: emailFocus, type: HeroInputType.email),''',
    ),
    DemoExample(
      title: 'With Disabled State',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: <Widget>[
          HeroLabel.text('Username', isDisabled: true),
          HeroInput(isDisabled: true),
        ],
      ),
      code: '''
HeroLabel.text('Username', focusNode: usernameFocus, isDisabled: true),
HeroInput(focusNode: usernameFocus, isDisabled: true),''',
    ),
    DemoExample(
      title: 'With Invalid State',
      builder: (BuildContext context) => _LabeledField(
        builder: (BuildContext context, FocusNode focusNode) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: <Widget>[
            HeroLabel.text('Password', focusNode: focusNode, isInvalid: true),
            HeroInput(focusNode: focusNode, isInvalid: true),
          ],
        ),
      ),
      code: '''
HeroLabel.text('Password', focusNode: passwordFocus, isInvalid: true),
HeroInput(focusNode: passwordFocus, isInvalid: true),''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A restyled label (xs, semibold, wide tracking, accent, uppercase).',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return _LabeledField(
          builder: (BuildContext context, FocusNode focusNode) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: <Widget>[
              HeroLabel.text(
                'Repository'.toUpperCase(),
                focusNode: focusNode,
                style: theme.typography
                    .style(
                      HeroFontSize.xs,
                      weight: HeroTypography.semibold,
                      tracking: 0.025,
                    )
                    .copyWith(color: theme.colors.accent),
              ),
              HeroInput(
                focusNode: focusNode,
                width: 256,
                placeholder: 'heroui/react',
                style: HeroFieldStyle(
                  backgroundColor: theme.colors.fieldBackground,
                ),
              ),
            ],
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 6,
  children: <Widget>[
    HeroLabel.text(
      'REPOSITORY',
      focusNode: repoFocus,
      style: theme.typography
          .style(
            HeroFontSize.xs,
            weight: HeroTypography.semibold,
            tracking: 0.025,
          )
          .copyWith(color: theme.colors.accent),
    ),
    HeroInput(
      focusNode: repoFocus,
      width: 256,
      placeholder: 'heroui/react',
      style: HeroFieldStyle(backgroundColor: theme.colors.fieldBackground),
    ),
  ],
)''',
    ),
  ],
);

/// Owns the focus node that links a label to its input.
class _LabeledField extends StatefulWidget {
  const _LabeledField({required this.builder});

  final Widget Function(BuildContext context, FocusNode focusNode) builder;

  @override
  State<_LabeledField> createState() => _LabeledFieldState();
}

class _LabeledFieldState extends State<_LabeledField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _focusNode);
}
