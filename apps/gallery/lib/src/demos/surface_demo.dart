import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroSurface`, reproducing
/// heroui.com/docs/components/surface.
final ComponentDemo surfaceDemo = ComponentDemo(
  slug: 'surface',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>[
        'standard',
        'secondary',
        'tertiary',
        'transparent',
      ]),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final HeroSurfaceVariant variant = values.pick(
        'variant',
        HeroSurfaceVariant.values,
      );
      return _SurfaceCard(
        variant: variant,
        text: 'This is a ${variant.name} surface variant.',
      );
    },
    code: (PlaygroundValues values) =>
        '''
HeroSurface(
  variant: HeroSurfaceVariant.${values.option('variant')},
  constraints: const BoxConstraints(minWidth: 320),
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: content,
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _SurfaceCard(
        variant: HeroSurfaceVariant.standard,
        text: 'This is a default surface variant. It uses bg-surface styling.',
      ),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroSurface(
  constraints: const BoxConstraints(minWidth: 320),
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: <Widget>[
      Text(
        'Surface Content',
        style: theme.typography
            .style(HeroFontSize.base, weight: HeroTypography.semibold)
            .copyWith(color: theme.colors.foreground),
      ),
      Text(
        'This is a default surface variant. It uses bg-surface styling.',
        style: theme.typography.sm.copyWith(color: theme.colors.muted),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Variants',
      description:
          'default (bg-surface), secondary (bg-surface-secondary), tertiary '
          '(bg-surface-tertiary) and transparent.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        Widget captioned(String caption, Widget surface) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            Text(
              caption,
              style: theme.typography
                  .style(HeroFontSize.sm, weight: HeroTypography.medium)
                  .copyWith(color: theme.colors.muted),
            ),
            surface,
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            captioned(
              'Default',
              const _SurfaceCard(
                variant: HeroSurfaceVariant.standard,
                text:
                    'This is a default surface variant. It uses bg-surface '
                    'styling.',
              ),
            ),
            captioned(
              'Secondary',
              const _SurfaceCard(
                variant: HeroSurfaceVariant.secondary,
                text:
                    'This is a secondary surface variant. It uses '
                    'bg-surface-secondary styling.',
              ),
            ),
            captioned(
              'Tertiary',
              const _SurfaceCard(
                variant: HeroSurfaceVariant.tertiary,
                text:
                    'This is a tertiary surface variant. It uses '
                    'bg-surface-tertiary styling.',
              ),
            ),
            captioned(
              'Transparent',
              const _SurfaceCard(
                variant: HeroSurfaceVariant.transparent,
                bordered: true,
                text:
                    'This is a transparent surface variant. It has no '
                    'background, suitable for overlays and cards with custom '
                    'backgrounds.',
              ),
            ),
          ],
        );
      },
      code: '''
HeroSurface(variant: HeroSurfaceVariant.standard, ...)
HeroSurface(variant: HeroSurfaceVariant.secondary, ...)
HeroSurface(variant: HeroSurfaceVariant.tertiary, ...)
HeroSurface(
  variant: HeroSurfaceVariant.transparent,
  border: BorderSide(color: theme.colors.border, width: theme.borderWidth),
  constraints: const BoxConstraints(minWidth: 320),
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: content,
)''',
    ),
    DemoExample(
      title: 'With Form Components',
      description: 'Use the secondary variant of form fields on surfaces.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroSurface(
          constraints: const BoxConstraints(minWidth: 320),
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          padding: EdgeInsets.all(theme.spacing(6)),
          child: const IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: <Widget>[
                HeroInput(
                  placeholder: 'Input with secondary variant',
                  variant: HeroFieldVariant.secondary,
                ),
                HeroTextArea(
                  placeholder: 'TextArea with secondary variant',
                  variant: HeroFieldVariant.secondary,
                ),
              ],
            ),
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroSurface(
  constraints: const BoxConstraints(minWidth: 320),
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const IntrinsicWidth(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        HeroInput(
          placeholder: 'Input with secondary variant',
          variant: HeroFieldVariant.secondary,
        ),
        HeroTextArea(
          placeholder: 'TextArea with secondary variant',
          variant: HeroFieldVariant.secondary,
        ),
      ],
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      description: 'A surface with an accent border and a gradient.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: theme.spacing(96)),
          child: HeroSurface(
            borderRadius: BorderRadius.circular(theme.radii.xl),
            border: BorderSide(
              color: theme.colors.accent.withValues(alpha: 0.15),
              width: theme.borderWidth,
            ),
            gradient: _billingGradient(theme),
            padding: EdgeInsets.all(theme.spacing(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Billing overview',
                  style: theme.typography
                      .style(HeroFontSize.sm, weight: HeroTypography.semibold)
                      .copyWith(color: theme.colors.foreground),
                ),
                Text(
                  'View invoices and payment methods in one place.',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.muted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: theme.spacing(96)),
  child: HeroSurface(
    borderRadius: BorderRadius.circular(theme.radii.xl),
    border: BorderSide(
      color: theme.colors.accent.withValues(alpha: 0.15),
      width: theme.borderWidth,
    ),
    // bg-linear-to-br from-accent/8 via-surface to-surface-secondary
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color.alphaBlend(
          theme.colors.accent.withValues(alpha: 0.08),
          theme.colors.surface,
        ),
        theme.colors.surface,
        theme.colors.surfaceSecondary,
      ],
    ),
    padding: EdgeInsets.all(theme.spacing(4)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Billing overview',
          style: theme.typography
              .style(HeroFontSize.sm, weight: HeroTypography.semibold)
              .copyWith(color: theme.colors.foreground),
        ),
        Text(
          'View invoices and payment methods in one place.',
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
      ],
    ),
  ),
)''',
    ),
  ],
);

LinearGradient _billingGradient(HeroThemeData theme) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[
    Color.alphaBlend(
      theme.colors.accent.withValues(alpha: 0.08),
      theme.colors.surface,
    ),
    theme.colors.surface,
    theme.colors.surfaceSecondary,
  ],
);

/// The rounded, padded surface of HeroUI's surface examples.
class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.variant,
    required this.text,
    this.bordered = false,
  });

  final HeroSurfaceVariant variant;
  final String text;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroSurface(
      variant: variant,
      constraints: const BoxConstraints(minWidth: 320),
      borderRadius: BorderRadius.circular(theme.radii.xl3),
      padding: EdgeInsets.all(theme.spacing(6)),
      border: bordered
          ? BorderSide(color: theme.colors.border, width: theme.borderWidth)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          Text(
            'Surface Content',
            style: theme.typography
                .style(HeroFontSize.base, weight: HeroTypography.semibold)
                .copyWith(color: theme.colors.foreground),
          ),
          Text(
            text,
            style: theme.typography.sm.copyWith(color: theme.colors.muted),
          ),
        ],
      ),
    );
  }
}
