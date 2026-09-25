import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const String _assets = 'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com';

const List<(String, String, HeroIconData)>
_orders = <(String, String, HeroIconData)>[
  (
    'How do I place an order?',
    "Browse our products, add items to your cart, and proceed to checkout. You'll need to provide shipping and payment information to complete your purchase.",
    HeroIcons.shoppingBag,
  ),
  (
    'Can I modify or cancel my order?',
    "Yes, you can modify or cancel your order before it's shipped. Once your order is processed, you can't make changes.",
    HeroIcons.receipt,
  ),
  (
    'What payment methods do you accept?',
    'We accept all major credit cards, including Visa, Mastercard, and American Express.',
    HeroIcons.creditCard,
  ),
  (
    'How much does shipping cost?',
    'Shipping costs vary based on your location and the size of your order. We offer free shipping for orders over \$50.',
    HeroIcons.box,
  ),
  (
    'Do you ship internationally?',
    'Yes, we ship to most countries. Please check our shipping rates and policies for more information.',
    HeroIcons.planetEarth,
  ),
  (
    'How do I request a refund?',
    "If you're not satisfied with your purchase, you can request a refund within 30 days of purchase. Please contact our customer support team for assistance.",
    HeroIcons.arrowsRotateLeft,
  ),
];

const List<(String, String, String)> _guides = <(String, String, String)>[
  (
    'getting-started',
    'Getting Started',
    'Learn the basics of HeroUI and how to integrate it into your React project. This section covers installation, setup, and your first component.',
  ),
  (
    'core-concepts',
    'Core Concepts',
    'Understand the fundamental concepts behind HeroUI, including the compound component pattern, styling with Tailwind CSS, and accessibility features.',
  ),
  (
    'advanced-usage',
    'Advanced Usage',
    'Explore advanced features like custom variants, theme customization, and integration with other libraries in your React ecosystem.',
  ),
  (
    'best-practices',
    'Best Practices',
    'Follow our recommended best practices for building performant, accessible, and maintainable applications with HeroUI components.',
  ),
];

/// The 448 px wide column of the docs examples (`w-full max-w-md`).
Widget _medium(Widget child) => ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 448),
  child: child,
);

/// An icon in front of a title (`me-3 size-4 shrink-0 text-muted`).
class _MutedIcon extends StatelessWidget {
  const _MutedIcon(this.icon);

  final HeroIconData icon;

  @override
  Widget build(BuildContext context) =>
      HeroIcon(icon, color: HeroTheme.of(context).colors.muted);
}

List<Widget> _orderItems({int count = 6}) => <Widget>[
  for (final (String title, String body, HeroIconData icon) in _orders.take(
    count,
  ))
    HeroAccordionItem(
      startContent: _MutedIcon(icon),
      title: Text(title),
      child: Text(body),
    ),
];

const String _ordersCode = '''
HeroAccordion(
  children: <Widget>[
    for (final Order order in orders)
      HeroAccordionItem(
        startContent: HeroIcon(order.icon, color: theme.colors.muted),
        title: Text(order.title),
        child: Text(order.content),
      ),
  ],
)''';

final ComponentDemo accordionDemo = ComponentDemo(
  slug: 'accordion',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['standard', 'surface']),
      ToggleControl('allowsMultipleExpanded'),
      ToggleControl('hideSeparator'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => _medium(
      HeroAccordion(
        key: ValueKey<bool>(values.toggle('allowsMultipleExpanded')),
        variant: values.pick('variant', HeroAccordionVariant.values),
        allowsMultipleExpanded: values.toggle('allowsMultipleExpanded'),
        hideSeparator: values.toggle('hideSeparator'),
        isDisabled: values.toggle('isDisabled'),
        children: _orderItems(count: 3),
      ),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroAccordion(
  variant: HeroAccordionVariant.${values.option('variant')},
  allowsMultipleExpanded: ${values.toggle('allowsMultipleExpanded')},
  hideSeparator: ${values.toggle('hideSeparator')},
  isDisabled: ${values.toggle('isDisabled')},
  children: const <Widget>[
    HeroAccordionItem(
      startContent: HeroIcon(HeroIcons.shoppingBag),
      title: Text('How do I place an order?'),
      child: Text('Browse our products, ...'),
    ),
    // ...
  ],
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) =>
          _medium(HeroAccordion(children: _orderItems())),
      code: _ordersCode,
    ),
    DemoExample(
      title: 'Surface',
      builder: (BuildContext context) => _medium(
        HeroAccordion(
          variant: HeroAccordionVariant.surface,
          children: _orderItems(),
        ),
      ),
      code: _ordersCode.replaceFirst(
        'HeroAccordion(\n',
        'HeroAccordion(\n  variant: HeroAccordionVariant.surface,\n',
      ),
    ),
    DemoExample(
      title: 'Without Separator',
      builder: (BuildContext context) => _medium(
        HeroAccordion(hideSeparator: true, children: _orderItems(count: 3)),
      ),
      code: _ordersCode.replaceFirst(
        'HeroAccordion(\n',
        'HeroAccordion(\n  hideSeparator: true,\n',
      ),
    ),
    DemoExample(
      title: 'Multiple Expanded',
      builder: (BuildContext context) => _medium(
        HeroAccordion(
          allowsMultipleExpanded: true,
          children: <Widget>[
            for (final (String _, String title, String body) in _guides)
              HeroAccordionItem(title: Text(title), child: Text(body)),
          ],
        ),
      ),
      code: '''
HeroAccordion(
  allowsMultipleExpanded: true,
  children: const <Widget>[
    HeroAccordionItem(
      title: Text('Getting Started'),
      child: Text('Learn the basics of HeroUI ...'),
    ),
    HeroAccordionItem(
      title: Text('Core Concepts'),
      child: Text('Understand the fundamental concepts ...'),
    ),
    // ...
  ],
)''',
    ),
    DemoExample(
      title: 'Disabled State',
      builder: (BuildContext context) => const _DisabledAccordions(),
      code: '''
// The entire accordion.
HeroAccordion(
  isDisabled: true,
  children: const <Widget>[
    HeroAccordionItem(
      title: Text('Disabled Item 1'),
      child: Text('This content cannot be accessed when the accordion is disabled.'),
    ),
    // ...
  ],
)

// Individual items.
HeroAccordion(
  children: const <Widget>[
    HeroAccordionItem(
      title: Text('Active Item'),
      child: Text('This item is active and can be toggled normally.'),
    ),
    HeroAccordionItem(
      isDisabled: true,
      title: Text('Disabled Item'),
      child: Text('This content cannot be accessed when the item is disabled.'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _ControlledAccordion(),
      code: '''
Set<Object> expandedKeys = <Object>{'getting-started'};
final HeroDisclosureGroupNavigation navigation = HeroDisclosureGroupNavigation(
  expandedKeys: expandedKeys,
  itemIds: const <Object>['getting-started', 'core-concepts', 'advanced-usage'],
  onExpandedChanged: (Set<Object> keys) => setState(() => expandedKeys = keys),
);

Row(
  children: <Widget>[
    Text('Expanded: \${expandedKeys.join(', ')}'),
    const Spacer(),
    HeroButton(
      isIconOnly: true,
      size: HeroSize.sm,
      variant: HeroButtonVariant.secondary,
      semanticLabel: 'Previous item',
      isDisabled: navigation.isPrevDisabled,
      onPressed: navigation.previous,
      child: const HeroIcon(HeroIcons.chevronUp),
    ),
    // Next item alike.
  ],
)

HeroAccordion(
  expandedKeys: expandedKeys,
  onExpandedChanged: (Set<Object> keys) => setState(() => expandedKeys = keys),
  children: const <Widget>[
    HeroAccordionItem(
      id: 'getting-started',
      title: Text('Getting Started'),
      child: Text('Learn the basics of HeroUI ...'),
    ),
    // ...
  ],
)''',
    ),
    DemoExample(
      title: 'Custom Indicator',
      builder: (BuildContext context) => const _CustomIndicators(),
      code: '''
HeroAccordion(
  variant: HeroAccordionVariant.surface,
  expandedKeys: expandedKeys,
  onExpandedChanged: (Set<Object> keys) => setState(() => expandedKeys = keys),
  children: <Widget>[
    HeroAccordionItem(
      id: '1',
      title: const Text('Using Plus/Minus Icon'),
      indicator: HeroAccordionIndicator(
        child: HeroIcon(
          expandedKeys.contains('1') ? HeroIcons.minus : HeroIcons.plus,
        ),
      ),
      child: const Text('This accordion uses a plus icon ...'),
    ),
    const HeroAccordionItem(
      id: '2',
      title: Text('Using Caret Icon'),
      indicator: HeroAccordionIndicator(
        child: HeroIcon(HeroIcons.circleChevronDown),
      ),
      child: Text('This item uses a caret icon for the indicator. ...'),
    ),
    const HeroAccordionItem(
      id: '3',
      title: Text('Using Arrow Icon'),
      indicator: HeroAccordionIndicator(
        child: HeroIcon(HeroIcons.chevronsDown),
      ),
      child: Text('This item uses an arrow icon. ...'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      builder: (BuildContext context) => _medium(
        HeroAccordion(
          children: <Widget>[
            for (final (String title, String body, HeroIconData icon)
                in _orders)
              HeroAccordionItem(
                children: <Widget>[
                  HeroAccordionHeading(
                    child: HeroAccordionTrigger(
                      startContent: _MutedIcon(icon),
                      builder:
                          (
                            BuildContext context,
                            HeroAccordionTriggerState state,
                          ) => Text(
                            title,
                            style: state.isExpanded
                                ? TextStyle(
                                    color: HeroTheme.of(context).colors.accent,
                                  )
                                : null,
                          ),
                    ),
                  ),
                  HeroAccordionPanel(
                    child: HeroAccordionBody(child: Text(body)),
                  ),
                ],
              ),
          ],
        ),
      ),
      code: '''
HeroAccordionItem(
  children: <Widget>[
    HeroAccordionHeading(
      child: HeroAccordionTrigger(
        startContent: HeroIcon(HeroIcons.shoppingBag, color: colors.muted),
        builder: (BuildContext context, HeroAccordionTriggerState state) =>
            Text(
              'How do I place an order?',
              style: state.isExpanded ? TextStyle(color: colors.accent) : null,
            ),
      ),
    ),
    const HeroAccordionPanel(
      child: HeroAccordionBody(child: Text('Browse our products, ...')),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'FAQ Layout',
      builder: (BuildContext context) => const _Faq(),
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: 24,
  children: <Widget>[
    Text('Frequently Asked Questions', style: theme.typography.xl2),
    Text(
      'Everything you need to know about licensing and usage.',
      style: theme.typography.lg.copyWith(color: theme.colors.muted),
    ),
    for (final Category category in categories)
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          Text(category.title),
          HeroAccordion(
            variant: HeroAccordionVariant.surface,
            children: <Widget>[
              for (final Question question in category.items)
                HeroAccordionItem(
                  title: Text(question.title),
                  child: Text(question.content),
                ),
            ],
          ),
        ],
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) => const _CustomAccordion(),
      code: '''
HeroAccordion(
  variant: HeroAccordionVariant.surface,
  borderRadius: theme.radii.xl2,
  children: <Widget>[
    for (final Step step in steps)
      HeroAccordionItem(
        children: <Widget>[
          HeroAccordionHeading(
            child: HeroAccordionTrigger(
              style: HeroAccordionTriggerStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(colors.surface),
              ),
              indicator: HeroAccordionIndicator(
                color: colors.muted.withValues(alpha: 0.5),
              ),
              builder: (BuildContext context, HeroAccordionTriggerState state) =>
                  Row(
                    spacing: 8,
                    children: <Widget>[
                      AnimatedScale(
                        scale: state.isHovered ? 1.2 : 1,
                        duration: const Duration(milliseconds: 300),
                        curve: HeroMotion.easeOut,
                        child: AnimatedRotation(
                          turns: state.isHovered ? -10 / 360 : 0,
                          duration: const Duration(milliseconds: 300),
                          curve: HeroMotion.easeOut,
                          child: Image.network(step.iconUrl, width: 44, height: 44),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(step.title),
                            Text(step.subtitle, style: subtitleStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
          ),
          HeroAccordionPanel(
            child: HeroAccordionBody(
              style: TextStyle(color: colors.muted.withValues(alpha: 0.8)),
              child: Text(step.content),
            ),
          ),
        ],
      ),
  ],
)''',
    ),
  ],
);

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Text(
      text,
      style: theme.typography
          .style(HeroFontSize.sm, weight: HeroTypography.medium)
          .copyWith(color: theme.colors.muted),
    );
  }
}

class _DisabledAccordions extends StatelessWidget {
  const _DisabledAccordions();

  @override
  Widget build(BuildContext context) {
    return _medium(
      const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 32,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: <Widget>[
              _Caption('Entire accordion disabled'),
              HeroAccordion(
                isDisabled: true,
                children: <Widget>[
                  HeroAccordionItem(
                    title: Text('Disabled Item 1'),
                    child: Text(
                      'This content cannot be accessed when the accordion is disabled.',
                    ),
                  ),
                  HeroAccordionItem(
                    title: Text('Disabled Item 2'),
                    child: Text(
                      'This content cannot be accessed when the accordion is disabled.',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: <Widget>[
              _Caption('Individual items disabled'),
              HeroAccordion(
                children: <Widget>[
                  HeroAccordionItem(
                    title: Text('Active Item'),
                    child: Text(
                      'This item is active and can be toggled normally.',
                    ),
                  ),
                  HeroAccordionItem(
                    isDisabled: true,
                    title: Text('Disabled Item'),
                    child: Text(
                      'This content cannot be accessed when the item is disabled.',
                    ),
                  ),
                  HeroAccordionItem(
                    title: Text('Another Active Item'),
                    child: Text('This item is also active and can be toggled.'),
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

class _ControlledAccordion extends StatefulWidget {
  const _ControlledAccordion();

  @override
  State<_ControlledAccordion> createState() => _ControlledAccordionState();
}

class _ControlledAccordionState extends State<_ControlledAccordion> {
  Set<Object> _expanded = <Object>{'getting-started'};

  static final List<Object> _ids = <Object>[
    for (final (String id, String _, String _) in _guides.take(3)) id,
  ];

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroDisclosureGroupNavigation navigation =
        HeroDisclosureGroupNavigation(
          expandedKeys: _expanded,
          itemIds: _ids,
          onExpandedChanged: (Set<Object> keys) =>
              setState(() => _expanded = keys),
        );
    return _medium(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Expanded: ',
                    children: <InlineSpan>[
                      TextSpan(
                        text: _expanded.isEmpty ? 'none' : _expanded.join(', '),
                        style: const TextStyle(
                          fontWeight: HeroTypography.semibold,
                        ),
                      ),
                    ],
                  ),
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.muted,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: <Widget>[
                  HeroButton(
                    isIconOnly: true,
                    size: HeroSize.sm,
                    variant: HeroButtonVariant.secondary,
                    semanticLabel: 'Previous item',
                    isDisabled: navigation.isPrevDisabled,
                    onPressed: navigation.previous,
                    child: const HeroIcon(HeroIcons.chevronUp),
                  ),
                  HeroButton(
                    isIconOnly: true,
                    size: HeroSize.sm,
                    variant: HeroButtonVariant.secondary,
                    semanticLabel: 'Next item',
                    isDisabled: navigation.isNextDisabled,
                    onPressed: navigation.next,
                    child: const HeroIcon(HeroIcons.chevronDown),
                  ),
                ],
              ),
            ],
          ),
          HeroAccordion(
            expandedKeys: _expanded,
            onExpandedChanged: (Set<Object> keys) =>
                setState(() => _expanded = keys),
            children: <Widget>[
              for (final (String id, String title, String body) in _guides.take(
                3,
              ))
                HeroAccordionItem(
                  id: id,
                  title: Text(title),
                  child: Text(body),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomIndicators extends StatefulWidget {
  const _CustomIndicators();

  @override
  State<_CustomIndicators> createState() => _CustomIndicatorsState();
}

class _CustomIndicatorsState extends State<_CustomIndicators> {
  Set<Object> _expanded = <Object>{};

  @override
  Widget build(BuildContext context) {
    return _medium(
      HeroAccordion(
        variant: HeroAccordionVariant.surface,
        expandedKeys: _expanded,
        onExpandedChanged: (Set<Object> keys) =>
            setState(() => _expanded = keys),
        children: <Widget>[
          HeroAccordionItem(
            id: '1',
            title: const Text('Using Plus/Minus Icon'),
            indicator: HeroAccordionIndicator(
              child: HeroIcon(
                _expanded.contains('1') ? HeroIcons.minus : HeroIcons.plus,
              ),
            ),
            child: const Text(
              'This accordion uses a plus icon that transforms when expanded. The icon automatically rotates 45 degrees to form an X.',
            ),
          ),
          const HeroAccordionItem(
            id: '2',
            title: Text('Using Caret Icon'),
            indicator: HeroAccordionIndicator(
              child: HeroIcon(HeroIcons.circleChevronDown),
            ),
            child: Text(
              'This item uses a caret icon for the indicator. The rotation animation is applied automatically.',
            ),
          ),
          const HeroAccordionItem(
            id: '3',
            title: Text('Using Arrow Icon'),
            indicator: HeroAccordionIndicator(
              child: HeroIcon(HeroIcons.chevronsDown),
            ),
            child: Text(
              'This item uses an arrow icon. Any icon you pass will receive the rotation animation when the item expands.',
            ),
          ),
        ],
      ),
    );
  }
}

const List<(String, List<(String, String)>)>
_faqCategories = <(String, List<(String, String)>)>[
  (
    'General',
    <(String, String)>[
      (
        'How do I place an order?',
        "Browse our products, add items to your cart, and proceed to checkout. You'll need to provide shipping and payment information to complete your purchase.",
      ),
      (
        'Can I modify or cancel my order?',
        "Yes, you can modify or cancel your order before it's shipped. Once your order is processed, you can't make changes.",
      ),
    ],
  ),
  (
    'Licensing',
    <(String, String)>[
      (
        'How do I purchase a license?',
        'You can purchase a license directly from our website. Select the license type that fits your needs and proceed to checkout.',
      ),
      (
        'What is the difference between a standard and a pro license?',
        'A standard license is for personal use or small projects, while a pro license includes commercial use rights and priority support.',
      ),
    ],
  ),
  (
    'Support',
    <(String, String)>[
      (
        'How do I get support?',
        'You can reach our support team through the contact form on our website, or email us directly at support@example.com.',
      ),
    ],
  ),
];

class _Faq extends StatelessWidget {
  const _Faq();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: <Widget>[
            Text(
              'Frequently Asked Questions',
              style: theme.typography
                  .style(HeroFontSize.xl2, weight: HeroTypography.bold)
                  .copyWith(color: theme.colors.foreground),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: theme.spacing(4)),
              child: Text(
                'Everything you need to know about licensing and usage.',
                style: theme.typography
                    .style(HeroFontSize.lg, weight: HeroTypography.medium)
                    .copyWith(color: theme.colors.muted),
              ),
            ),
          ],
        ),
        for (final (String title, List<(String, String)> items)
            in _faqCategories)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: <Widget>[
              Text(
                title,
                style: theme.typography
                    .style(HeroFontSize.base, weight: HeroTypography.medium)
                    .copyWith(color: theme.colors.muted),
              ),
              HeroAccordion(
                variant: HeroAccordionVariant.surface,
                children: <Widget>[
                  for (final (String question, String answer) in items)
                    HeroAccordionItem(
                      title: Text(question),
                      child: Text(answer),
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

const List<(String, String, String, String)>
_steps = <(String, String, String, String)>[
  (
    'Set Up Notifications',
    'Receive account activity updates',
    'Stay informed about your account activity with real-time notifications.',
    '$_assets/docs/3dicons/bell-small.png',
  ),
  (
    'Set up Browser Extension',
    'Connect your browser to your account',
    'Enhance your browsing experience by installing our official browser extension',
    '$_assets/docs/3dicons/compass-small.png',
  ),
  (
    'Mint Collectible',
    'Create your first collectible',
    'Begin your journey into the world of digital collectibles by creating your first NFT. ',
    '$_assets/docs/3dicons/mint-collective-small.png',
  ),
];

class _CustomAccordion extends StatelessWidget {
  const _CustomAccordion();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final Color muted = colors.muted;
    final Duration duration = theme.motion.resolve(context, HeroMotion.slower);
    return _medium(
      HeroAccordion(
        variant: HeroAccordionVariant.surface,
        borderRadius: theme.radii.xl2,
        children: <Widget>[
          for (final (String title, String subtitle, String body, String url)
              in _steps)
            HeroAccordionItem(
              children: <Widget>[
                HeroAccordionHeading(
                  child: HeroAccordionTrigger(
                    style: HeroAccordionTriggerStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        colors.surface,
                      ),
                    ),
                    indicator: HeroAccordionIndicator(
                      color: muted.withValues(alpha: muted.a * 0.5),
                    ),
                    builder:
                        (
                          BuildContext context,
                          HeroAccordionTriggerState state,
                        ) => Row(
                          spacing: theme.spacing(2),
                          children: <Widget>[
                            AnimatedScale(
                              scale: state.isHovered ? 1.2 : 1,
                              duration: duration,
                              curve: HeroMotion.easeOut,
                              child: AnimatedRotation(
                                turns: state.isHovered ? -10 / 360 : 0,
                                duration: duration,
                                curve: HeroMotion.easeOut,
                                child: Image.network(
                                  url,
                                  width: theme.spacing(11),
                                  height: theme.spacing(11),
                                  semanticLabel: title,
                                  errorBuilder:
                                      (
                                        BuildContext context,
                                        Object error,
                                        StackTrace? stack,
                                      ) => SizedBox.square(
                                        dimension: theme.spacing(11),
                                        child: const Center(
                                          child: HeroIcon(HeroIcons.bell),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(title),
                                  Text(
                                    subtitle,
                                    style: theme.typography
                                        .style(HeroFontSize.sm, lineHeight: 24)
                                        .copyWith(
                                          color: muted.withValues(
                                            alpha: muted.a * 0.8,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
                HeroAccordionPanel(
                  child: HeroAccordionBody(
                    style: TextStyle(
                      color: muted.withValues(alpha: muted.a * 0.8),
                    ),
                    child: Text(body),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
