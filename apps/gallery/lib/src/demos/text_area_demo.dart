import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroTextArea`, reproducing
/// heroui.com/docs/components/text-area.
final ComponentDemo textAreaDemo = ComponentDemo(
  slug: 'text-area',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary']),
      OptionsControl('rows', <String>['2', '3', '4', '6'], initial: '3'),
      OptionsControl('resize', <String>['none', 'vertical']),
      ToggleControl('fullWidth'),
      ToggleControl('isDisabled'),
      ToggleControl('isReadOnly'),
      ToggleControl('isInvalid'),
      TextControl('placeholder', initial: 'Share a quick project update...'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => SizedBox(
      width: 320,
      child: Center(
        child: HeroTextArea(
          semanticLabel: 'Playground text area',
          placeholder: values.text('placeholder'),
          variant: values.pick('variant', HeroFieldVariant.values),
          rows: int.parse(values.option('rows')),
          resize: values.pick('resize', HeroTextAreaResize.values),
          fullWidth: values.toggle('fullWidth'),
          isDisabled: values.toggle('isDisabled'),
          isReadOnly: values.toggle('isReadOnly'),
          isInvalid: values.toggle('isInvalid'),
        ),
      ),
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroTextArea(\n')
        ..writeln("  placeholder: '${values.text('placeholder')}',")
        ..writeln('  rows: ${values.option('rows')},');
      if (values.option('variant') != 'primary') {
        out.writeln('  variant: HeroFieldVariant.${values.option('variant')},');
      }
      if (values.option('resize') != 'none') {
        out.writeln('  resize: HeroTextAreaResize.${values.option('resize')},');
      }
      for (final String flag in <String>[
        'fullWidth',
        'isDisabled',
        'isReadOnly',
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
      builder: (BuildContext context) => const HeroTextArea(
        semanticLabel: 'Quick project update',
        width: 384,
        height: 128,
        placeholder: 'Share a quick project update...',
      ),
      code: '''
HeroTextArea(
  semanticLabel: 'Quick project update',
  width: 384,
  height: 128,
  placeholder: 'Share a quick project update...',
)''',
    ),
    DemoExample(
      title: 'Variants',
      description:
          'primary (default) has the field shadow; secondary is the lower '
          'emphasis variant for surfaces.',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: <Widget>[
            HeroTextArea(
              fullWidth: true,
              placeholder: 'Primary textarea',
              variant: HeroFieldVariant.primary,
            ),
            HeroTextArea(
              fullWidth: true,
              placeholder: 'Secondary textarea',
              variant: HeroFieldVariant.secondary,
            ),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 280,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: <Widget>[
      HeroTextArea(
        fullWidth: true,
        placeholder: 'Primary textarea',
        variant: HeroFieldVariant.primary,
      ),
      HeroTextArea(
        fullWidth: true,
        placeholder: 'Secondary textarea',
        variant: HeroFieldVariant.secondary,
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Full Width',
      builder: (BuildContext context) => const SizedBox(
        width: 400,
        child: HeroTextArea(
          fullWidth: true,
          placeholder: 'Full width textarea',
        ),
      ),
      code: '''
SizedBox(
  width: 400,
  child: HeroTextArea(fullWidth: true, placeholder: 'Full width textarea'),
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _ControlledTextArea(),
      code: '''
class ControlledTextArea extends StatefulWidget {
  const ControlledTextArea({super.key});

  @override
  State<ControlledTextArea> createState() => _ControlledTextAreaState();
}

class _ControlledTextAreaState extends State<ControlledTextArea> {
  String value = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: <Widget>[
          HeroTextArea(
            semanticLabel: 'Announcement',
            placeholder: 'Compose an announcement...',
            value: value,
            onChanged: (String next) => setState(() => value = next),
          ),
          HeroDescription.text('Characters: \${value.length} / 280'),
        ],
      ),
    );
  }
}''',
    ),
    DemoExample(
      title: 'Rows and Resizing',
      builder: (BuildContext context) => const _RowsExample(),
      code: '''
SizedBox(
  width: 384,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: <Widget>[
          HeroLabel.text('Short feedback', focusNode: shortFocus),
          HeroTextArea(
            focusNode: shortFocus,
            semanticLabel: 'Short feedback',
            placeholder: "This week's highlights...",
            rows: 3,
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: <Widget>[
          HeroLabel.text('Detailed notes', focusNode: notesFocus),
          HeroTextArea(
            focusNode: notesFocus,
            semanticLabel: 'Detailed notes',
            placeholder: 'Write out the full meeting notes...',
            rows: 6,
            resize: HeroTextAreaResize.vertical,
          ),
        ],
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A note field restyled with HeroFieldStyle: rounded-xl, a border, '
          'the surface background, a hairline ring and a soft focus ring.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: HeroTextArea(
            semanticLabel: 'Notes',
            fullWidth: true,
            height: 112,
            placeholder: 'Add a note...',
            style: _noteStyle(theme),
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 320),
  child: HeroTextArea(
    semanticLabel: 'Notes',
    fullWidth: true,
    height: 112,
    placeholder: 'Add a note...',
    style: HeroFieldStyle(
      borderRadius: BorderRadius.circular(theme.radii.xl),
      borderWidth: theme.borderWidth,
      borderColor: theme.colors.border.withValues(alpha: 0.8),
      backgroundColor: theme.colors.surface,
      // shadow-sm plus a ring-1 (black/5, white/10 in dark mode)
      shadow: HeroShadow(
        boxShadows: <BoxShadow>[
          BoxShadow(
            color: theme.isDark
                ? theme.colors.white.withValues(alpha: 0.1)
                : theme.colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
          ),
          ...theme.shadows.surface.boxShadows,
        ],
      ),
      focusRingColor: theme.colors.muted.withValues(alpha: 0.3),
      textStyle: theme.typography.sm.copyWith(color: theme.colors.foreground),
      placeholderStyle: TextStyle(color: theme.colors.muted),
    ),
  ),
)''',
    ),
  ],
);

HeroFieldStyle _noteStyle(HeroThemeData theme) => HeroFieldStyle(
  borderRadius: BorderRadius.circular(theme.radii.xl),
  borderWidth: theme.borderWidth,
  borderColor: theme.colors.border.withValues(alpha: 0.8),
  backgroundColor: theme.colors.surface,
  shadow: HeroShadow(
    boxShadows: <BoxShadow>[
      BoxShadow(
        color: theme.isDark
            ? theme.colors.white.withValues(alpha: 0.1)
            : theme.colors.black.withValues(alpha: 0.05),
        spreadRadius: 1,
      ),
      ...theme.shadows.surface.boxShadows,
    ],
  ),
  focusRingColor: theme.colors.muted.withValues(alpha: 0.3),
  textStyle: theme.typography.sm.copyWith(color: theme.colors.foreground),
  placeholderStyle: TextStyle(color: theme.colors.muted),
);

class _ControlledTextArea extends StatefulWidget {
  const _ControlledTextArea();

  @override
  State<_ControlledTextArea> createState() => _ControlledTextAreaState();
}

class _ControlledTextAreaState extends State<_ControlledTextArea> {
  String _value = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: <Widget>[
          HeroTextArea(
            semanticLabel: 'Announcement',
            placeholder: 'Compose an announcement...',
            value: _value,
            onChanged: (String next) => setState(() => _value = next),
          ),
          HeroDescription.text('Characters: ${_value.length} / 280'),
        ],
      ),
    );
  }
}

class _RowsExample extends StatefulWidget {
  const _RowsExample();

  @override
  State<_RowsExample> createState() => _RowsExampleState();
}

class _RowsExampleState extends State<_RowsExample> {
  final FocusNode _short = FocusNode();
  final FocusNode _notes = FocusNode();

  @override
  void dispose() {
    _short.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 384,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: <Widget>[
              HeroLabel.text('Short feedback', focusNode: _short),
              HeroTextArea(
                focusNode: _short,
                semanticLabel: 'Short feedback',
                placeholder: "This week's highlights...",
                rows: 3,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: <Widget>[
              HeroLabel.text('Detailed notes', focusNode: _notes),
              HeroTextArea(
                focusNode: _notes,
                semanticLabel: 'Detailed notes',
                placeholder: 'Write out the full meeting notes...',
                rows: 6,
                resize: HeroTextAreaResize.vertical,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
