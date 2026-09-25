import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroSearchField`, reproducing
/// heroui.com/docs/components/search-field.
final ComponentDemo searchFieldDemo = ComponentDemo(
  slug: 'search-field',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary']),
      ToggleControl('fullWidth'),
      ToggleControl('isRequired'),
      ToggleControl('isDisabled'),
      ToggleControl('isReadOnly'),
      ToggleControl('isInvalid'),
      TextControl('label', initial: 'Search'),
      TextControl('placeholder', initial: 'Search...'),
      TextControl('description', initial: 'Enter keywords to search'),
      TextControl('errorMessage', initial: 'Please enter a valid query'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => SizedBox(
      width: values.toggle('fullWidth') ? 400 : null,
      child: HeroSearchField(
        label: values.text('label'),
        placeholder: values.text('placeholder'),
        description: values.text('description'),
        errorMessage: values.text('errorMessage'),
        inputWidth: 280,
        variant: values.pick('variant', HeroFieldVariant.values),
        fullWidth: values.toggle('fullWidth'),
        isRequired: values.toggle('isRequired'),
        isDisabled: values.toggle('isDisabled'),
        isReadOnly: values.toggle('isReadOnly'),
        isInvalid: values.toggle('isInvalid') ? true : null,
      ),
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroSearchField(\n')
        ..writeln("  label: '${values.text('label')}',")
        ..writeln("  placeholder: '${values.text('placeholder')}',")
        ..writeln("  description: '${values.text('description')}',")
        ..writeln("  errorMessage: '${values.text('errorMessage')}',")
        ..writeln('  inputWidth: 280,');
      if (values.option('variant') != 'primary') {
        out.writeln('  variant: HeroFieldVariant.${values.option('variant')},');
      }
      for (final String flag in <String>[
        'fullWidth',
        'isRequired',
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
      builder: (BuildContext context) =>
          const HeroSearchField(name: 'search', children: _basicParts),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Variants',
      description:
          'primary (default) has the field shadow; secondary is the lower '
          'emphasis variant without shadow, suited to surfaces.',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroSearchField(
            name: 'primary-search',
            label: 'Primary variant',
            placeholder: 'Search...',
            inputWidth: 280,
          ),
          HeroSearchField(
            name: 'secondary-search',
            variant: HeroFieldVariant.secondary,
            label: 'Secondary variant',
            placeholder: 'Search...',
            inputWidth: 280,
          ),
        ],
      ),
      code: '''
const HeroSearchField(
  name: 'secondary-search',
  variant: HeroFieldVariant.secondary, // or primary (default)
  children: <Widget>[
    HeroLabel.text('Secondary variant'),
    HeroSearchFieldGroup(
      children: <Widget>[
        HeroSearchFieldSearchIcon(),
        HeroSearchFieldInput(placeholder: 'Search...', width: 280),
        HeroSearchFieldClearButton(),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'In Surface',
      description:
          'Inside a Surface, use the secondary variant for the lower '
          'emphasis look suited to surface backgrounds.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroSurface(
          width: 384,
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          padding: EdgeInsets.all(theme.spacing(6)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: <Widget>[
              HeroSearchField(
                name: 'search',
                variant: HeroFieldVariant.secondary,
                label: 'Search',
                placeholder: 'Search...',
                description: 'Enter keywords to search',
                fullWidth: true,
              ),
              HeroSearchField(
                name: 'search-2',
                variant: HeroFieldVariant.secondary,
                label: 'Advanced search',
                placeholder: 'Advanced search...',
                description: 'Use filters to refine your search',
                fullWidth: true,
              ),
            ],
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroSurface(
  width: 384,
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: <Widget>[
      HeroSearchField(
        name: 'search',
        variant: HeroFieldVariant.secondary,
        label: 'Search',
        placeholder: 'Search...',
        description: 'Enter keywords to search',
        fullWidth: true,
      ),
      HeroSearchField(
        name: 'search-2',
        variant: HeroFieldVariant.secondary,
        label: 'Advanced search',
        placeholder: 'Advanced search...',
        description: 'Use filters to refine your search',
        fullWidth: true,
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'With Description',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroSearchField(
            name: 'search',
            label: 'Search products',
            placeholder: 'Search products...',
            description: 'Enter keywords to search for products',
            inputWidth: 280,
          ),
          HeroSearchField(
            name: 'search-users',
            label: 'Search users',
            placeholder: 'Search users...',
            description: 'Search by name, email, or username',
            inputWidth: 280,
          ),
        ],
      ),
      code: '''
const HeroSearchField(
  name: 'search',
  label: 'Search products',
  placeholder: 'Search products...',
  description: 'Enter keywords to search for products',
  inputWidth: 280,
)''',
    ),
    DemoExample(
      title: 'Required Field',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroSearchField(
            name: 'search',
            isRequired: true,
            label: 'Search',
            placeholder: 'Search...',
            inputWidth: 280,
          ),
          HeroSearchField(
            name: 'search-query',
            isRequired: true,
            label: 'Search query',
            placeholder: 'Enter search query...',
            description: 'Minimum 3 characters required',
            inputWidth: 280,
          ),
        ],
      ),
      code: '''
const HeroSearchField(
  name: 'search-query',
  isRequired: true,
  label: 'Search query',
  placeholder: 'Enter search query...',
  description: 'Minimum 3 characters required',
  inputWidth: 280,
)''',
    ),
    DemoExample(
      title: 'Disabled State',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroSearchField(
            name: 'search',
            isDisabled: true,
            value: 'Disabled search',
            label: 'Search',
            placeholder: 'Search...',
            description: 'This search field is disabled',
            inputWidth: 280,
          ),
          HeroSearchField(
            name: 'search-empty',
            isDisabled: true,
            label: 'Search',
            placeholder: 'Search...',
            description: 'This search field is disabled',
            inputWidth: 280,
          ),
        ],
      ),
      code: '''
const HeroSearchField(
  name: 'search',
  isDisabled: true,
  value: 'Disabled search',
  label: 'Search',
  placeholder: 'Search...',
  description: 'This search field is disabled',
  inputWidth: 280,
)''',
    ),
    DemoExample(
      title: 'Full Width',
      builder: (BuildContext context) => const SizedBox(
        width: 400,
        child: HeroSearchField(
          name: 'search',
          fullWidth: true,
          label: 'Search',
          placeholder: 'Search...',
        ),
      ),
      code: '''
const SizedBox(
  width: 400,
  child: HeroSearchField(
    name: 'search',
    fullWidth: true,
    label: 'Search',
    placeholder: 'Search...',
  ),
)''',
    ),
    DemoExample(
      title: 'Validation',
      description: 'isInvalid with a FieldError surfaces validation messages.',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroSearchField(
            name: 'search',
            isInvalid: true,
            isRequired: true,
            value: 'ab',
            label: 'Search',
            placeholder: 'Search...',
            errorMessage: 'Search query must be at least 3 characters',
            inputWidth: 280,
          ),
          HeroSearchField(
            name: 'search-invalid',
            isInvalid: true,
            value: 'invalid@query',
            label: 'Search',
            placeholder: 'Search...',
            errorMessage: 'Invalid characters in search query',
            inputWidth: 280,
          ),
        ],
      ),
      code: '''
const HeroSearchField(
  name: 'search',
  isInvalid: true,
  isRequired: true,
  value: 'ab',
  children: <Widget>[
    HeroLabel.text('Search'),
    HeroSearchFieldGroup(
      children: <Widget>[
        HeroSearchFieldSearchIcon(),
        HeroSearchFieldInput(placeholder: 'Search...', width: 280),
        HeroSearchFieldClearButton(),
      ],
    ),
    HeroFieldError.text('Search query must be at least 3 characters'),
  ],
)''',
    ),
    DemoExample(
      title: 'Controlled',
      description:
          'Control the value to synchronize it with other widgets or format '
          'it.',
      builder: (BuildContext context) => const _ControlledSearch(),
      code: r'''
String value = '';

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    HeroSearchField(
      name: 'search',
      value: value,
      onChanged: (String v) => setState(() => value = v),
      label: 'Search',
      placeholder: 'Search...',
      description: 'Current value: ${value.isEmpty ? '(empty)' : value}',
      inputWidth: 280,
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[
        HeroButton(
          variant: HeroButtonVariant.tertiary,
          onPressed: () => setState(() => value = ''),
          child: const Text('Clear'),
        ),
        HeroButton(
          variant: HeroButtonVariant.tertiary,
          onPressed: () => setState(() => value = 'example query'),
          child: const Text('Set example'),
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Form Example',
      description: 'Form integration with validation and submission.',
      builder: (BuildContext context) => const _SearchForm(),
      code: r'''
const int minLength = 3;
String value = '';
bool isSubmitting = false;

HeroForm(
  onSubmit: (Map<String, Object?> data) async {
    setState(() => isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    setState(() {
      value = '';
      isSubmitting = false;
    });
  },
  child: SizedBox(
    width: 280,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        HeroSearchField(
          name: 'search',
          isRequired: true,
          isInvalid: value.isNotEmpty && value.length < minLength,
          value: value,
          onChanged: (String v) => setState(() => value = v),
          fullWidth: true,
          label: 'Search products',
          placeholder: 'Search products...',
          description: 'Enter at least $minLength characters to search',
          errorMessage: 'Search query must be at least $minLength characters',
        ),
        HeroButton(
          type: HeroButtonType.submit,
          fullWidth: true,
          isDisabled: value.length < minLength,
          isPending: isSubmitting,
          child: Text(isSubmitting ? 'Searching...' : 'Search'),
        ),
      ],
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'With Validation',
      description: 'Custom validation logic with a controlled value.',
      builder: (BuildContext context) => const _LiveValidatedSearch(),
      code: r'''
String value = '';

HeroSearchField(
  name: 'search',
  isRequired: true,
  isInvalid: value.isNotEmpty && value.length < 3,
  value: value,
  onChanged: (String v) => setState(() => value = v),
  label: 'Search',
  placeholder: 'Search...',
  description: 'Enter at least 3 characters to search',
  errorMessage: 'Search query must be at least 3 characters',
  inputWidth: 280,
)''',
    ),
    DemoExample(
      title: 'Custom Icons',
      description: 'Replace the search icon and the clear button icon.',
      builder: (BuildContext context) => const HeroSearchField(
        name: 'search-custom',
        children: <Widget>[
          HeroLabel.text('Search (Custom Icons)'),
          HeroSearchFieldGroup(
            children: <Widget>[
              HeroSearchFieldSearchIcon(child: HeroIcon(HeroIcons.funnel)),
              HeroSearchFieldInput(placeholder: 'Search...', width: 280),
              HeroSearchFieldClearButton(
                child: HeroIcon(HeroIcons.circleXmarkFill, size: 16),
              ),
            ],
          ),
          HeroDescription.text('Custom icon children'),
        ],
      ),
      code: '''
const HeroSearchField(
  name: 'search-custom',
  children: <Widget>[
    HeroLabel.text('Search (Custom Icons)'),
    HeroSearchFieldGroup(
      children: <Widget>[
        HeroSearchFieldSearchIcon(child: HeroIcon(HeroIcons.funnel)),
        HeroSearchFieldInput(placeholder: 'Search...', width: 280),
        HeroSearchFieldClearButton(
          child: HeroIcon(HeroIcons.circleXmarkFill, size: 16),
        ),
      ],
    ),
    HeroDescription.text('Custom icon children'),
  ],
)''',
    ),
    DemoExample(
      title: 'With Keyboard Shortcut',
      description:
          'Shift+S focuses the search field from anywhere on the page; '
          'Escape clears it, then leaves it.',
      builder: (BuildContext context) => const _ShortcutSearch(),
      code: r'''
final FocusNode focusNode = FocusNode();

// In initState: a page-wide Shift+S handler.
WidgetsBinding.instance.keyboard.addHandler(handleKey);

bool handleKey(KeyEvent event) {
  if (event.character == 'S' && !focusNode.hasFocus) {
    focusNode.requestFocus();
    return true;
  }
  return false;
}

// Escape reaches this handler once the field is empty.
Focus(
  canRequestFocus: false,
  onKeyEvent: (FocusNode node, KeyEvent event) {
    if (event.logicalKey.keyLabel == 'Escape' && focusNode.hasFocus) {
      focusNode.unfocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  },
  child: HeroSearchField(
    name: 'search',
    focusNode: focusNode,
    label: 'Search',
    placeholder: 'Search...',
    description: 'Use keyboard shortcut to quickly focus this field',
    inputWidth: 280,
  ),
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'React renders the field through a custom element. In Flutter the '
          'output is identical to the basic example.',
      builder: (BuildContext context) =>
          const HeroSearchField(name: 'search', children: _basicParts),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A secondary field restyled: rounded-xl default group background '
          'and muted icon, clear button and placeholder.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return SizedBox(
          width: 256,
          child: HeroSearchField(
            name: 'docs',
            variant: HeroFieldVariant.secondary,
            fullWidth: true,
            children: <Widget>[
              HeroLabel.text(
                'Search docs',
                style: TextStyle(color: theme.colors.foreground),
              ),
              HeroSearchFieldGroup(
                style: HeroFieldStyle(
                  borderRadius: BorderRadius.circular(theme.radii.xl),
                  backgroundColor: theme.colors.defaultColor,
                ),
                children: <Widget>[
                  HeroSearchFieldSearchIcon(color: theme.colors.muted),
                  HeroSearchFieldInput(
                    placeholder: 'Components, guides...',
                    style: HeroFieldStyle(
                      placeholderStyle: TextStyle(color: theme.colors.muted),
                    ),
                  ),
                  HeroSearchFieldClearButton(
                    style: HeroButtonStyle(
                      foregroundColor: WidgetStatePropertyAll<Color?>(
                        theme.colors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
SizedBox(
  width: 256,
  child: HeroSearchField(
    name: 'docs',
    variant: HeroFieldVariant.secondary,
    fullWidth: true,
    children: <Widget>[
      HeroLabel.text(
        'Search docs',
        style: TextStyle(color: theme.colors.foreground),
      ),
      HeroSearchFieldGroup(
        style: HeroFieldStyle(
          borderRadius: BorderRadius.circular(theme.radii.xl),
          backgroundColor: theme.colors.defaultColor,
        ),
        children: <Widget>[
          HeroSearchFieldSearchIcon(color: theme.colors.muted),
          HeroSearchFieldInput(
            placeholder: 'Components, guides...',
            style: HeroFieldStyle(
              placeholderStyle: TextStyle(color: theme.colors.muted),
            ),
          ),
          HeroSearchFieldClearButton(
            style: HeroButtonStyle(
              foregroundColor: WidgetStatePropertyAll<Color?>(
                theme.colors.muted,
              ),
            ),
          ),
        ],
      ),
    ],
  ),
)''',
    ),
  ],
);

const List<Widget> _basicParts = <Widget>[
  HeroLabel.text('Search'),
  HeroSearchFieldGroup(
    children: <Widget>[
      HeroSearchFieldSearchIcon(),
      HeroSearchFieldInput(placeholder: 'Search...', width: 280),
      HeroSearchFieldClearButton(),
    ],
  ),
];

const String _basicCode = '''
const HeroSearchField(
  name: 'search',
  children: <Widget>[
    HeroLabel.text('Search'),
    HeroSearchFieldGroup(
      children: <Widget>[
        HeroSearchFieldSearchIcon(),
        HeroSearchFieldInput(placeholder: 'Search...', width: 280),
        HeroSearchFieldClearButton(),
      ],
    ),
  ],
)

// or, with the convenience parameters:
const HeroSearchField(
  name: 'search',
  label: 'Search',
  placeholder: 'Search...',
  inputWidth: 280,
)''';

/// A controlled search field with buttons that set the value.
class _ControlledSearch extends StatefulWidget {
  const _ControlledSearch();

  @override
  State<_ControlledSearch> createState() => _ControlledSearchState();
}

class _ControlledSearchState extends State<_ControlledSearch> {
  String _value = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        HeroSearchField(
          name: 'search',
          value: _value,
          onChanged: (String value) => setState(() => _value = value),
          label: 'Search',
          placeholder: 'Search...',
          description: 'Current value: ${_value.isEmpty ? '(empty)' : _value}',
          inputWidth: 280,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            HeroButton(
              variant: HeroButtonVariant.tertiary,
              onPressed: () => setState(() => _value = ''),
              child: const Text('Clear'),
            ),
            HeroButton(
              variant: HeroButtonVariant.tertiary,
              onPressed: () => setState(() => _value = 'example query'),
              child: const Text('Set example'),
            ),
          ],
        ),
      ],
    );
  }
}

/// The docs' search form: a required query of at least three characters
/// and a pending submit button.
class _SearchForm extends StatefulWidget {
  const _SearchForm();

  @override
  State<_SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<_SearchForm> {
  static const int _minLength = 3;
  String _value = '';
  bool _submitting = false;

  Future<void> _submit(Map<String, Object?> data) async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _value = '';
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool invalid = _value.isNotEmpty && _value.length < _minLength;
    return HeroForm(
      onSubmit: _submit,
      child: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            HeroSearchField(
              name: 'search',
              isRequired: true,
              isInvalid: invalid,
              value: _value,
              onChanged: (String value) => setState(() => _value = value),
              fullWidth: true,
              label: 'Search products',
              placeholder: 'Search products...',
              description: 'Enter at least $_minLength characters to search',
              errorMessage:
                  'Search query must be at least $_minLength characters',
            ),
            HeroButton(
              type: HeroButtonType.submit,
              fullWidth: true,
              isDisabled: _value.length < _minLength,
              isPending: _submitting,
              child: Text(_submitting ? 'Searching...' : 'Search'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A search field validated while typing.
class _LiveValidatedSearch extends StatefulWidget {
  const _LiveValidatedSearch();

  @override
  State<_LiveValidatedSearch> createState() => _LiveValidatedSearchState();
}

class _LiveValidatedSearchState extends State<_LiveValidatedSearch> {
  String _value = '';

  @override
  Widget build(BuildContext context) {
    return HeroSearchField(
      name: 'search',
      isRequired: true,
      isInvalid: _value.isNotEmpty && _value.length < 3,
      value: _value,
      onChanged: (String value) => setState(() => _value = value),
      label: 'Search',
      placeholder: 'Search...',
      description: 'Enter at least 3 characters to search',
      errorMessage: 'Search query must be at least 3 characters',
      inputWidth: 280,
    );
  }
}

/// A search field focused with Shift+S and left with Escape.
class _ShortcutSearch extends StatefulWidget {
  const _ShortcutSearch();

  @override
  State<_ShortcutSearch> createState() => _ShortcutSearchState();
}

class _ShortcutSearchState extends State<_ShortcutSearch> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'Shortcut search');
  String _value = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.keyboard.addHandler(_handleKey);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.keyboard.removeHandler(_handleKey);
    _focusNode.dispose();
    super.dispose();
  }

  bool _typingElsewhere() {
    final BuildContext? focused = FocusManager.instance.primaryFocus?.context;
    return focused?.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _handleKey(KeyEvent event) {
    if (event.character != 'S' ||
        _focusNode.hasFocus ||
        _typingElsewhere() ||
        WidgetsBinding.instance.keyboard.isMetaPressed ||
        WidgetsBinding.instance.keyboard.isControlPressed ||
        WidgetsBinding.instance.keyboard.isAltPressed) {
      return false;
    }
    _focusNode.requestFocus();
    return true;
  }

  KeyEventResult _handleEscape(FocusNode node, KeyEvent event) {
    if (event.logicalKey.keyLabel != 'Escape' || !_focusNode.hasFocus) {
      return KeyEventResult.ignored;
    }
    _focusNode.unfocus();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _handleEscape,
          child: HeroSearchField(
            name: 'search',
            focusNode: _focusNode,
            value: _value,
            onChanged: (String value) => setState(() => _value = value),
            label: 'Search',
            placeholder: 'Search...',
            description: 'Use keyboard shortcut to quickly focus this field',
            inputWidth: 280,
          ),
        ),
        DefaultTextStyle.merge(
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
          child: const Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text('Press'),
              HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.shift], text: 'S'),
              Text('to focus the search field'),
            ],
          ),
        ),
      ],
    );
  }
}
