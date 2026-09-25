import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

final ComponentDemo errorMessageDemo = ComponentDemo(
  slug: 'error-message',
  playground: Playground(
    controls: const <PlaygroundControl>[
      TextControl('text', initial: 'Please select at least one category'),
      ToggleControl('medium'),
    ],
    builder: (BuildContext context, PlaygroundValues values) =>
        HeroErrorMessage.text(
          values.text('text'),
          style: values.toggle('medium')
              ? const TextStyle(fontWeight: HeroTypography.medium)
              : null,
        ),
    code: (PlaygroundValues values) =>
        '''
HeroErrorMessage.text(
  '${values.text('text')}',${values.toggle('medium') ? '\n  style: const TextStyle(fontWeight: HeroTypography.medium),' : ''}
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      description:
          'ErrorMessage displays errors in non-form components such as tag '
          'groups; form fields use FieldError.',
      builder: (BuildContext context) => const _RequiredCategories(),
      code: '''
Set<Object> selected = <Object>{};

HeroTagGroup(
  label: 'Required Categories',
  selectionMode: HeroSelectionMode.multiple,
  selectedKeys: selected,
  onSelectionChanged: (Set<Object> keys) => setState(() => selected = keys),
  children: <Widget>[
    const HeroTagGroupList(
      children: <Widget>[
        HeroTag(id: 'news', label: 'News'),
        HeroTag(id: 'travel', label: 'Travel'),
        HeroTag(id: 'gaming', label: 'Gaming'),
        HeroTag(id: 'shopping', label: 'Shopping'),
      ],
    ),
    const HeroDescription.text('Select at least one category'),
    if (selected.isEmpty)
      const HeroErrorMessage.text('Please select at least one category'),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) => const _Topics(),
      code: '''
SizedBox(
  width: 320,
  child: HeroTagGroup(
    label: 'Topics',
    spacing: 6,
    selectionMode: HeroSelectionMode.multiple,
    selectedKeys: selected,
    onSelectionChanged: (Set<Object> keys) => setState(() => selected = keys),
    children: <Widget>[
      const HeroTagGroupList(
        children: <Widget>[
          HeroTag(id: 'api', label: 'API'),
          HeroTag(id: 'design', label: 'Design'),
          HeroTag(id: 'docs', label: 'Docs'),
        ],
      ),
      const HeroDescription.text('Pick at least one topic'),
      if (selected.isEmpty)
        const HeroErrorMessage.text(
          'Choose at least one topic',
          style: TextStyle(fontWeight: HeroTypography.medium),
        ),
    ],
  ),
)''',
    ),
  ],
);

class _RequiredCategories extends StatefulWidget {
  const _RequiredCategories();

  @override
  State<_RequiredCategories> createState() => _RequiredCategoriesState();
}

class _RequiredCategoriesState extends State<_RequiredCategories> {
  Set<Object> _selected = <Object>{};

  @override
  Widget build(BuildContext context) {
    return HeroTagGroup(
      label: 'Required Categories',
      selectionMode: HeroSelectionMode.multiple,
      selectedKeys: _selected,
      onSelectionChanged: (Set<Object> keys) =>
          setState(() => _selected = keys),
      children: <Widget>[
        const HeroTagGroupList(
          children: <Widget>[
            HeroTag(id: 'news', label: 'News'),
            HeroTag(id: 'travel', label: 'Travel'),
            HeroTag(id: 'gaming', label: 'Gaming'),
            HeroTag(id: 'shopping', label: 'Shopping'),
          ],
        ),
        const HeroDescription.text('Select at least one category'),
        if (_selected.isEmpty)
          const HeroErrorMessage.text('Please select at least one category'),
      ],
    );
  }
}

class _Topics extends StatefulWidget {
  const _Topics();

  @override
  State<_Topics> createState() => _TopicsState();
}

class _TopicsState extends State<_Topics> {
  Set<Object> _selected = <Object>{};

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return SizedBox(
      width: 320,
      child: HeroTagGroup(
        label: 'Topics',
        spacing: theme.spacing(1.5),
        selectionMode: HeroSelectionMode.multiple,
        selectedKeys: _selected,
        onSelectionChanged: (Set<Object> keys) =>
            setState(() => _selected = keys),
        children: <Widget>[
          const HeroTagGroupList(
            children: <Widget>[
              HeroTag(id: 'api', label: 'API'),
              HeroTag(id: 'design', label: 'Design'),
              HeroTag(id: 'docs', label: 'Docs'),
            ],
          ),
          const HeroDescription.text('Pick at least one topic'),
          if (_selected.isEmpty)
            const HeroErrorMessage.text(
              'Choose at least one topic',
              style: TextStyle(fontWeight: HeroTypography.medium),
            ),
        ],
      ),
    );
  }
}
