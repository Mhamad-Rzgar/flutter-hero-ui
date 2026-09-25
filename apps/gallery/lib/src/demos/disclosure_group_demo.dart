import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const String _qrCodeUrl =
    'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/images/qr-code-native.png';

/// A full-width button trigger that is secondary while expanded and a
/// transparent tertiary button while collapsed, as in the docs examples.
Widget _trigger(HeroIconData icon, String title) =>
    HeroDisclosureTrigger.builder(
      builder: (BuildContext context, HeroDisclosureState state) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroButton(
          variant: state.isExpanded
              ? HeroButtonVariant.secondary
              : HeroButtonVariant.tertiary,
          fullWidth: true,
          isDisabled: state.isDisabled,
          onPressed: state.toggle,
          style: state.isExpanded
              ? null
              : HeroButtonStyle(
                  // `bg-transparent`, keeping the tertiary hover fill.
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (Set<WidgetState> states) =>
                        states.contains(WidgetState.hovered)
                        ? null
                        : theme.colors.defaultColor.withValues(alpha: 0),
                  ),
                ),
          child: Row(
            spacing: theme.spacing(2),
            children: <Widget>[
              HeroIcon(icon),
              Expanded(child: Text(title)),
              HeroDisclosureIndicator(color: theme.colors.muted),
            ],
          ),
        );
      },
    );

/// The centered QR code panel of the docs examples.
class _QrPanel extends StatelessWidget {
  const _QrPanel({
    required this.description,
    required this.note,
    required this.action,
    required this.actionIcon,
  });

  final String description;
  final String note;
  final String action;
  final HeroIconData actionIcon;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle muted = theme.typography.sm.copyWith(
      color: theme.colors.muted,
    );
    return HeroDisclosureBody(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing(2) + theme.spacing(4),
        vertical: theme.spacing(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing(2),
        children: <Widget>[
          Text(description, textAlign: TextAlign.center, style: muted),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: theme.spacing(54)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                _qrCodeUrl,
                fit: BoxFit.cover,
                semanticLabel: 'QR Code',
                errorBuilder:
                    (BuildContext context, Object error, StackTrace? stack) =>
                        Center(
                          child: HeroIcon(
                            HeroIcons.qrCode,
                            size: theme.spacing(24),
                            color: theme.colors.foreground,
                          ),
                        ),
              ),
            ),
          ),
          Text(note, textAlign: TextAlign.center, style: muted),
          Padding(
            padding: EdgeInsets.only(top: theme.spacing(4)),
            child: HeroButton(
              onPressed: () {},
              startContent: HeroIcon(actionIcon),
              child: Text(action),
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _nativeDisclosures({
  String downloadTitle = 'Download App',
}) => <Widget>[
  HeroDisclosure(
    id: 'preview',
    children: <Widget>[
      HeroDisclosureHeading(
        child: _trigger(HeroIcons.qrCode, 'Preview HeroUI Native'),
      ),
      const HeroDisclosureContent(
        child: _QrPanel(
          description:
              'Scan this QR code with your camera app to preview the HeroUI native components.',
          note: 'Expo must be installed on your device.',
          action: 'Preview on Expo Go',
          actionIcon: HeroIcons.smartphone,
        ),
      ),
    ],
  ),
  const HeroSeparator(margin: EdgeInsets.symmetric(vertical: 8)),
  HeroDisclosure(
    id: 'download',
    children: <Widget>[
      HeroDisclosureHeading(
        child: _trigger(HeroIcons.smartphone, downloadTitle),
      ),
      HeroDisclosureContent(
        child: downloadTitle == 'Download App'
            ? const _QrPanel(
                description:
                    'Download the HeroUI native app to explore our mobile components directly on your device.',
                note: 'Available on iOS and Android devices.',
                action: 'Download on App Store',
                actionIcon: HeroIcons.smartphone,
              )
            : const _QrPanel(
                description:
                    'Scan this QR code with your camera app to preview the HeroUI native components.',
                note: 'Expo must be installed on your device.',
                action: 'Download on App Store',
                actionIcon: HeroIcons.smartphone,
              ),
      ),
    ],
  ),
];

const String _triggerCode = '''
HeroDisclosureTrigger.builder(
  builder: (BuildContext context, HeroDisclosureState state) => HeroButton(
    variant: state.isExpanded
        ? HeroButtonVariant.secondary
        : HeroButtonVariant.tertiary,
    fullWidth: true,
    isDisabled: state.isDisabled,
    onPressed: state.toggle,
    child: Row(
      spacing: 8,
      children: <Widget>[
        const HeroIcon(HeroIcons.qrCode),
        const Expanded(child: Text('Preview HeroUI Native')),
        HeroDisclosureIndicator(color: theme.colors.muted),
      ],
    ),
  ),
)''';

final ComponentDemo disclosureGroupDemo = ComponentDemo(
  slug: 'disclosure-group',
  playground: Playground(
    controls: const <PlaygroundControl>[
      ToggleControl('allowsMultipleExpanded'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: HeroDisclosureGroup(
        key: ValueKey<bool>(values.toggle('allowsMultipleExpanded')),
        allowsMultipleExpanded: values.toggle('allowsMultipleExpanded'),
        isDisabled: values.toggle('isDisabled'),
        children: const <Widget>[
          _SimpleDisclosure(
            id: 'billing',
            title: 'Billing',
            body: 'Invoices are issued on the first of each month.',
          ),
          HeroSeparator(margin: EdgeInsets.symmetric(vertical: 4)),
          _SimpleDisclosure(
            id: 'support',
            title: 'Support',
            body:
                'Reach us at help@heroui.com. Typical response time is under one business day.',
          ),
        ],
      ),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroDisclosureGroup(
  allowsMultipleExpanded: ${values.toggle('allowsMultipleExpanded')},
  isDisabled: ${values.toggle('isDisabled')},
  children: <Widget>[
    HeroDisclosure(id: 'billing', children: billingParts),
    const HeroSeparator(margin: EdgeInsets.symmetric(vertical: 4)),
    HeroDisclosure(id: 'support', children: supportParts),
  ],
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _BasicGroup(),
      code:
          '''
Set<Object> expandedKeys = <Object>{'preview'};

HeroDisclosureGroup(
  expandedKeys: expandedKeys,
  onExpandedChanged: (Set<Object> keys) => setState(() => expandedKeys = keys),
  children: <Widget>[
    HeroDisclosure(
      id: 'preview',
      children: <Widget>[
        HeroDisclosureHeading(child: $_triggerCode),
        HeroDisclosureContent(child: HeroDisclosureBody(child: previewPanel)),
      ],
    ),
    const HeroSeparator(margin: EdgeInsets.symmetric(vertical: 8)),
    HeroDisclosure(
      id: 'download',
      children: <Widget>[
        HeroDisclosureHeading(child: downloadTrigger),
        HeroDisclosureContent(child: HeroDisclosureBody(child: downloadPanel)),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Controlled',
      description:
          'Control which disclosures are expanded with external navigation '
          'controls through expandedKeys and onExpandedChanged.',
      builder: (BuildContext context) => const _ControlledGroup(),
      code: '''
Set<Object> expandedKeys = <Object>{'preview'};

final HeroDisclosureGroupNavigation navigation = HeroDisclosureGroupNavigation(
  expandedKeys: expandedKeys,
  itemIds: const <Object>['preview', 'download'],
  onExpandedChanged: (Set<Object> keys) => setState(() => expandedKeys = keys),
);

Row(
  children: <Widget>[
    const Expanded(child: Text('HeroUI Native')),
    HeroButton(
      isIconOnly: true,
      size: HeroSize.sm,
      variant: HeroButtonVariant.secondary,
      semanticLabel: 'Previous disclosure',
      isDisabled: navigation.isPrevDisabled,
      onPressed: navigation.previous,
      child: const HeroIcon(HeroIcons.chevronUp),
    ),
    HeroButton(
      isIconOnly: true,
      size: HeroSize.sm,
      variant: HeroButtonVariant.secondary,
      semanticLabel: 'Next disclosure',
      isDisabled: navigation.isNextDisabled,
      onPressed: navigation.next,
      child: const HeroIcon(HeroIcons.chevronDown),
    ),
  ],
)

HeroDisclosureGroup(
  expandedKeys: expandedKeys,
  onExpandedChanged: (Set<Object> keys) => setState(() => expandedKeys = keys),
  children: disclosures,
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) => const _CustomGroup(),
      code: '''
HeroSurface(
  color: theme.colors.defaultSoft,
  borderRadius: BorderRadius.circular(theme.radii.xl),
  padding: const EdgeInsets.all(8),
  child: HeroDisclosureGroup(
    children: <Widget>[
      HeroDisclosure(
        id: 'billing',
        children: <Widget>[
          HeroDisclosureHeading(
            child: HeroDisclosureTrigger.builder(
              builder: (BuildContext context, HeroDisclosureState state) =>
                  HeroButton(
                    variant: HeroButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: state.toggle,
                    child: Row(
                      children: <Widget>[
                        const Expanded(child: Text('Billing')),
                        HeroDisclosureIndicator(color: theme.colors.muted),
                      ],
                    ),
                  ),
            ),
          ),
          HeroDisclosureContent(
            child: HeroDisclosureBody(
              child: Text(
                'Invoices are issued on the first of each month.',
                style: theme.typography.sm.copyWith(color: theme.colors.muted),
              ),
            ),
          ),
        ],
      ),
      const HeroSeparator(margin: EdgeInsets.symmetric(vertical: 4)),
      // Support alike.
    ],
  ),
)''',
    ),
  ],
);

class _BasicGroup extends StatefulWidget {
  const _BasicGroup();

  @override
  State<_BasicGroup> createState() => _BasicGroupState();
}

class _BasicGroupState extends State<_BasicGroup> {
  Set<Object> _expanded = <Object>{'preview'};

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Padding(
        padding: EdgeInsets.all(theme.spacing(4)),
        child: HeroDisclosureGroup(
          expandedKeys: _expanded,
          onExpandedChanged: (Set<Object> keys) =>
              setState(() => _expanded = keys),
          children: _nativeDisclosures(),
        ),
      ),
    );
  }
}

class _ControlledGroup extends StatefulWidget {
  const _ControlledGroup();

  @override
  State<_ControlledGroup> createState() => _ControlledGroupState();
}

class _ControlledGroupState extends State<_ControlledGroup> {
  Set<Object> _expanded = <Object>{'preview'};

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroDisclosureGroupNavigation navigation =
        HeroDisclosureGroupNavigation(
          expandedKeys: _expanded,
          itemIds: const <Object>['preview', 'download'],
          onExpandedChanged: (Set<Object> keys) =>
              setState(() => _expanded = keys),
        );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Padding(
        padding: EdgeInsets.all(theme.spacing(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing(4),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: theme.spacing(2)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'HeroUI Native',
                      style: theme.typography
                          .style(
                            HeroFontSize.lg,
                            weight: HeroTypography.semibold,
                          )
                          .copyWith(color: theme.colors.foreground),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: theme.spacing(2),
                    children: <Widget>[
                      HeroButton(
                        isIconOnly: true,
                        size: HeroSize.sm,
                        variant: HeroButtonVariant.secondary,
                        semanticLabel: 'Previous disclosure',
                        isDisabled: navigation.isPrevDisabled,
                        onPressed: navigation.previous,
                        child: const HeroIcon(HeroIcons.chevronUp),
                      ),
                      HeroButton(
                        isIconOnly: true,
                        size: HeroSize.sm,
                        variant: HeroButtonVariant.secondary,
                        semanticLabel: 'Next disclosure',
                        isDisabled: navigation.isNextDisabled,
                        onPressed: navigation.next,
                        child: const HeroIcon(HeroIcons.chevronDown),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            HeroDisclosureGroup(
              expandedKeys: _expanded,
              onExpandedChanged: (Set<Object> keys) =>
                  setState(() => _expanded = keys),
              children: _nativeDisclosures(
                downloadTitle: 'Download HeroUI Native',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleDisclosure extends StatelessWidget {
  const _SimpleDisclosure({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroDisclosure(
      id: id,
      children: <Widget>[
        HeroDisclosureHeading(
          child: HeroDisclosureTrigger.builder(
            builder: (BuildContext context, HeroDisclosureState state) =>
                HeroButton(
                  variant: HeroButtonVariant.ghost,
                  fullWidth: true,
                  isDisabled: state.isDisabled,
                  onPressed: state.toggle,
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text(title)),
                      HeroDisclosureIndicator(color: theme.colors.muted),
                    ],
                  ),
                ),
          ),
        ),
        HeroDisclosureContent(
          child: HeroDisclosureBody(
            child: Text(
              body,
              style: theme.typography.sm.copyWith(color: theme.colors.muted),
            ),
          ),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: HeroSurface(
        color: theme.colors.defaultSoft,
        borderRadius: BorderRadius.circular(theme.radii.xl),
        padding: EdgeInsets.all(theme.spacing(2)),
        child: HeroDisclosureGroup(
          children: <Widget>[
            const _SimpleDisclosure(
              id: 'billing',
              title: 'Billing',
              body: 'Invoices are issued on the first of each month.',
            ),
            HeroSeparator(
              margin: EdgeInsets.symmetric(vertical: theme.spacing(1)),
            ),
            const _SimpleDisclosure(
              id: 'support',
              title: 'Support',
              body:
                  'Reach us at help@heroui.com. Typical response time is under one business day.',
            ),
          ],
        ),
      ),
    );
  }
}
