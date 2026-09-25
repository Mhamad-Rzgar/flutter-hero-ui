import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// A stand-in for the photos of HeroUI's examples.
Widget _photo(HeroThemeData theme, {double? size, double? radius}) {
  Widget photo = DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[theme.colors.danger, theme.colors.warning],
      ),
    ),
  );
  if (radius != null) {
    photo = ClipPath(
      clipper: ShapeBorderClipper(shape: theme.shapeAll(radius)),
      child: photo,
    );
  }
  return size == null ? photo : SizedBox.square(dimension: size, child: photo);
}

void main() {
  heroGoldenTest(
    'variants',
    name: 'card_variants',
    size: const Size(400, 520),
    builder: (HeroThemeData theme) => SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final (HeroCardVariant variant, String description)
              in <(HeroCardVariant, String)>[
                (HeroCardVariant.transparent, 'Minimal prominence'),
                (HeroCardVariant.standard, 'Standard card (bg-surface)'),
                (HeroCardVariant.secondary, 'Medium (bg-surface-secondary)'),
                (HeroCardVariant.tertiary, 'Higher (bg-surface-tertiary)'),
              ])
            HeroCard(
              variant: variant,
              title: Text(variant.name),
              description: Text(description),
              content: const Text('The card content'),
            ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'usage with icon, header and footer link',
    name: 'card_usage',
    size: const Size(440, 200),
    builder: (HeroThemeData theme) => HeroCard(
      width: 400,
      children: <Widget>[
        HeroIcon(
          HeroIcons.circleDollar,
          size: theme.spacing(6),
          color: theme.colors.accent,
        ),
        const HeroCardHeader(
          children: <Widget>[
            HeroCardTitle.text('Become an Acme Creator!'),
            HeroCardDescription.text(
              'Visit the Acme Creator Hub to sign up today and start earning '
              'credits from your fans and followers.',
            ),
          ],
        ),
        const HeroCardFooter(
          children: <Widget>[
            HeroLink(children: <Widget>[Text('Creator Hub'), HeroLinkIcon()]),
          ],
        ),
      ],
    ),
  );

  heroGoldenTest(
    'horizontal, avatar and background layouts',
    name: 'card_layouts',
    size: const Size(480, 480),
    builder: (HeroThemeData theme) => SizedBox(
      width: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroCard(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            overlays: <Widget>[
              PositionedDirectional(
                end: theme.spacing(3),
                top: theme.spacing(3),
                child: const HeroCloseButton(),
              ),
            ],
            children: <Widget>[
              _photo(theme, size: 120, radius: theme.radii.xl2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    HeroCardHeader(
                      gap: theme.spacing(1),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: theme.spacing(8),
                          ),
                          child: const HeroCardTitle.text(
                            'Become an ACME Creator!',
                          ),
                        ),
                        const HeroCardDescription.text(
                          'Lorem ipsum dolor sit amet consectetur.',
                        ),
                      ],
                    ),
                    HeroCardFooter(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Only 10 spots',
                          style: HeroCardTitle.styleOf(theme),
                        ),
                        HeroButton(
                          size: HeroSize.sm,
                          onPressed: () {},
                          child: const Text('Apply Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: <Widget>[
              HeroCard(
                width: 200,
                gap: theme.spacing(2),
                children: <Widget>[
                  _photo(theme, size: 56, radius: theme.radii.xl2),
                  const HeroCardHeader(
                    children: <Widget>[
                      HeroCardTitle.text('Indie Hackers'),
                      HeroCardDescription.text('148 members'),
                    ],
                  ),
                  HeroCardFooter(
                    gap: theme.spacing(2),
                    children: <Widget>[
                      SizedBox.square(
                        dimension: theme.spacing(5),
                        child: HeroAvatar(
                          name: 'Martha',
                          fallback: Text(
                            'M',
                            style: TextStyle(
                              fontSize: HeroFontSize.xs.fontSize,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'By Martha',
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.foreground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: HeroCard(
                  constraints: const BoxConstraints(minHeight: 160),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  background: _photo(theme),
                  children: <Widget>[
                    const HeroCardHeader(
                      children: <Widget>[
                        HeroCardTitle.text('NEO'),
                        HeroCardDescription.text('Home Robot'),
                      ],
                    ),
                    HeroCardFooter(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Flexible(child: Text('Available soon')),
                        HeroButton(
                          size: HeroSize.sm,
                          variant: HeroButtonVariant.tertiary,
                          onPressed: () {},
                          child: const Text('Notify me'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'interactive states',
    name: 'card_states',
    size: const Size(400, 360),
    builder: (HeroThemeData theme) => SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          HeroCard(
            autofocus: true,
            href: Uri.parse('https://heroui.com'),
            title: const Text('Focused link card'),
            description: const Text('Shows the focus ring'),
          ),
          HeroCard(
            onPressed: () {},
            variant: HeroCardVariant.secondary,
            title: const Text('Pressable card'),
            description: const Text('Idle'),
          ),
          HeroCard(
            onPressed: () {},
            isDisabled: true,
            title: const Text('Disabled card'),
            description: const Text('Faded'),
          ),
        ],
      ),
    ),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      await tester.pump();
    },
  );

  heroGoldenTest(
    'custom styles',
    name: 'card_custom',
    size: const Size(440, 340),
    builder: (HeroThemeData theme) {
      final Color accent = theme.colors.accent;
      return HeroCard(
        width: 400,
        clipBehavior: Clip.antiAlias,
        style: HeroCardStyle(
          border: BorderSide(
            color: accent.withValues(alpha: theme.isDark ? 0.3 : 0.2),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.alphaBlend(
                accent.withValues(alpha: theme.isDark ? 0.2 : 0.12),
                theme.colors.surface,
              ),
              theme.colors.surface,
              theme.colors.surfaceSecondary,
            ],
          ),
        ),
        background: Stack(
          children: <Widget>[
            PositionedDirectional(
              top: -48,
              end: -48,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: SizedBox.square(
                  dimension: 160,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: const CircleBorder(),
                      color: accent.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        children: <Widget>[
          const HeroCardHeader(
            children: <Widget>[
              HeroCardTitle.text('Upgrade to Pro'),
              HeroCardDescription.text(
                'Unlock team workflows and insights built for growing '
                'products.',
              ),
            ],
          ),
          HeroCardContent(
            gap: theme.spacing(2),
            children: <Widget>[
              for (final String feature in <String>[
                'Unlimited projects and collaborators',
                'Priority support with 24h response',
              ])
                Row(
                  spacing: theme.spacing(2),
                  children: <Widget>[
                    HeroIcon(HeroIcons.check, size: 16, color: accent),
                    Text(
                      feature,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.muted,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          HeroCardFooter(
            gap: theme.spacing(2),
            children: <Widget>[
              Expanded(
                child: HeroButton(
                  fullWidth: true,
                  onPressed: () {},
                  child: const Text('Upgrade now'),
                ),
              ),
              Expanded(
                child: HeroButton(
                  fullWidth: true,
                  variant: HeroButtonVariant.secondary,
                  onPressed: () {},
                  child: const Text('Compare plans'),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
