import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const List<(String, String, String)> _overview = <(String, String, String)>[
  ('overview', 'Overview', 'View your project overview and recent activity.'),
  (
    'analytics',
    'Analytics',
    'Track your metrics and analyze performance data.',
  ),
  ('reports', 'Reports', 'Generate and download detailed reports.'),
];

const List<(String, String, String, String)> _settings =
    <(String, String, String, String)>[
      (
        'account',
        'Account',
        'Account Settings',
        'Manage your account information and preferences.',
      ),
      (
        'security',
        'Security',
        'Security Settings',
        'Configure two-factor authentication and password settings.',
      ),
      (
        'notifications',
        'Notifications',
        'Notification Preferences',
        'Choose how and when you want to receive notifications.',
      ),
      (
        'billing',
        'Billing',
        'Billing Information',
        'View and manage your subscription and payment methods.',
      ),
    ];

const List<(String, String, String)> _alignment = <(String, String, String)>[
  ('general', 'General', 'Manage your account information and preferences.'),
  (
    'billing',
    'Subscription & Billing',
    'View and manage your plan and payment methods.',
  ),
  (
    'appearance',
    'Appearance',
    'Choose a theme and adjust the interface density.',
  ),
  (
    'notifications',
    'Notifications',
    'Choose how and when you want to receive notifications.',
  ),
  (
    'privacy',
    'Privacy',
    'Control what you share and who can see your activity.',
  ),
];

/// `max-w-md` / `max-w-lg` wrappers used by the docs examples.
Widget _maxWidth(double width, Widget child) => ConstrainedBox(
  constraints: BoxConstraints(maxWidth: width),
  child: child,
);

/// The basic three-tab example, optionally with separators or a variant.
Widget _overviewTabs({
  HeroTabsVariant variant = HeroTabsVariant.primary,
  bool separators = false,
  Set<String> disabled = const <String>{},
}) => _maxWidth(
  448,
  HeroTabs(
    variant: variant,
    children: <Widget>[
      HeroTabListContainer(
        child: HeroTabList(
          semanticLabel: 'Options',
          children: <Widget>[
            for (int i = 0; i < _overview.length; i++)
              HeroTab(
                id: _overview[i].$1,
                isDisabled: disabled.contains(_overview[i].$1),
                separator: separators && i > 0
                    ? const HeroTabSeparator()
                    : null,
                child: Text(_overview[i].$2),
              ),
          ],
        ),
      ),
      for (final (String id, String _, String text) in _overview)
        HeroTabPanel(id: id, padding: _panelTop, child: Text(text)),
    ],
  ),
);

/// `className="pt-4"` on the docs panels.
const EdgeInsetsDirectional _panelTop = EdgeInsetsDirectional.fromSTEB(
  8,
  16,
  8,
  8,
);

/// `className="px-4"` on the vertical docs panels.
const EdgeInsetsDirectional _panelX = EdgeInsetsDirectional.symmetric(
  horizontal: 16,
  vertical: 8,
);

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel(this.title, this.text);

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Text(
          title,
          style: theme.typography
              .style(HeroFontSize.base, weight: HeroTypography.semibold)
              .copyWith(color: theme.colors.foreground),
        ),
        Text(
          text,
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
      ],
    );
  }
}

Widget _verticalTabs({HeroTabsVariant variant = HeroTabsVariant.primary}) =>
    _maxWidth(
      512,
      HeroTabs(
        orientation: Axis.vertical,
        variant: variant,
        children: <Widget>[
          HeroTabListContainer(
            child: HeroTabList(
              semanticLabel: 'Vertical tabs',
              children: <Widget>[
                for (final (String id, String label, String _, String _)
                    in _settings)
                  HeroTab(id: id, child: Text(label)),
              ],
            ),
          ),
          for (final (String id, String _, String title, String text)
              in _settings)
            HeroTabPanel(
              id: id,
              padding: _panelX,
              child: _SettingsPanel(title, text),
            ),
        ],
      ),
    );

const String _basicCode = '''
HeroTabs(
  children: <Widget>[
    HeroTabListContainer(
      child: HeroTabList(
        semanticLabel: 'Options',
        children: const <Widget>[
          HeroTab(id: 'overview', child: Text('Overview')),
          HeroTab(id: 'analytics', child: Text('Analytics')),
          HeroTab(id: 'reports', child: Text('Reports')),
        ],
      ),
    ),
    const HeroTabPanel(
      id: 'overview',
      child: Text('View your project overview and recent activity.'),
    ),
    const HeroTabPanel(
      id: 'analytics',
      child: Text('Track your metrics and analyze performance data.'),
    ),
    const HeroTabPanel(
      id: 'reports',
      child: Text('Generate and download detailed reports.'),
    ),
  ],
)''';

final ComponentDemo tabsDemo = ComponentDemo(
  slug: 'tabs',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary']),
      OptionsControl('orientation', <String>['horizontal', 'vertical']),
      OptionsControl('align', <String>[
        'start',
        'center',
        'end',
      ], initial: 'center'),
      ToggleControl('separators'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => _maxWidth(
      448,
      HeroTabs(
        variant: values.pick('variant', HeroTabsVariant.values),
        orientation: values.pick('orientation', Axis.values),
        align: values.pick('align', HeroTabsAlign.values),
        isDisabled: values.toggle('isDisabled'),
        children: <Widget>[
          HeroTabListContainer(
            child: HeroTabList(
              semanticLabel: 'Options',
              children: <Widget>[
                for (int i = 0; i < _overview.length; i++)
                  HeroTab(
                    id: _overview[i].$1,
                    separator: values.toggle('separators') && i > 0
                        ? const HeroTabSeparator()
                        : null,
                    child: Text(_overview[i].$2),
                  ),
              ],
            ),
          ),
          for (final (String id, String _, String text) in _overview)
            HeroTabPanel(id: id, child: Text(text)),
        ],
      ),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroTabs(
  variant: HeroTabsVariant.${values.option('variant')},
  orientation: Axis.${values.option('orientation')},
  align: HeroTabsAlign.${values.option('align')},
  isDisabled: ${values.toggle('isDisabled')},
  children: <Widget>[
    HeroTabListContainer(
      child: HeroTabList(
        semanticLabel: 'Options',
        children: const <Widget>[
          HeroTab(id: 'overview', child: Text('Overview')),
          HeroTab(${values.toggle('separators') ? "\n            separator: HeroTabSeparator(),\n            " : ''}id: 'analytics', child: Text('Analytics')),
          HeroTab(${values.toggle('separators') ? "\n            separator: HeroTabSeparator(),\n            " : ''}id: 'reports', child: Text('Reports')),
        ],
      ),
    ),
    // One HeroTabPanel per tab.
  ],
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => _overviewTabs(),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Vertical',
      builder: (BuildContext context) => _verticalTabs(),
      code: '''
HeroTabs(
  orientation: Axis.vertical,
  children: <Widget>[
    HeroTabListContainer(
      child: HeroTabList(
        semanticLabel: 'Vertical tabs',
        children: const <Widget>[
          HeroTab(id: 'account', child: Text('Account')),
          HeroTab(id: 'security', child: Text('Security')),
          HeroTab(id: 'notifications', child: Text('Notifications')),
          HeroTab(id: 'billing', child: Text('Billing')),
        ],
      ),
    ),
    const HeroTabPanel(
      id: 'account',
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      child: Text('Manage your account information and preferences.'),
    ),
    // ...
  ],
)''',
    ),
    DemoExample(
      title: 'Overflow',
      description:
          'When the tabs do not fit, the list container scrolls and shows '
          'chevrons and fading edges.',
      builder: (BuildContext context) => const _OverflowTabs(),
      code: r'''
const List<String> items = <String>[
  'Overview', 'Analytics', 'Reports', 'Performance', 'Engagement',
  'Audience', 'Acquisition', 'Retention', 'Settings',
];

SizedBox(
  width: 400,
  child: HeroTabs(
    children: <Widget>[
      HeroTabListContainer(
        child: HeroTabList(
          semanticLabel: 'Overflow options',
          children: <Widget>[
            for (final String item in items)
              HeroTab(id: item, child: Text(item)),
          ],
        ),
      ),
      for (final String item in items)
        HeroTabPanel(id: item, child: Text('$item panel content.')),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Disabled Tab',
      builder: (BuildContext context) => _maxWidth(
        448,
        const HeroTabs(
          children: <Widget>[
            HeroTabListContainer(
              child: HeroTabList(
                semanticLabel: 'Tabs with disabled',
                children: <Widget>[
                  HeroTab(id: 'active', child: Text('Active')),
                  HeroTab(
                    id: 'disabled',
                    isDisabled: true,
                    child: Text('Disabled'),
                  ),
                  HeroTab(id: 'available', child: Text('Available')),
                ],
              ),
            ),
            HeroTabPanel(
              id: 'active',
              padding: _panelTop,
              child: Text('This tab is active and can be selected.'),
            ),
            HeroTabPanel(
              id: 'disabled',
              padding: _panelTop,
              child: Text('This content cannot be accessed.'),
            ),
            HeroTabPanel(
              id: 'available',
              padding: _panelTop,
              child: Text('This tab is also available for selection.'),
            ),
          ],
        ),
      ),
      code: '''
HeroTab(
  id: 'disabled',
  isDisabled: true,
  child: const Text('Disabled'),
)''',
    ),
    DemoExample(
      title: 'With Separator',
      description:
          'Give every tab but the first a HeroTabSeparator to divide the tabs.',
      builder: (BuildContext context) => _overviewTabs(separators: true),
      code: '''
HeroTabList(
  semanticLabel: 'Options',
  children: const <Widget>[
    HeroTab(id: 'overview', child: Text('Overview')),
    HeroTab(
      id: 'analytics',
      separator: HeroTabSeparator(),
      child: Text('Analytics'),
    ),
    HeroTab(
      id: 'reports',
      separator: HeroTabSeparator(),
      child: Text('Reports'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Secondary Variant',
      builder: (BuildContext context) =>
          _overviewTabs(variant: HeroTabsVariant.secondary),
      code: '''
HeroTabs(
  variant: HeroTabsVariant.secondary,
  children: <Widget>[
    HeroTabListContainer(
      child: HeroTabList(
        semanticLabel: 'Options',
        children: const <Widget>[
          HeroTab(id: 'overview', child: Text('Overview')),
          HeroTab(id: 'analytics', child: Text('Analytics')),
          HeroTab(id: 'reports', child: Text('Reports')),
        ],
      ),
    ),
    // Panels...
  ],
)''',
    ),
    DemoExample(
      title: 'Secondary Variant Vertical',
      builder: (BuildContext context) =>
          _verticalTabs(variant: HeroTabsVariant.secondary),
      code: '''
HeroTabs(
  orientation: Axis.vertical,
  variant: HeroTabsVariant.secondary,
  children: <Widget>[
    HeroTabListContainer(
      child: HeroTabList(
        semanticLabel: 'Vertical tabs',
        children: const <Widget>[
          HeroTab(id: 'account', child: Text('Account')),
          HeroTab(id: 'security', child: Text('Security')),
          HeroTab(id: 'notifications', child: Text('Notifications')),
          HeroTab(id: 'billing', child: Text('Billing')),
        ],
      ),
    ),
    // Panels...
  ],
)''',
    ),
    DemoExample(
      title: 'Alignment',
      description:
          'Tab content is centered by default; align it to the start or end, '
          'for example for sidebar navigation.',
      builder: (BuildContext context) => _maxWidth(
        512,
        HeroTabs(
          align: HeroTabsAlign.start,
          orientation: Axis.vertical,
          variant: HeroTabsVariant.secondary,
          children: <Widget>[
            HeroTabListContainer(
              child: HeroTabList(
                semanticLabel: 'Settings',
                children: <Widget>[
                  for (final (String id, String label, String _) in _alignment)
                    HeroTab(id: id, child: Text(label)),
                ],
              ),
            ),
            for (final (String id, String label, String text) in _alignment)
              HeroTabPanel(
                id: id,
                padding: _panelX,
                child: _SettingsPanel(label, text),
              ),
          ],
        ),
      ),
      code: '''
HeroTabs(
  align: HeroTabsAlign.start,
  orientation: Axis.vertical,
  variant: HeroTabsVariant.secondary,
  children: <Widget>[
    HeroTabListContainer(
      child: HeroTabList(
        semanticLabel: 'Settings',
        children: const <Widget>[
          HeroTab(id: 'general', child: Text('General')),
          HeroTab(id: 'billing', child: Text('Subscription & Billing')),
          HeroTab(id: 'appearance', child: Text('Appearance')),
          HeroTab(id: 'notifications', child: Text('Notifications')),
          HeroTab(id: 'privacy', child: Text('Privacy')),
        ],
      ),
    ),
    // Panels...
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'A builder renders each tab from its state, here as a link-styled '
          'label.',
      builder: (BuildContext context) => const _RenderFunctionTabs(),
      code: '''
HeroTab(
  id: 'components',
  builder: (BuildContext context, HeroTabState state) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: <Widget>[
      const Text('Components'),
      if (state.isHovered || state.isFocusVisible)
        const HeroIcon(HeroIcons.externalLink, size: 12),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A billing-cycle switch: a tinted list container, square tabs and '
          'an accent indicator.',
      builder: (BuildContext context) => const _CustomTabs(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final HeroColors colors = theme.colors;
final BorderRadius radius = BorderRadius.all(Radius.circular(theme.radii.lg));
bool selected(Set<WidgetState> s) => s.contains(WidgetState.selected);

HeroTab(
  id: 'monthly',
  indicator: HeroTabIndicator(
    color: colors.accent,
    borderRadius: radius,
    shadows: const <BoxShadow>[],
  ),
  style: HeroTabStyle(
    borderRadius: radius,
    opacity: const WidgetStatePropertyAll<double>(1),
    backgroundColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> s) => selected(s)
          ? null
          : s.contains(WidgetState.pressed)
          ? colors.accentSoftHover
          : s.contains(WidgetState.hovered)
          ? colors.accentSoft
          : null,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> s) => selected(s)
          ? colors.accentForeground
          : s.contains(WidgetState.hovered)
          ? colors.accentSoftForeground
          : colors.muted,
    ),
  ),
  child: const Text('Monthly'),
)

HeroTabListContainer(
  decoration: ShapeDecoration(
    color: colors.accentSoft.withValues(alpha: 0.3),
    shape: theme.shapeAll(
      theme.radii.xl,
      side: BorderSide(color: colors.accent.withValues(alpha: 0.1)),
    ),
  ),
  child: HeroTabList(semanticLabel: 'Billing cycle', children: tabs),
)''',
    ),
  ],
);

class _OverflowTabs extends StatelessWidget {
  const _OverflowTabs();

  static const List<String> _items = <String>[
    'Overview',
    'Analytics',
    'Reports',
    'Performance',
    'Engagement',
    'Audience',
    'Acquisition',
    'Retention',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: HeroTabs(
        children: <Widget>[
          HeroTabListContainer(
            child: HeroTabList(
              semanticLabel: 'Overflow options',
              children: <Widget>[
                for (final String item in _items)
                  HeroTab(id: item, child: Text(item)),
              ],
            ),
          ),
          for (final String item in _items)
            HeroTabPanel(
              id: item,
              padding: _panelTop,
              child: Text('$item panel content.'),
            ),
        ],
      ),
    );
  }
}

class _RenderFunctionTabs extends StatelessWidget {
  const _RenderFunctionTabs();

  static const List<(String, String)> _links = <(String, String)>[
    ('getting-started', 'Getting Started'),
    ('components', 'Components'),
    ('releases', 'Releases'),
  ];

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return _maxWidth(
      448,
      HeroTabs(
        children: <Widget>[
          HeroTabListContainer(
            child: HeroTabList(
              semanticLabel: 'Options',
              children: <Widget>[
                for (final (String id, String label) in _links)
                  HeroTab(
                    id: id,
                    builder: (BuildContext context, HeroTabState state) => Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: theme.spacing(1),
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (state.isHovered || state.isFocusVisible)
                          HeroIcon(
                            HeroIcons.externalLink,
                            size: theme.spacing(3),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          for (final (String id, String text) in const <(String, String)>[
            ('overview', 'View your project overview and recent activity.'),
            ('analytics', 'Track your metrics and analyze performance data.'),
            ('reports', 'Generate and download detailed reports.'),
          ])
            HeroTabPanel(id: id, padding: _panelTop, child: Text(text)),
        ],
      ),
    );
  }
}

class _CustomTabs extends StatelessWidget {
  const _CustomTabs();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final BorderRadius radius = BorderRadius.all(
      Radius.circular(theme.radii.lg),
    );
    bool selected(Set<WidgetState> s) => s.contains(WidgetState.selected);
    final HeroTabStyle style = HeroTabStyle(
      borderRadius: radius,
      opacity: const WidgetStatePropertyAll<double>(1),
      backgroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> s) => selected(s)
            ? null
            : s.contains(WidgetState.pressed)
            ? colors.accentSoftHover
            : s.contains(WidgetState.hovered)
            ? colors.accentSoft
            : null,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> s) => selected(s)
            ? colors.accentForeground
            : s.contains(WidgetState.hovered)
            ? colors.accentSoftForeground
            : colors.muted,
      ),
    );
    final HeroTabIndicator indicator = HeroTabIndicator(
      color: colors.accent,
      borderRadius: radius,
      shadows: const <BoxShadow>[],
    );
    final TextStyle panelText = theme.typography.sm.copyWith(
      color: colors.muted,
    );
    const EdgeInsetsDirectional panelPadding = EdgeInsetsDirectional.fromSTEB(
      8,
      12,
      8,
      8,
    );
    return _maxWidth(
      384,
      HeroTabs(
        children: <Widget>[
          HeroTabListContainer(
            decoration: ShapeDecoration(
              color: colors.accentSoft.withValues(
                alpha: colors.accentSoft.a * 0.3,
              ),
              shape: theme.shapeAll(
                theme.radii.xl,
                side: BorderSide(
                  color: colors.accent.withValues(alpha: colors.accent.a * 0.1),
                ),
              ),
            ),
            child: HeroTabList(
              semanticLabel: 'Billing cycle',
              children: <Widget>[
                HeroTab(
                  id: 'monthly',
                  indicator: indicator,
                  style: style,
                  child: const Text('Monthly'),
                ),
                HeroTab(
                  id: 'yearly',
                  indicator: indicator,
                  style: style,
                  child: const Text('Yearly'),
                ),
              ],
            ),
          ),
          HeroTabPanel(
            id: 'monthly',
            padding: panelPadding,
            child: Text('Billed monthly, cancel anytime.', style: panelText),
          ),
          HeroTabPanel(
            id: 'yearly',
            padding: panelPadding,
            child: Text('Save 20% with annual billing.', style: panelText),
          ),
        ],
      ),
    );
  }
}
