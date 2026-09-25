import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroDescription`, reproducing
/// heroui.com/docs/components/description.
final ComponentDemo descriptionDemo = ComponentDemo(
  slug: 'description',
  playground: Playground(
    controls: const <PlaygroundControl>[
      TextControl(
        'text',
        initial: "We'll never share your email with anyone else.",
      ),
    ],
    builder: (BuildContext context, PlaygroundValues values) =>
        SizedBox(width: 256, child: HeroDescription.text(values.text('text'))),
    code: (PlaygroundValues values) =>
        'HeroDescription.text("${values.text('text')}")',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => _Field(
        builder: (BuildContext context, FocusNode focusNode) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: <Widget>[
            HeroLabel.text('Email', focusNode: focusNode),
            HeroInput(
              focusNode: focusNode,
              width: 256,
              placeholder: 'you@example.com',
              type: HeroInputType.email,
            ),
            const HeroDescription.text(
              "We'll never share your email with anyone else.",
            ),
          ],
        ),
      ),
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 4,
  children: <Widget>[
    HeroLabel.text('Email', focusNode: emailFocus),
    HeroInput(
      focusNode: emailFocus,
      width: 256,
      placeholder: 'you@example.com',
      type: HeroInputType.email,
    ),
    const HeroDescription.text(
      "We'll never share your email with anyone else.",
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'With Form Fields',
      builder: (BuildContext context) => _Field(
        builder: (BuildContext context, FocusNode focusNode) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: <Widget>[
            HeroLabel.text('Password', focusNode: focusNode),
            HeroInput(focusNode: focusNode, type: HeroInputType.password),
            const HeroDescription.text(
              'Must be at least 8 characters with one uppercase letter',
            ),
          ],
        ),
      ),
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 4,
  children: <Widget>[
    HeroLabel.text('Password', focusNode: passwordFocus),
    HeroInput(focusNode: passwordFocus, type: HeroInputType.password),
    const HeroDescription.text(
      'Must be at least 8 characters with one uppercase letter',
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Integration with TextField',
      description:
          'Inside a HeroTextField the label and description are linked to '
          'the input and announced with it.',
      builder: (BuildContext context) => const HeroTextField(
        type: HeroInputType.email,
        children: <Widget>[
          HeroLabel.text('Email'),
          HeroInput(placeholder: 'Enter your email'),
          HeroDescription.text("We'll never share your email"),
        ],
      ),
      code: '''
HeroTextField(
  type: HeroInputType.email,
  children: const <Widget>[
    HeroLabel.text('Email'),
    HeroInput(placeholder: 'Enter your email'),
    HeroDescription.text("We'll never share your email"),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description: 'A description with relaxed leading and wide tracking.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return _Field(
          builder: (BuildContext context, FocusNode focusNode) => SizedBox(
            width: 256,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4,
              children: <Widget>[
                HeroLabel.text('Workspace URL', focusNode: focusNode),
                HeroInput(focusNode: focusNode, placeholder: 'acme'),
                HeroDescription.text(
                  'Lowercase letters and hyphens only. Used in '
                  'app.heroui.com/acme',
                  style: theme.typography.style(
                    HeroFontSize.xs,
                    lineHeight: HeroFontSize.xs.fontSize * 1.625,
                    tracking: 0.025,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
SizedBox(
  width: 256,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 4,
    children: <Widget>[
      HeroLabel.text('Workspace URL', focusNode: workspaceFocus),
      HeroInput(focusNode: workspaceFocus, placeholder: 'acme'),
      HeroDescription.text(
        'Lowercase letters and hyphens only. Used in app.heroui.com/acme',
        // leading-relaxed tracking-wide
        style: theme.typography.style(
          HeroFontSize.xs,
          lineHeight: HeroFontSize.xs.fontSize * 1.625,
          tracking: 0.025,
        ),
      ),
    ],
  ),
)''',
    ),
  ],
);

/// Owns the focus node that links a label to its input.
class _Field extends StatefulWidget {
  const _Field({required this.builder});

  final Widget Function(BuildContext context, FocusNode focusNode) builder;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _focusNode);
}
