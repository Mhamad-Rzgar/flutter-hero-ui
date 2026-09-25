import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const String _assets = 'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com';

const List<(String, String, HeroIconData)> _categories =
    <(String, String, HeroIconData)>[
      ('news', 'News', HeroIcons.squareArticle),
      ('travel', 'Travel', HeroIcons.planetEarth),
      ('gaming', 'Gaming', HeroIcons.rocket),
      ('shopping', 'Shopping', HeroIcons.shoppingBag),
    ];

List<Widget> _categoryTags({int count = 4, bool icons = false}) => <Widget>[
  for (final (String id, String name, HeroIconData icon) in _categories.take(
    count,
  ))
    HeroTag(id: id, startContent: icons ? HeroIcon(icon) : null, label: name),
];

/// A 16 px avatar (`className="size-4"`).
Widget _smallAvatar(String color, String fallback) => SizedBox.square(
  dimension: 16,
  child: HeroAvatar(
    size: HeroSize.sm,
    src: '$_assets/avatars/$color.jpg',
    fallback: Text(fallback),
  ),
);

const String _basicCode = '''
HeroTagGroup(
  semanticLabel: 'Tags',
  selectionMode: HeroSelectionMode.single,
  children: const <Widget>[
    HeroTagGroupList(
      children: <Widget>[
        HeroTag(
          id: 'news',
          startContent: HeroIcon(HeroIcons.squareArticle),
          label: 'News',
        ),
        HeroTag(
          id: 'travel',
          startContent: HeroIcon(HeroIcons.planetEarth),
          label: 'Travel',
        ),
        HeroTag(
          id: 'gaming',
          startContent: HeroIcon(HeroIcons.rocket),
          label: 'Gaming',
        ),
        HeroTag(
          id: 'shopping',
          startContent: HeroIcon(HeroIcons.shoppingBag),
          label: 'Shopping',
        ),
      ],
    ),
  ],
)''';

final ComponentDemo tagGroupDemo = ComponentDemo(
  slug: 'tag-group',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      OptionsControl('variant', <String>['standard', 'surface']),
      OptionsControl('selectionMode', <String>[
        'none',
        'single',
        'multiple',
      ], initial: 'single'),
      ToggleControl('isDisabled'),
      ToggleControl('removable'),
    ],
    builder: (BuildContext context, PlaygroundValues values) =>
        _PlaygroundTags(values: values),
    code: (PlaygroundValues values) =>
        '''
HeroTagGroup(
  label: 'Categories',
  size: HeroSize.${values.option('size')},
  variant: HeroTagVariant.${values.option('variant')},
  selectionMode: HeroSelectionMode.${values.option('selectionMode')},
  isDisabled: ${values.toggle('isDisabled')},${values.toggle('removable') ? '\n  onRemove: (Set<Object> keys) => setState(() => tags.removeAll(keys)),' : ''}
  children: <Widget>[
    HeroTagGroupList(
      children: <Widget>[
        for (final String tag in tags) HeroTag(id: tag, label: tag),
      ],
    ),
  ],
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => HeroTagGroup(
        semanticLabel: 'Tags',
        selectionMode: HeroSelectionMode.single,
        children: <Widget>[
          HeroTagGroupList(children: _categoryTags(icons: true)),
        ],
      ),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: <Widget>[
          for (final (HeroSize size, String label) in <(HeroSize, String)>[
            (HeroSize.sm, 'Small'),
            (HeroSize.md, 'Medium'),
            (HeroSize.lg, 'Large'),
          ])
            HeroTagGroup(
              label: label,
              size: size,
              selectionMode: HeroSelectionMode.single,
              children: <Widget>[
                HeroTagGroupList(children: _categoryTags(count: 3)),
              ],
            ),
        ],
      ),
      code: '''
HeroTagGroup(
  label: 'Small',
  size: HeroSize.sm, // HeroSize.md, HeroSize.lg
  selectionMode: HeroSelectionMode.single,
  children: const <Widget>[
    HeroTagGroupList(
      children: <Widget>[
        HeroTag(id: 'news', label: 'News'),
        HeroTag(id: 'travel', label: 'Travel'),
        HeroTag(id: 'gaming', label: 'Gaming'),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Variants',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 32,
        children: <Widget>[
          for (final (HeroTagVariant variant, String label)
              in <(HeroTagVariant, String)>[
                (HeroTagVariant.standard, 'Default'),
                (HeroTagVariant.surface, 'Surface'),
              ])
            HeroTagGroup(
              label: label,
              variant: variant,
              selectionMode: HeroSelectionMode.single,
              children: <Widget>[
                HeroTagGroupList(children: _categoryTags(count: 3)),
              ],
            ),
        ],
      ),
      code: '''
HeroTagGroup(
  label: 'Surface',
  variant: HeroTagVariant.surface,
  selectionMode: HeroSelectionMode.single,
  children: const <Widget>[
    HeroTagGroupList(
      children: <Widget>[
        HeroTag(id: 'news', label: 'News'),
        HeroTag(id: 'travel', label: 'Travel'),
        HeroTag(id: 'gaming', label: 'Gaming'),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroTagGroup(
            label: 'Disabled Tags',
            description: 'Some tags are disabled',
            selectionMode: HeroSelectionMode.single,
            children: <Widget>[
              HeroTagGroupList(
                children: <Widget>[
                  HeroTag(id: 'news', label: 'News', isDisabled: true),
                  HeroTag(id: 'travel', label: 'Travel'),
                  HeroTag(id: 'gaming', label: 'Gaming', isDisabled: true),
                ],
              ),
            ],
          ),
          HeroTagGroup(
            label: 'Disabled Keys',
            description: 'Tags disabled via disabledKeys prop',
            disabledKeys: <Object>{'travel'},
            selectionMode: HeroSelectionMode.single,
            children: <Widget>[
              HeroTagGroupList(
                children: <Widget>[
                  HeroTag(id: 'news', label: 'News'),
                  HeroTag(id: 'travel', label: 'Travel'),
                  HeroTag(id: 'gaming', label: 'Gaming'),
                ],
              ),
            ],
          ),
        ],
      ),
      code: '''
HeroTagGroup(
  label: 'Disabled Keys',
  description: 'Tags disabled via disabledKeys prop',
  disabledKeys: const <Object>{'travel'},
  selectionMode: HeroSelectionMode.single,
  children: const <Widget>[
    HeroTagGroupList(
      children: <Widget>[
        HeroTag(id: 'news', label: 'News', isDisabled: true),
        HeroTag(id: 'travel', label: 'Travel'),
        HeroTag(id: 'gaming', label: 'Gaming'),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Selection Modes',
      builder: (BuildContext context) => const _SelectionModes(),
      code: '''
Set<Object> single = <Object>{'news'};
Set<Object> multiple = <Object>{'news', 'travel'};

HeroTagGroup(
  label: 'Single Selection',
  description: 'Choose one category',
  selectionMode: HeroSelectionMode.single,
  selectedKeys: single,
  onSelectionChanged: (Set<Object> keys) => setState(() => single = keys),
  children: <Widget>[HeroTagGroupList(children: categoryTags)],
)

HeroTagGroup(
  label: 'Multiple Selection',
  description: 'Choose multiple categories',
  selectionMode: HeroSelectionMode.multiple,
  selectedKeys: multiple,
  onSelectionChanged: (Set<Object> keys) => setState(() => multiple = keys),
  children: <Widget>[HeroTagGroupList(children: categoryTags)],
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _ControlledTags(),
      code: '''
Set<Object> selected = <Object>{'news', 'travel'};

HeroTagGroup(
  label: 'Categories (controlled)',
  description:
      'Selected: \${selected.isEmpty ? 'None' : selected.join(', ')}',
  selectionMode: HeroSelectionMode.multiple,
  selectedKeys: selected,
  onSelectionChanged: (Set<Object> keys) => setState(() => selected = keys),
  children: <Widget>[HeroTagGroupList(children: categoryTags)],
)''',
    ),
    DemoExample(
      title: 'With List Data',
      builder: (BuildContext context) => const _TeamMembers(),
      code: '''
HeroTagGroup(
  label: 'Team Members',
  description: 'Select team members for your project',
  selectionMode: HeroSelectionMode.multiple,
  selectedKeys: selected,
  onSelectionChanged: (Set<Object> keys) => setState(() => selected = keys),
  onRemove: (Set<Object> keys) => setState(() {
    users.removeWhere((User user) => keys.contains(user.id));
    selected = selected.difference(keys);
  }),
  children: <Widget>[
    HeroTagGroupList(
      emptyStateBuilder: (BuildContext context) => HeroEmptyState(
        padding: const EdgeInsets.all(4),
        child: const Text('No team members'),
      ),
      children: <Widget>[
        HeroCollection<User>(
          items: users,
          itemBuilder: (BuildContext context, User user) => HeroTag(
            id: user.id,
            textValue: user.name,
            startContent: SizedBox.square(
              dimension: 16,
              child: HeroAvatar(
                size: HeroSize.sm,
                src: user.avatar,
                fallback: Text(user.fallback),
              ),
            ),
            label: user.name,
          ),
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'With Prefix',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 32,
        children: <Widget>[
          HeroTagGroup(
            label: 'With Icons',
            description: 'Tags with icons',
            selectionMode: HeroSelectionMode.single,
            children: <Widget>[
              HeroTagGroupList(children: _categoryTags(icons: true)),
            ],
          ),
          HeroTagGroup(
            label: 'With Avatars',
            description: 'Tags with avatars',
            selectionMode: HeroSelectionMode.single,
            children: <Widget>[
              HeroTagGroupList(
                children: <Widget>[
                  for (final (String id, String name, String color)
                      in <(String, String, String)>[
                        ('fred', 'Fred', 'blue'),
                        ('michael', 'Michael', 'green'),
                        ('jane', 'Jane', 'purple'),
                      ])
                    HeroTag(
                      id: id,
                      startContent: _smallAvatar(color, name[0]),
                      label: name,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
      code: '''
HeroTagGroup(
  label: 'With Avatars',
  description: 'Tags with avatars',
  selectionMode: HeroSelectionMode.single,
  children: <Widget>[
    HeroTagGroupList(
      children: <Widget>[
        HeroTag(
          id: 'fred',
          startContent: SizedBox.square(
            dimension: 16,
            child: HeroAvatar(
              size: HeroSize.sm,
              src: '\$assets/avatars/blue.jpg',
              fallback: const Text('F'),
            ),
          ),
          label: 'Fred',
        ),
        // Michael and Jane alike.
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'With Remove Button',
      builder: (BuildContext context) => const _RemovableTags(),
      code: '''
HeroTagGroup(
  label: 'Default Remove Button',
  description: 'Click the X to remove tags',
  selectionMode: HeroSelectionMode.single,
  onRemove: (Set<Object> keys) =>
      setState(() => tags.removeWhere((Tag tag) => keys.contains(tag.id))),
  children: <Widget>[
    HeroTagGroupList(
      emptyStateBuilder: (BuildContext context) => HeroEmptyState(
        padding: const EdgeInsets.all(4),
        child: const Text('No categories found'),
      ),
      children: <Widget>[
        for (final Tag tag in tags) HeroTag(id: tag.id, label: tag.name),
      ],
    ),
  ],
)

// A custom remove icon, through the render function:
HeroTag(
  id: tag.id,
  textValue: tag.name,
  builder: (BuildContext context, HeroTagState state) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: <Widget>[
      Text(tag.name),
      if (state.allowsRemoving)
        const HeroTagRemoveButton(child: HeroIcon(HeroIcons.circleXmarkFill)),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Render Function',
      builder: (BuildContext context) => HeroTagGroup(
        semanticLabel: 'Tags',
        selectionMode: HeroSelectionMode.single,
        children: <Widget>[
          HeroTagGroupList(
            children: <Widget>[
              for (final (String id, String name, HeroIconData icon)
                  in _categories)
                HeroTag(
                  id: id,
                  textValue: name,
                  builder: (BuildContext context, HeroTagState state) => Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: <Widget>[
                      HeroIcon(state.isSelected ? HeroIcons.check : icon),
                      Text(name),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      code: '''
HeroTag(
  id: 'news',
  textValue: 'News',
  builder: (BuildContext context, HeroTagState state) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: <Widget>[
      HeroIcon(state.isSelected ? HeroIcons.check : HeroIcons.squareArticle),
      const Text('News'),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) => const _CustomTags(),
      code: '''
final HeroTagStyle style = HeroTagStyle(
  borderRadius: BorderRadius.circular(theme.radii.full),
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  gap: 6,
  textStyle: theme.typography.sm,
  iconSize: 16,
  shadows: theme.shadows.surface.boxShadows,
  backgroundColor: WidgetStateProperty.resolveWith(
    (Set<WidgetState> states) => states.contains(WidgetState.selected)
        ? colors.foreground
        : colors.surface.withValues(alpha: 0.8),
  ),
  foregroundColor: WidgetStateProperty.resolveWith(
    (Set<WidgetState> states) => states.contains(WidgetState.selected)
        ? colors.background
        : colors.foreground,
  ),
  iconColor: WidgetStateProperty.resolveWith(
    (Set<WidgetState> states) =>
        states.contains(WidgetState.selected) ? null : colors.muted,
  ),
  side: WidgetStateProperty.resolveWith(
    (Set<WidgetState> states) => BorderSide(
      color: states.contains(WidgetState.selected)
          ? colors.muted
          : colors.border,
    ),
  ),
);

HeroTagGroup(
  semanticLabel: 'Topics',
  selectionMode: HeroSelectionMode.single,
  children: <Widget>[
    HeroTagGroupList(
      spacing: 8,
      children: <Widget>[
        HeroTag(
          id: 'news',
          style: style,
          startContent: const HeroIcon(HeroIcons.squareArticle),
          label: 'News',
        ),
        // ...
      ],
    ),
  ],
)''',
    ),
  ],
);

class _PlaygroundTags extends StatefulWidget {
  const _PlaygroundTags({required this.values});

  final PlaygroundValues values;

  @override
  State<_PlaygroundTags> createState() => _PlaygroundTagsState();
}

class _PlaygroundTagsState extends State<_PlaygroundTags> {
  List<(String, String, HeroIconData)> _tags = _categories;

  @override
  Widget build(BuildContext context) {
    final PlaygroundValues values = widget.values;
    return HeroTagGroup(
      key: ValueKey<String>(values.option('selectionMode')),
      label: 'Categories',
      size: values.pick('size', HeroSize.values),
      variant: values.pick('variant', HeroTagVariant.values),
      selectionMode: values.pick('selectionMode', HeroSelectionMode.values),
      isDisabled: values.toggle('isDisabled'),
      onRemove: values.toggle('removable')
          ? (Set<Object> keys) => setState(
              () => _tags = <(String, String, HeroIconData)>[
                for (final (String, String, HeroIconData) tag in _tags)
                  if (!keys.contains(tag.$1)) tag,
              ],
            )
          : null,
      children: <Widget>[
        HeroTagGroupList(
          emptyStateBuilder: (BuildContext context) => HeroEmptyState(
            padding: const EdgeInsets.all(4),
            child: GestureDetector(
              onTap: () => setState(() => _tags = _categories),
              child: const Text('No categories left. Tap to restore.'),
            ),
          ),
          children: <Widget>[
            for (final (String id, String name, HeroIconData _) in _tags)
              HeroTag(id: id, label: name),
          ],
        ),
      ],
    );
  }
}

class _SelectionModes extends StatefulWidget {
  const _SelectionModes();

  @override
  State<_SelectionModes> createState() => _SelectionModesState();
}

class _SelectionModesState extends State<_SelectionModes> {
  Set<Object> _single = <Object>{'news'};
  Set<Object> _multiple = <Object>{'news', 'travel'};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: <Widget>[
        HeroTagGroup(
          label: 'Single Selection',
          description: 'Choose one category',
          selectionMode: HeroSelectionMode.single,
          selectedKeys: _single,
          onSelectionChanged: (Set<Object> keys) =>
              setState(() => _single = keys),
          children: <Widget>[HeroTagGroupList(children: _categoryTags())],
        ),
        HeroTagGroup(
          label: 'Multiple Selection',
          description: 'Choose multiple categories',
          selectionMode: HeroSelectionMode.multiple,
          selectedKeys: _multiple,
          onSelectionChanged: (Set<Object> keys) =>
              setState(() => _multiple = keys),
          children: <Widget>[HeroTagGroupList(children: _categoryTags())],
        ),
      ],
    );
  }
}

class _ControlledTags extends StatefulWidget {
  const _ControlledTags();

  @override
  State<_ControlledTags> createState() => _ControlledTagsState();
}

class _ControlledTagsState extends State<_ControlledTags> {
  Set<Object> _selected = <Object>{'news', 'travel'};

  @override
  Widget build(BuildContext context) {
    return HeroTagGroup(
      label: 'Categories (controlled)',
      description:
          'Selected: ${_selected.isEmpty ? 'None' : _selected.join(', ')}',
      selectionMode: HeroSelectionMode.multiple,
      selectedKeys: _selected,
      onSelectionChanged: (Set<Object> keys) =>
          setState(() => _selected = keys),
      children: <Widget>[HeroTagGroupList(children: _categoryTags())],
    );
  }
}

class _User {
  const _User(this.id, this.name, this.color, this.fallback);

  final String id;
  final String name;
  final String color;
  final String fallback;
}

const List<_User> _team = <_User>[
  _User('fred', 'Fred', 'blue', 'F'),
  _User('michael', 'Michael', 'green', 'M'),
  _User('jane', 'Jane', 'purple', 'J'),
  _User('alice', 'Alice', 'red', 'A'),
  _User('bob', 'Bob', 'orange', 'B'),
  _User('charlie', 'Charlie', 'black', 'C'),
];

class _TeamMembers extends StatefulWidget {
  const _TeamMembers();

  @override
  State<_TeamMembers> createState() => _TeamMembersState();
}

class _TeamMembersState extends State<_TeamMembers> {
  List<_User> _users = _team;
  Set<Object> _selected = <Object>{'fred', 'michael'};

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final List<_User> selected = <_User>[
      for (final Object key in _selected)
        ..._users.where((_User user) => user.id == key),
    ];
    return SizedBox(
      width: 384,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroTagGroup(
            label: 'Team Members',
            description: 'Select team members for your project',
            selectionMode: HeroSelectionMode.multiple,
            selectedKeys: _selected,
            onSelectionChanged: (Set<Object> keys) =>
                setState(() => _selected = keys),
            onRemove: (Set<Object> keys) => setState(() {
              _users = <_User>[
                for (final _User user in _users)
                  if (!keys.contains(user.id)) user,
              ];
              _selected = _selected.difference(keys);
            }),
            children: <Widget>[
              HeroTagGroupList(
                emptyStateBuilder: (BuildContext context) =>
                    const HeroEmptyState(
                      padding: EdgeInsets.all(4),
                      child: Text('No team members'),
                    ),
                children: <Widget>[
                  HeroCollection<_User>(
                    items: _users,
                    itemBuilder: (BuildContext context, _User user) => HeroTag(
                      id: user.id,
                      textValue: user.name,
                      startContent: _smallAvatar(user.color, user.fallback),
                      label: user.name,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (selected.isNotEmpty)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: <Widget>[
                Text(
                  'Selected:',
                  style: theme.typography
                      .style(HeroFontSize.sm, weight: HeroTypography.medium)
                      .copyWith(color: theme.colors.muted),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final _User user in selected)
                      DecoratedBox(
                        decoration: ShapeDecoration(
                          color: theme.colors.surfaceTertiary,
                          shape: theme.shapeAll(theme.radii.lg),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: <Widget>[
                              _smallAvatar(user.color, user.fallback),
                              Text(
                                user.name,
                                style: theme.typography.sm.copyWith(
                                  color: theme.colors.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RemovableTags extends StatefulWidget {
  const _RemovableTags();

  @override
  State<_RemovableTags> createState() => _RemovableTagsState();
}

class _RemovableTagsState extends State<_RemovableTags> {
  List<(String, String)> _tags = const <(String, String)>[
    ('news', 'News'),
    ('travel', 'Travel'),
    ('gaming', 'Gaming'),
    ('shopping', 'Shopping'),
  ];
  List<(String, String)> _frameworks = const <(String, String)>[
    ('react', 'React'),
    ('vue', 'Vue'),
    ('angular', 'Angular'),
    ('svelte', 'Svelte'),
  ];

  static List<(String, String)> _without(
    List<(String, String)> tags,
    Set<Object> keys,
  ) => <(String, String)>[
    for (final (String, String) tag in tags)
      if (!keys.contains(tag.$1)) tag,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: <Widget>[
        SizedBox(
          width: 384,
          child: HeroTagGroup(
            label: 'Default Remove Button',
            description: 'Click the X to remove tags',
            selectionMode: HeroSelectionMode.single,
            onRemove: (Set<Object> keys) =>
                setState(() => _tags = _without(_tags, keys)),
            children: <Widget>[
              HeroTagGroupList(
                emptyStateBuilder: (BuildContext context) =>
                    const HeroEmptyState(
                      padding: EdgeInsets.all(4),
                      child: Text('No categories found'),
                    ),
                children: <Widget>[
                  for (final (String id, String name) in _tags)
                    HeroTag(id: id, textValue: name, label: name),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: 448,
          child: HeroTagGroup(
            label: 'Custom Remove Button',
            description: 'Custom remove button with icon',
            selectionMode: HeroSelectionMode.single,
            onRemove: (Set<Object> keys) =>
                setState(() => _frameworks = _without(_frameworks, keys)),
            children: <Widget>[
              HeroTagGroupList(
                emptyStateBuilder: (BuildContext context) =>
                    const HeroEmptyState(
                      padding: EdgeInsets.all(4),
                      child: Text('No frameworks found'),
                    ),
                children: <Widget>[
                  for (final (String id, String name) in _frameworks)
                    HeroTag(
                      id: id,
                      textValue: name,
                      builder: (BuildContext context, HeroTagState state) =>
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: <Widget>[
                              Text(name),
                              if (state.allowsRemoving)
                                const HeroTagRemoveButton(
                                  child: HeroIcon(HeroIcons.circleXmarkFill),
                                ),
                            ],
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomTags extends StatelessWidget {
  const _CustomTags();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final HeroTagStyle style = HeroTagStyle(
      borderRadius: BorderRadius.circular(theme.radii.full),
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing(2.5),
        vertical: theme.spacing(1),
      ),
      gap: theme.spacing(1.5),
      textStyle: theme.typography.sm,
      iconSize: theme.spacing(4),
      shadows: theme.shadows.surface.boxShadows,
      backgroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? colors.foreground
            : colors.surface.withValues(alpha: colors.surface.a * 0.8),
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => states.contains(WidgetState.selected)
            ? colors.background
            : colors.foreground,
      ),
      iconColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.selected) ? null : colors.muted,
      ),
      side: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => BorderSide(
          color: states.contains(WidgetState.selected)
              ? colors.muted
              : colors.border,
        ),
      ),
    );
    return HeroTagGroup(
      semanticLabel: 'Topics',
      selectionMode: HeroSelectionMode.single,
      children: <Widget>[
        HeroTagGroupList(
          spacing: theme.spacing(2),
          children: <Widget>[
            for (final (String id, String name, HeroIconData icon)
                in _categories)
              HeroTag(
                id: id,
                style: style,
                startContent: HeroIcon(icon),
                label: name,
              ),
          ],
        ),
      ],
    );
  }
}
