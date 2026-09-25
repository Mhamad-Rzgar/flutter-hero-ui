import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _content(HeroThemeData theme, String name) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 4,
  children: <Widget>[
    // Inherits the surface foreground.
    Text(
      'Surface Content',
      style: TextStyle(
        fontSize: HeroFontSize.base.fontSize,
        fontWeight: HeroTypography.semibold,
      ),
    ),
    Text(
      'The $name surface variant.',
      style: theme.typography.sm.copyWith(color: theme.colors.muted),
    ),
  ],
);

void main() {
  heroGoldenTest(
    'variants',
    name: 'variants',
    size: const Size(320, 460),
    builder: (HeroThemeData theme) => SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          for (final HeroSurfaceVariant variant in HeroSurfaceVariant.values)
            HeroSurface(
              variant: variant,
              borderRadius: BorderRadius.circular(theme.radii.xl3),
              padding: EdgeInsets.all(theme.spacing(5)),
              border: variant == HeroSurfaceVariant.transparent
                  ? BorderSide(
                      color: theme.colors.border,
                      width: theme.borderWidth,
                    )
                  : null,
              child: _content(theme, variant.name),
            ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'with form components and custom styles',
    name: 'custom',
    size: const Size(360, 360),
    builder: (HeroThemeData theme) => SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          HeroSurface(
            borderRadius: BorderRadius.circular(theme.radii.xl3),
            padding: EdgeInsets.all(theme.spacing(6)),
            child: const Column(
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
          HeroSurface(
            borderRadius: BorderRadius.circular(theme.radii.xl),
            border: BorderSide(
              color: theme.colors.accent.withValues(alpha: 0.15),
              width: theme.borderWidth,
            ),
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
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
