import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const String _assets = 'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com';

/// The users of the docs examples: id, name and avatar color.
const List<(String, String, String)> _users = <(String, String, String)>[
  ('1', 'Bob', 'blue'),
  ('2', 'Fred', 'green'),
  ('3', 'Martha', 'purple'),
];

HeroListBoxItem _userItem(
  (String, String, String) user, {
  Widget? indicator = const HeroListBoxItemIndicator(),
  HeroListBoxItemWidgetBuilder? builder,
}) {
  final (String id, String name, String color) = user;
  return HeroListBoxItem(
    id: id,
    textValue: name,
    startContent: HeroAvatar(
      size: HeroSize.sm,
      src: '$_assets/avatars/$color.jpg',
      name: name,
      fallback: Text(name[0]),
    ),
    label: builder == null ? name : null,
    description: builder == null ? '${name.toLowerCase()}@heroui.com' : null,
    builder: builder,
    indicator: indicator,
  );
}

List<Widget> _userItems({
  Widget? indicator = const HeroListBoxItemIndicator(),
}) => <Widget>[
  for (final (String, String, String) user in _users)
    _userItem(user, indicator: indicator),
];

/// The custom check of the docs: Gravity UI's check in
/// `--accent-soft-foreground`, shown only when selected.
Widget _checkIndicator(BuildContext context) => HeroListBoxItemIndicator(
  builder: (BuildContext context, bool isSelected) => isSelected
      ? HeroIcon(
          HeroIcons.check,
          color: HeroTheme.of(context).colors.accentSoftForeground,
        )
      : null,
);

/// The 256 px wide rounded surface the docs put most examples on.
class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroSurface(
      width: 256,
      borderRadius: BorderRadius.circular(theme.radii.xl3),
      shadow: theme.shadows.surface,
      child: child,
    );
  }
}

/// A 16 px icon aligned with the item's label (`flex h-8 items-start pt-px`).
class _ItemIcon extends StatelessWidget {
  const _ItemIcon(this.icon, {this.danger = false});

  final HeroIconData icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return SizedBox(
      height: theme.spacing(8),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: theme.spacing(0.25)),
          child: HeroIcon(
            icon,
            color: danger ? theme.colors.danger : theme.colors.muted,
          ),
        ),
      ),
    );
  }
}

Widget _fileActions(BuildContext context, {Set<Object>? disabledKeys}) {
  final HeroThemeData theme = HeroTheme.of(context);
  return _SurfaceCard(
    child: HeroListBox(
      semanticLabel: 'File actions',
      padding: EdgeInsets.all(theme.spacing(2)),
      disabledKeys: disabledKeys ?? const <Object>{},
      onAction: (Object key) => debugPrint('Selected item: $key'),
      children: const <Widget>[
        HeroListBoxSection(
          header: HeroHeader.text('Actions'),
          children: <Widget>[
            HeroListBoxItem(
              id: 'new-file',
              startContent: _ItemIcon(HeroIcons.squarePlus),
              label: 'New file',
              description: 'Create a new file',
              endContent: HeroKbd(
                variant: HeroKbdVariant.light,
                keys: <HeroKbdKey>[HeroKbdKey.command],
                text: 'N',
              ),
            ),
            HeroListBoxItem(
              id: 'edit-file',
              startContent: _ItemIcon(HeroIcons.pencil),
              label: 'Edit file',
              description: 'Make changes',
              endContent: HeroKbd(
                variant: HeroKbdVariant.light,
                keys: <HeroKbdKey>[HeroKbdKey.command],
                text: 'E',
              ),
            ),
          ],
        ),
        HeroSeparator(),
        HeroListBoxSection(
          header: HeroHeader.text('Danger zone'),
          children: <Widget>[
            HeroListBoxItem(
              id: 'delete-file',
              variant: HeroListBoxVariant.danger,
              startContent: _ItemIcon(HeroIcons.trashBin, danger: true),
              label: 'Delete file',
              description: 'Move to trash',
              endContent: HeroKbd(
                variant: HeroKbdVariant.light,
                keys: <HeroKbdKey>[HeroKbdKey.command, HeroKbdKey.shift],
                text: 'D',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

const String _usersCode = '''
HeroListBox(
  semanticLabel: 'Users',
  selectionMode: HeroSelectionMode.single,
  children: <Widget>[
    HeroListBoxItem(
      id: '1',
      textValue: 'Bob',
      startContent: HeroAvatar(
        size: HeroSize.sm,
        src: '\$assets/avatars/blue.jpg',
        name: 'Bob',
        fallback: const Text('B'),
      ),
      label: 'Bob',
      description: 'bob@heroui.com',
      indicator: const HeroListBoxItemIndicator(),
    ),
    // Fred and Martha alike.
  ],
)''';

const String _fileActionsCode = '''
HeroSurface(
  width: 256,
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  shadow: theme.shadows.surface,
  child: HeroListBox(
    semanticLabel: 'File actions',
    padding: EdgeInsets.all(theme.spacing(2)),
    DISABLED_KEYS
    onAction: (Object key) => debugPrint('Selected item: \$key'),
    children: const <Widget>[
      HeroListBoxSection(
        header: HeroHeader.text('Actions'),
        children: <Widget>[
          HeroListBoxItem(
            id: 'new-file',
            startContent: HeroIcon(HeroIcons.squarePlus),
            label: 'New file',
            description: 'Create a new file',
            endContent: HeroKbd(
              variant: HeroKbdVariant.light,
              keys: <HeroKbdKey>[HeroKbdKey.command],
              text: 'N',
            ),
          ),
          HeroListBoxItem(
            id: 'edit-file',
            startContent: HeroIcon(HeroIcons.pencil),
            label: 'Edit file',
            description: 'Make changes',
            endContent: HeroKbd(
              variant: HeroKbdVariant.light,
              keys: <HeroKbdKey>[HeroKbdKey.command],
              text: 'E',
            ),
          ),
        ],
      ),
      HeroSeparator(),
      HeroListBoxSection(
        header: HeroHeader.text('Danger zone'),
        children: <Widget>[
          HeroListBoxItem(
            id: 'delete-file',
            variant: HeroListBoxVariant.danger,
            startContent: HeroIcon(HeroIcons.trashBin),
            label: 'Delete file',
            description: 'Move to trash',
            endContent: HeroKbd(
              variant: HeroKbdVariant.light,
              keys: <HeroKbdKey>[HeroKbdKey.command, HeroKbdKey.shift],
              text: 'D',
            ),
          ),
        ],
      ),
    ],
  ),
)''';

const String _checkIndicatorCode = '''
HeroListBoxItemIndicator(
  builder: (BuildContext context, bool isSelected) => isSelected
      ? HeroIcon(HeroIcons.check, color: theme.colors.accentSoftForeground)
      : null,
)''';

final ComponentDemo listBoxDemo = ComponentDemo(
  slug: 'list-box',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('selectionMode', <String>[
        'none',
        'single',
        'multiple',
      ], initial: 'single'),
      OptionsControl('variant', <String>['standard', 'danger']),
      ToggleControl('indicator', initial: true),
      ToggleControl('description', initial: true),
      ToggleControl('disabledKeys'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final bool description = values.toggle('description');
      return _SurfaceCard(
        child: HeroListBox(
          key: ValueKey<String>(values.option('selectionMode')),
          semanticLabel: 'Users',
          selectionMode: values.pick('selectionMode', HeroSelectionMode.values),
          variant: values.pick('variant', HeroListBoxVariant.values),
          disabledKeys: values.toggle('disabledKeys')
              ? const <Object>{'2'}
              : const <Object>{},
          children: <Widget>[
            for (final (String id, String name, String _) in _users)
              HeroListBoxItem(
                id: id,
                label: name,
                description: description
                    ? '${name.toLowerCase()}@heroui.com'
                    : null,
                indicator: values.toggle('indicator')
                    ? const HeroListBoxItemIndicator()
                    : null,
              ),
          ],
        ),
      );
    },
    code: (PlaygroundValues values) =>
        '''
HeroListBox(
  semanticLabel: 'Users',
  selectionMode: HeroSelectionMode.${values.option('selectionMode')},
  variant: HeroListBoxVariant.${values.option('variant')},${values.toggle('disabledKeys') ? "\n  disabledKeys: const <Object>{'2'}," : ''}
  children: const <Widget>[
    HeroListBoxItem(
      id: '1',
      label: 'Bob',${values.toggle('description') ? "\n      description: 'bob@heroui.com'," : ''}${values.toggle('indicator') ? '\n      indicator: HeroListBoxItemIndicator(),' : ''}
    ),
    // ...
  ],
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => SizedBox(
        width: 220,
        child: HeroListBox(
          semanticLabel: 'Users',
          selectionMode: HeroSelectionMode.single,
          children: _userItems(),
        ),
      ),
      code: _usersCode,
    ),
    DemoExample(
      title: 'With Disabled Items',
      builder: (BuildContext context) =>
          _fileActions(context, disabledKeys: const <Object>{'delete-file'}),
      code: _fileActionsCode.replaceFirst(
        'DISABLED_KEYS',
        "disabledKeys: const <Object>{'delete-file'},",
      ),
    ),
    DemoExample(
      title: 'With Sections',
      builder: _fileActions,
      code: _fileActionsCode.replaceFirst('    DISABLED_KEYS\n', ''),
    ),
    DemoExample(
      title: 'Multi Select',
      builder: (BuildContext context) => _SurfaceCard(
        child: HeroListBox(
          semanticLabel: 'Users',
          selectionMode: HeroSelectionMode.multiple,
          children: _userItems(),
        ),
      ),
      code: '''
HeroSurface(
  width: 256,
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  shadow: theme.shadows.surface,
  child: HeroListBox(
    semanticLabel: 'Users',
    selectionMode: HeroSelectionMode.multiple,
    children: userItems, // as in Usage
  ),
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _ControlledListBox(),
      code:
          '''
Set<Object> selected = <Object>{'1'};

Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    HeroSurface(
      width: 256,
      borderRadius: BorderRadius.circular(theme.radii.xl3),
      shadow: theme.shadows.surface,
      child: HeroListBox(
        semanticLabel: 'Users',
        selectionMode: HeroSelectionMode.multiple,
        selectedKeys: selected,
        onSelectionChanged: (Set<Object> keys) =>
            setState(() => selected = keys),
        children: <Widget>[
          HeroListBoxItem(
            id: '1',
            textValue: 'Bob',
            startContent: bobAvatar,
            label: 'Bob',
            description: 'bob@heroui.com',
            indicator: $_checkIndicatorCode,
          ),
          // Fred and Martha alike.
        ],
      ),
    ),
    Text(
      'Selected: \${selected.isEmpty ? 'None' : selected.join(', ')}',
      style: theme.typography.sm.copyWith(color: theme.colors.muted),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Virtualization',
      description:
          'Virtualized lists build only the rows in view, so they stay fast '
          'with large datasets.',
      builder: (BuildContext context) => SizedBox(
        width: 300,
        height: 400,
        child: HeroListBox.builder(
          semanticLabel: 'Virtualized list with 1000 items',
          virtualized: true,
          rowHeight: 50,
          itemCount: _virtualUsers.length,
          itemBuilder: (BuildContext context, int index) {
            final _User user = _virtualUsers[index];
            return HeroListBoxItem(
              id: user.id,
              textValue: user.name,
              label: user.name,
              description: user.email,
              indicator: const HeroListBoxItemIndicator(),
            );
          },
        ),
      ),
      code: '''
SizedBox(
  width: 300,
  height: 400,
  child: HeroListBox.builder(
    semanticLabel: 'Virtualized list with 1000 items',
    virtualized: true,
    rowHeight: 50,
    itemCount: users.length,
    itemBuilder: (BuildContext context, int index) {
      final User user = users[index];
      return HeroListBoxItem(
        id: user.id,
        textValue: user.name,
        label: user.name,
        description: user.email,
        indicator: const HeroListBoxItemIndicator(),
      );
    },
  ),
)''',
    ),
    DemoExample(
      title: 'Custom Check Icon',
      builder: (BuildContext context) => _SurfaceCard(
        child: HeroListBox(
          semanticLabel: 'Users',
          selectionMode: HeroSelectionMode.multiple,
          children: _userItems(indicator: _checkIndicator(context)),
        ),
      ),
      code:
          '''
HeroListBox(
  semanticLabel: 'Users',
  selectionMode: HeroSelectionMode.multiple,
  children: <Widget>[
    HeroListBoxItem(
      id: '1',
      textValue: 'Bob',
      startContent: bobAvatar,
      label: 'Bob',
      description: 'bob@heroui.com',
      indicator: $_checkIndicatorCode,
    ),
    // Fred and Martha alike.
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      builder: (BuildContext context) => SizedBox(
        width: 220,
        child: HeroListBox(
          semanticLabel: 'Users',
          selectionMode: HeroSelectionMode.single,
          children: <Widget>[
            for (final (String, String, String) user in _users)
              _userItem(user, builder: _renderUser(user.$2)),
          ],
        ),
      ),
      code: '''
HeroListBoxItem(
  id: '1',
  textValue: 'Bob',
  startContent: bobAvatar,
  builder: (BuildContext context, HeroListBoxItemState state) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const HeroLabel.text('Bob'),
      HeroDescription.text(
        state.isSelected ? 'Selected · bob@heroui.com' : 'bob@heroui.com',
      ),
    ],
  ),
  indicator: const HeroListBoxItemIndicator(),
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) => const _CustomListBox(),
      code: '''
HeroSurface(
  width: 224,
  borderRadius: BorderRadius.circular(theme.radii.xl),
  border: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
  shadow: theme.shadows.surface,
  child: HeroListBox(
    semanticLabel: 'Assignee',
    selectionMode: HeroSelectionMode.single,
    itemStyle: HeroListBoxItemStyle(
      borderRadius: BorderRadius.circular(theme.radii.lg),
      backgroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => states.contains(WidgetState.focused)
            ? theme.colors.accent.withValues(alpha: 0.1)
            : states.contains(WidgetState.selected)
            ? theme.colors.accent.withValues(alpha: 0.05)
            : null,
      ),
    ),
    children: userItems.take(2).toList(),
  ),
)''',
    ),
  ],
);

HeroListBoxItemWidgetBuilder _renderUser(String name) =>
    (BuildContext context, HeroListBoxItemState state) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        HeroLabel.text(name),
        HeroDescription.text(
          state.isSelected
              ? 'Selected · ${name.toLowerCase()}@heroui.com'
              : '${name.toLowerCase()}@heroui.com',
        ),
      ],
    );

class _ControlledListBox extends StatefulWidget {
  const _ControlledListBox();

  @override
  State<_ControlledListBox> createState() => _ControlledListBoxState();
}

class _ControlledListBoxState extends State<_ControlledListBox> {
  Set<Object> _selected = <Object>{'1'};

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        _SurfaceCard(
          child: HeroListBox(
            semanticLabel: 'Users',
            selectionMode: HeroSelectionMode.multiple,
            selectedKeys: _selected,
            onSelectionChanged: (Set<Object> keys) =>
                setState(() => _selected = keys),
            children: _userItems(indicator: _checkIndicator(context)),
          ),
        ),
        Text(
          'Selected: ${_selected.isEmpty ? 'None' : _selected.join(', ')}',
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
      ],
    );
  }
}

class _CustomListBox extends StatelessWidget {
  const _CustomListBox();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final Color border = theme.colors.border;
    return HeroSurface(
      width: 224,
      borderRadius: BorderRadius.circular(theme.radii.xl),
      border: BorderSide(color: border.withValues(alpha: border.a * 0.8)),
      shadow: theme.shadows.surface,
      child: HeroListBox(
        semanticLabel: 'Assignee',
        selectionMode: HeroSelectionMode.single,
        itemStyle: HeroListBoxItemStyle(
          borderRadius: BorderRadius.circular(theme.radii.lg),
          backgroundColor: WidgetStateProperty.resolveWith(
            (Set<WidgetState> states) => states.contains(WidgetState.focused)
                ? theme.colors.accent.withValues(alpha: 0.1)
                : states.contains(WidgetState.selected)
                ? theme.colors.accent.withValues(alpha: 0.05)
                : null,
          ),
        ),
        children: _userItems().take(2).toList(),
      ),
    );
  }
}

class _User {
  const _User(this.id, this.name, this.email);

  final int id;
  final String name;
  final String email;
}

const List<String> _firstNames = <String>[
  'Emma',
  'Liam',
  'Olivia',
  'Noah',
  'Ava',
  'James',
  'Sophia',
  'Oliver',
  'Isabella',
  'Lucas',
  'Mia',
  'Ethan',
  'Charlotte',
  'Mason',
  'Amelia',
  'Logan',
  'Harper',
  'Alexander',
  'Ella',
  'Benjamin',
];

const List<String> _lastNames = <String>[
  'Smith',
  'Johnson',
  'Williams',
  'Brown',
  'Jones',
  'Garcia',
  'Miller',
  'Davis',
  'Rodriguez',
  'Martinez',
  'Anderson',
  'Taylor',
  'Thomas',
  'Jackson',
  'White',
  'Harris',
  'Clark',
  'Lewis',
  'Robinson',
  'Walker',
];

final List<_User> _virtualUsers = <_User>[
  for (int i = 0; i < 1000; i++)
    _User(
      i + 1,
      '${_firstNames[i % 20]} ${_lastNames[(i ~/ 20) % 20]}',
      '${_firstNames[i % 20].toLowerCase()}.'
          '${_lastNames[(i ~/ 20) % 20].toLowerCase()}@acme.com',
    ),
];
