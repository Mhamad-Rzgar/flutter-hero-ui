import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroCard`, reproducing
/// heroui.com/docs/components/card.
final ComponentDemo cardDemo = ComponentDemo(
  slug: 'card',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>[
        'standard',
        'secondary',
        'tertiary',
        'transparent',
      ]),
      ToggleControl('onPressed'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final HeroCardVariant variant = values.pick(
        'variant',
        HeroCardVariant.values,
      );
      final bool pressable = values.toggle('onPressed');
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: HeroCard(
          variant: variant,
          onPressed: pressable ? () {} : null,
          isDisabled: values.toggle('isDisabled'),
          title: const Text('Become an Acme Creator!'),
          description: const Text(
            'Visit the Acme Creator Hub to sign up today and start earning '
            'credits from your fans and followers.',
          ),
          content: Text('A ${variant.name} card.'),
        ),
      );
    },
    code: (PlaygroundValues values) {
      final String variant = values.option('variant');
      return '''
HeroCard(
${variant == 'standard' ? '' : '  variant: HeroCardVariant.$variant,\n'}${values.toggle('onPressed') ? '  onPressed: () {},\n' : ''}${values.toggle('isDisabled') ? '  isDisabled: true,\n' : ''}  title: const Text('Become an Acme Creator!'),
  description: const Text(
    'Visit the Acme Creator Hub to sign up today and start earning '
    'credits from your fans and followers.',
  ),
  content: const Text('A $variant card.'),
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _DefaultCard(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroCard(
  width: 400,
  children: <Widget>[
    HeroIcon(
      HeroIcons.circleDollar,
      size: theme.spacing(6),
      semanticLabel: 'Dollar sign icon',
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
    HeroCardFooter(
      children: <Widget>[
        HeroLink(
          href: Uri.parse('https://heroui.com'),
          target: HeroLinkTarget.blank,
          semanticsLabel: 'Go to Acme Creator Hub (opens in new tab)',
          children: const <Widget>[Text('Creator Hub'), HeroLinkIcon()],
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Variants',
      description:
          'Cards come in semantic variants that describe their prominence: '
          'transparent (nested cards), default (bg-surface), secondary '
          '(bg-surface-secondary) and tertiary (bg-surface-tertiary).',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          _VariantCard(
            variant: HeroCardVariant.transparent,
            title: 'Transparent',
            description: 'Minimal prominence with transparent background',
            content: 'Use for less important content or nested cards',
          ),
          _VariantCard(
            variant: HeroCardVariant.standard,
            title: 'Default',
            description: 'Standard card appearance (bg-surface)',
            content: 'The default card variant for most use cases',
          ),
          _VariantCard(
            variant: HeroCardVariant.secondary,
            title: 'Secondary',
            description: 'Medium prominence (bg-surface-secondary)',
            content: 'Use to draw moderate attention',
          ),
          _VariantCard(
            variant: HeroCardVariant.tertiary,
            title: 'Tertiary',
            description: 'Higher prominence (bg-surface-tertiary)',
            content: 'Use for primary or featured content',
          ),
        ],
      ),
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: <Widget>[
    HeroCard(
      width: 320,
      variant: HeroCardVariant.transparent,
      title: Text('Transparent'),
      description: Text('Minimal prominence with transparent background'),
      content: Text('Use for less important content or nested cards'),
    ),
    HeroCard(
      width: 320,
      title: Text('Default'),
      description: Text('Standard card appearance (bg-surface)'),
      content: Text('The default card variant for most use cases'),
    ),
    HeroCard(
      width: 320,
      variant: HeroCardVariant.secondary,
      title: Text('Secondary'),
      description: Text('Medium prominence (bg-surface-secondary)'),
      content: Text('Use to draw moderate attention'),
    ),
    HeroCard(
      width: 320,
      variant: HeroCardVariant.tertiary,
      title: Text('Tertiary'),
      description: Text('Higher prominence (bg-surface-tertiary)'),
      content: Text('Use for primary or featured content'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Horizontal Layout',
      description:
          'A row from the md breakpoint (768); below it the image sits above '
          'the text.',
      builder: (BuildContext context) =>
          const _CreatorBanner(rowBreakpoint: HeroBreakpoints.md),
      code: _horizontalCode,
    ),
    DemoExample(
      title: 'With Avatar',
      builder: (BuildContext context) => const Wrap(
        spacing: 16,
        runSpacing: 16,
        children: <Widget>[
          _CommunityCard(
            image: '$_docs/demo1.jpg',
            imageLabel: 'Indie Hackers community',
            title: 'Indie Hackers',
            members: '148 members',
            avatar: '$_avatars/red.jpg',
            avatarLabel: "Martha's avatar",
            fallback: 'IH',
            author: 'By Martha',
          ),
          _CommunityCard(
            image: '$_docs/demo2.jpg',
            imageLabel: 'AI Builders community',
            title: 'AI Builders',
            members: '362 members',
            avatar: '$_avatars/blue.jpg',
            avatarLabel: "John's avatar - blue themed",
            fallback: 'B',
            author: 'By John',
          ),
        ],
      ),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroCard(
  width: 200,
  gap: theme.spacing(2),
  children: <Widget>[
    ClipPath(
      clipper: ShapeBorderClipper(shape: theme.shapeAll(theme.radii.xl2)),
      child: Image.network(
        'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/docs/demo1.jpg',
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        semanticLabel: 'Indie Hackers community',
      ),
    ),
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
            src: 'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/avatars/red.jpg',
            semanticLabel: "Martha's avatar",
            fallback: Text('IH', style: TextStyle(fontSize: 12)),
          ),
        ),
        Text('By Martha', style: TextStyle(fontSize: 12)),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'With Images',
      description:
          'A responsive grid of image cards: one column on phones, two and '
          'three columns from the sm, md and lg breakpoints.',
      builder: (BuildContext context) => const _WithImages(),
      code: _withImagesCode,
    ),
    DemoExample(
      title: 'With Form',
      builder: (BuildContext context) => const _LoginCard(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroCard(
  constraints: const BoxConstraints(maxWidth: 448),
  children: <Widget>[
    const HeroCardHeader(
      children: <Widget>[
        HeroCardTitle.text('Login'),
        HeroCardDescription.text(
          'Enter your credentials to access your account',
        ),
      ],
    ),
    HeroForm(
      onSubmit: (Map<String, Object?> data) {
        // Form submitted successfully!
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing(4),
        children: <Widget>[
          HeroCardContent(
            gap: theme.spacing(4),
            children: const <Widget>[
              HeroTextField(
                name: 'email',
                type: HeroInputType.email,
                fullWidth: true,
                children: <Widget>[
                  HeroLabel.text('Email'),
                  HeroInput(
                    placeholder: 'email@example.com',
                    variant: HeroFieldVariant.secondary,
                  ),
                ],
              ),
              HeroTextField(
                name: 'password',
                type: HeroInputType.password,
                fullWidth: true,
                children: <Widget>[
                  HeroLabel.text('Password'),
                  HeroInput(
                    placeholder: '••••••••',
                    variant: HeroFieldVariant.secondary,
                  ),
                ],
              ),
            ],
          ),
          HeroCardFooter(
            direction: Axis.vertical,
            gap: theme.spacing(2),
            children: <Widget>[
              const HeroButton(
                type: HeroButtonType.submit,
                fullWidth: true,
                child: Text('Sign In'),
              ),
              // text-sm keeps the link's medium weight.
              DefaultTextStyle.merge(
                style: const TextStyle(fontSize: 14, height: 20 / 14),
                child: HeroLink(
                  href: Uri.parse('#'),
                  child: const Text('Forgot password?'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'An accent border, a diagonal gradient, blurred accent blobs and a '
          'tinted shadow.',
      builder: (BuildContext context) => const _UpgradeCard(),
      code: _customCode,
    ),
  ],
);

const String _cdn = 'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com';
const String _docs = '$_cdn/docs';
const String _avatars = '$_cdn/avatars';

TextStyle _text(
  HeroThemeData theme,
  HeroFontSize size, {
  FontWeight weight = HeroTypography.normal,
  double? lineHeight,
  Color? color,
}) => theme.typography
    .style(size, weight: weight, lineHeight: lineHeight)
    .copyWith(color: color ?? theme.colors.foreground);

/// A font size with its line height (`text-*`), inheriting everything else.
TextStyle _size(HeroFontSize size) =>
    TextStyle(fontSize: size.fontSize, height: size.lineHeight / size.fontSize);

bool _atLeast(BuildContext context, double breakpoint) =>
    (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= breakpoint;

/// A network photo of HeroUI's examples, with a neutral placeholder when it
/// cannot be loaded.
class _Photo extends StatelessWidget {
  const _Photo(
    this.url, {
    this.label,
    this.width,
    this.height,
    this.radius,
    this.scale = 1,
    this.light = false,
  });

  final String url;
  final String? label;
  final double? width;
  final double? height;
  final double? radius;
  final double scale;

  /// Whether the placeholder stays light in dark mode, for photos with dark
  /// text on top.
  final bool light;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    Widget image = Image.network(
      url,
      fit: BoxFit.cover,
      width: width,
      height: height,
      semanticLabel: label,
      excludeFromSemantics: label == null,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          ColoredBox(
            color: light
                ? Color.lerp(colors.white, colors.black, 0.1)!
                : colors.defaultColor,
            child: Center(
              child: HeroIcon(
                HeroIcons.picture,
                size: theme.spacing(6),
                color: light
                    ? colors.black.withValues(alpha: 0.4)
                    : colors.muted,
              ),
            ),
          ),
    );
    if (scale != 1) {
      image = Transform.scale(scale: scale, child: image);
    }
    image = SizedBox(width: width, height: height, child: image);
    final double? radius = this.radius;
    if (radius != null) {
      image = ClipPath(
        clipper: ShapeBorderClipper(shape: theme.shapeAll(radius)),
        child: image,
      );
    }
    return image;
  }
}

/// An avatar squeezed to a custom size (`size-4`, `size-5`, `size-14`).
class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar({
    required this.src,
    required this.size,
    required this.fallback,
    this.label,
    this.radius,
  });

  final String src;
  final double size;
  final String fallback;
  final String? label;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: HeroAvatar(
        src: src,
        radius: radius,
        semanticLabel: label,
        fallback: Text(fallback, style: _size(HeroFontSize.xs)),
      ),
    );
  }
}

class _DefaultCard extends StatelessWidget {
  const _DefaultCard();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroCard(
      width: 400,
      children: <Widget>[
        HeroIcon(
          HeroIcons.circleDollar,
          size: theme.spacing(6),
          semanticLabel: 'Dollar sign icon',
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
        HeroCardFooter(
          children: <Widget>[
            HeroLink(
              href: Uri.parse('https://heroui.com'),
              target: HeroLinkTarget.blank,
              semanticsLabel: 'Go to Acme Creator Hub (opens in new tab)',
              children: const <Widget>[Text('Creator Hub'), HeroLinkIcon()],
            ),
          ],
        ),
      ],
    );
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.variant,
    required this.title,
    required this.description,
    required this.content,
  });

  final HeroCardVariant variant;
  final String title;
  final String description;
  final String content;

  @override
  Widget build(BuildContext context) {
    return HeroCard(
      width: 320,
      variant: variant,
      title: Text(title),
      description: Text(description),
      content: Text(content),
    );
  }
}

/// The "Become an ACME Creator!" banner of the horizontal and image
/// examples: a column on phones, a row from [rowBreakpoint].
class _CreatorBanner extends StatelessWidget {
  const _CreatorBanner({required this.rowBreakpoint, this.minHeight});

  final double rowBreakpoint;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool sm = _atLeast(context, HeroBreakpoints.sm);
    final bool row = _atLeast(context, rowBreakpoint);
    final Widget image = _Photo(
      '$_docs/cherries.jpeg',
      label: 'Cherries',
      width: sm ? theme.spacing(30) : double.infinity,
      height: sm ? theme.spacing(30) : theme.spacing(35),
      radius: theme.radii.xl2,
      scale: 1.25,
    );
    final Widget spots = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Only 10 spots',
          style: _text(theme, HeroFontSize.sm, weight: HeroTypography.medium),
        ),
        Text(
          'Submission ends Oct 10.',
          style: _text(theme, HeroFontSize.xs, color: theme.colors.muted),
        ),
      ],
    );
    final Widget text = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: theme.spacing(3),
      children: <Widget>[
        HeroCardHeader(
          gap: theme.spacing(1),
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(end: theme.spacing(8)),
              child: const HeroCardTitle.text('Become an ACME Creator!'),
            ),
            const HeroCardDescription.text(
              'Lorem ipsum dolor sit amet consectetur. Sed arcu donec id '
              'aliquam dolor sed amet faucibus etiam.',
            ),
          ],
        ),
        HeroCardFooter(
          direction: sm ? Axis.horizontal : Axis.vertical,
          gap: theme.spacing(3),
          mainAxisAlignment: sm
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          crossAxisAlignment: sm
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: <Widget>[
            if (sm) Flexible(child: spots) else spots,
            HeroButton(
              fullWidth: !sm,
              onPressed: () {},
              child: const Text('Apply Now'),
            ),
          ],
        ),
      ],
    );
    return HeroCard(
      direction: row ? Axis.horizontal : Axis.vertical,
      crossAxisAlignment: row
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      overlays: <Widget>[
        PositionedDirectional(
          end: theme.spacing(3),
          top: theme.spacing(3),
          child: HeroCloseButton(
            semanticLabel: 'Close banner',
            onPressed: () {},
          ),
        ),
      ],
      children: <Widget>[
        image,
        if (row) Expanded(child: text) else text,
      ],
    );
  }
}

const String _horizontalCode = '''
final HeroThemeData theme = HeroTheme.of(context);
final double viewport = MediaQuery.sizeOf(context).width;
final bool sm = viewport >= HeroBreakpoints.sm;
final bool md = viewport >= HeroBreakpoints.md;

final Widget text = Column(
  mainAxisSize: MainAxisSize.min,
  // `mt-auto` on the footer.
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 12,
  children: <Widget>[
    HeroCardHeader(
      gap: 4,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 32),
          child: const HeroCardTitle.text('Become an ACME Creator!'),
        ),
        const HeroCardDescription.text(
          'Lorem ipsum dolor sit amet consectetur. Sed arcu donec id '
          'aliquam dolor sed amet faucibus etiam.',
        ),
      ],
    ),
    HeroCardFooter(
      direction: sm ? Axis.horizontal : Axis.vertical,
      gap: 12,
      mainAxisAlignment:
          sm ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
      crossAxisAlignment:
          sm ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[Text('Only 10 spots'), Text('Submission ends Oct 10.')],
        ),
        HeroButton(
          fullWidth: !sm,
          onPressed: () {},
          child: const Text('Apply Now'),
        ),
      ],
    ),
  ],
);

HeroCard(
  direction: md ? Axis.horizontal : Axis.vertical,
  crossAxisAlignment:
      md ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
  overlays: <Widget>[
    PositionedDirectional(
      end: 12,
      top: 12,
      child: HeroCloseButton(semanticLabel: 'Close banner', onPressed: () {}),
    ),
  ],
  children: <Widget>[
    ClipPath(
      clipper: ShapeBorderClipper(shape: theme.shapeAll(theme.radii.xl2)),
      child: SizedBox(
        width: sm ? 120 : double.infinity,
        height: sm ? 120 : 140,
        child: Transform.scale(
          scale: 1.25,
          child: Image.network(
            'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/docs/cherries.jpeg',
            fit: BoxFit.cover,
            semanticLabel: 'Cherries',
          ),
        ),
      ),
    ),
    if (md) Expanded(child: text) else text,
  ],
)''';

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({
    required this.image,
    required this.imageLabel,
    required this.title,
    required this.members,
    required this.avatar,
    required this.avatarLabel,
    required this.fallback,
    required this.author,
  });

  final String image;
  final String imageLabel;
  final String title;
  final String members;
  final String avatar;
  final String avatarLabel;
  final String fallback;
  final String author;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroCard(
      width: 200,
      gap: theme.spacing(2),
      children: <Widget>[
        _Photo(
          image,
          label: imageLabel,
          width: theme.spacing(14),
          height: theme.spacing(14),
          radius: theme.radii.xl2,
        ),
        HeroCardHeader(
          children: <Widget>[
            HeroCardTitle.text(title),
            HeroCardDescription.text(members),
          ],
        ),
        HeroCardFooter(
          gap: theme.spacing(2),
          children: <Widget>[
            _SmallAvatar(
              src: avatar,
              size: theme.spacing(5),
              label: avatarLabel,
              fallback: fallback,
            ),
            Flexible(child: Text(author, style: _text(theme, HeroFontSize.xs))),
          ],
        ),
      ],
    );
  }
}

class _WithImages extends StatelessWidget {
  const _WithImages();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double gap = theme.spacing(4);
    final bool sm = _atLeast(context, HeroBreakpoints.sm);
    final bool md = _atLeast(context, HeroBreakpoints.md);
    final bool lg = _atLeast(context, HeroBreakpoints.lg);

    Widget pair(Widget a, Widget b, {required bool row, int flexA = 1}) => row
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: gap,
              children: <Widget>[
                Expanded(flex: flexA, child: a),
                Expanded(child: b),
              ],
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap,
            children: <Widget>[a, b],
          );

    final Widget leftColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: <Widget>[
        const _PaymentCard(),
        pair(
          const _CommunityTile(
            image: '$_docs/demo1.jpg',
            imageLabel: 'Demo 1',
            fallback: 'JK',
            title: 'Indie Hackers',
            members: '148 members',
            avatar: '$_avatars/red.jpg',
            avatarLabel: 'John',
            author: 'By John',
          ),
          const _CommunityTile(
            image: '$_docs/demo2.jpg',
            imageLabel: 'Demo 2',
            fallback: 'AB',
            title: 'AI Builders',
            members: '362 members',
            avatar: '$_avatars/blue.jpg',
            avatarLabel: 'John',
            author: 'By Martha',
          ),
          row: sm,
        ),
      ],
    );

    final Widget events = Padding(
      padding: EdgeInsets.symmetric(vertical: md ? theme.spacing(2) : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: md ? 0 : theme.spacing(2),
        children: const <Widget>[
          _EventRow(
            image: '$_docs/robot1.jpeg',
            imageLabel: 'Futuristic Robot',
            title: 'Bridging the Future',
            time: 'Today, 6:30 PM',
          ),
          _EventRow(
            image: '$_docs/avocado.jpeg',
            imageLabel: 'Avocado',
            title: 'Avocado Hackathon',
            time: 'Wed, 4:30 PM',
          ),
          _EventRow(
            image: '$_docs/oranges.jpeg',
            imageLabel: 'Sound Electro event',
            title: 'Sound Electro | Beyond art',
            time: 'Fri, 8:00 PM',
          ),
        ],
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: theme.spacing(168)),
      child: Padding(
        padding: EdgeInsets.all(gap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: <Widget>[
            _CreatorBanner(
              rowBreakpoint: HeroBreakpoints.sm,
              minHeight: theme.spacing(38),
            ),
            pair(leftColumn, const _RobotTeaser(), row: lg),
            pair(const _RobotOffer(), events, row: md, flexA: 2),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool sm = _atLeast(context, HeroBreakpoints.sm);
    return HeroCard(
      overlays: <Widget>[
        PositionedDirectional(
          end: theme.spacing(3),
          top: theme.spacing(3),
          child: HeroCloseButton(
            semanticLabel: 'Close notification',
            onPressed: () {},
          ),
        ),
      ],
      children: <Widget>[
        HeroCardHeader(
          gap: theme.spacing(3),
          children: <Widget>[
            HeroIcon(
              HeroIcons.circleDollar,
              size: theme.spacing(8),
              semanticLabel: 'Dollar sign icon',
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: theme.spacing(1),
              children: <Widget>[
                Text(
                  'PAYMENT',
                  style: _text(
                    theme,
                    HeroFontSize.xs,
                    weight: HeroTypography.medium,
                    color: theme.colors.muted,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(end: theme.spacing(8)),
                  child: HeroCardTitle.text(
                    'You can now withdraw on crypto',
                    style: sm ? _size(HeroFontSize.base) : null,
                  ),
                ),
                HeroCardDescription.text(
                  'Add your wallet in settings to withdraw',
                  style: sm ? null : _size(HeroFontSize.xs),
                ),
              ],
            ),
          ],
        ),
        HeroCardFooter(
          children: <Widget>[
            HeroLink(
              href: Uri.parse('#'),
              semanticsLabel: 'Go to settings',
              children: const <Widget>[Text('Go to settings'), HeroLinkIcon()],
            ),
          ],
        ),
      ],
    );
  }
}

class _CommunityTile extends StatelessWidget {
  const _CommunityTile({
    required this.image,
    required this.imageLabel,
    required this.fallback,
    required this.title,
    required this.members,
    required this.avatar,
    required this.avatarLabel,
    required this.author,
  });

  final String image;
  final String imageLabel;
  final String fallback;
  final String title;
  final String members;
  final String avatar;
  final String avatarLabel;
  final String author;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle muted = _text(
      theme,
      HeroFontSize.xs,
      color: theme.colors.muted,
    );
    return HeroCard(
      gap: theme.spacing(2),
      children: <Widget>[
        HeroCardHeader(
          children: <Widget>[
            _SmallAvatar(
              src: image,
              size: theme.spacing(14),
              radius: theme.radii.xl,
              label: imageLabel,
              fallback: fallback,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: theme.spacing(1)),
          child: HeroCardContent(
            children: <Widget>[
              Text(
                title,
                style: _text(
                  theme,
                  HeroFontSize.sm,
                  weight: HeroTypography.medium,
                  lineHeight: theme.spacing(4),
                ),
              ),
              Text(members, style: muted),
            ],
          ),
        ),
        HeroCardFooter(
          gap: theme.spacing(2),
          children: <Widget>[
            _SmallAvatar(
              src: avatar,
              size: theme.spacing(4),
              label: avatarLabel,
              fallback: fallback,
            ),
            Flexible(child: Text(author, style: muted)),
          ],
        ),
      ],
    );
  }
}

/// A white "tertiary" button on a photo (`bg-white text-black`).
class _PhotoButton extends StatelessWidget {
  const _PhotoButton(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final HeroColors colors = HeroTheme.of(context).colors;
    return HeroButton(
      size: HeroSize.sm,
      variant: HeroButtonVariant.tertiary,
      onPressed: () {},
      style: HeroButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color?>(colors.white),
        foregroundColor: WidgetStatePropertyAll<Color?>(colors.black),
      ),
      child: Text(label),
    );
  }
}

class _RobotTeaser extends StatelessWidget {
  const _RobotTeaser();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final Color black = theme.colors.black;
    return HeroCard(
      constraints: BoxConstraints(minHeight: theme.spacing(50)),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      background: const _Photo('$_docs/neo2.jpeg', light: true),
      children: <Widget>[
        HeroCardHeader(
          children: <Widget>[
            HeroCardTitle.text(
              'NEO',
              style: _text(
                theme,
                HeroFontSize.xs,
                weight: HeroTypography.semibold,
                color: black.withValues(alpha: 0.7),
              ).copyWith(letterSpacing: HeroFontSize.xs.fontSize * 0.025),
            ),
            HeroCardDescription.text(
              'Home Robot',
              style: _text(
                theme,
                HeroFontSize.sm,
                weight: HeroTypography.medium,
                color: black.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        HeroCardFooter(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Available soon',
                    style: _text(
                      theme,
                      HeroFontSize.sm,
                      weight: HeroTypography.medium,
                      color: black,
                    ),
                  ),
                  Text(
                    'Get notified',
                    style: _text(
                      theme,
                      HeroFontSize.xs,
                      color: black.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const _PhotoButton('Notify me'),
          ],
        ),
      ],
    );
  }
}

class _RobotOffer extends StatelessWidget {
  const _RobotOffer();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final Color black = theme.colors.black;
    final bool sm = _atLeast(context, HeroBreakpoints.sm);
    final bool md = _atLeast(context, HeroBreakpoints.md);
    return HeroCard(
      height: theme.spacing(md ? 87.5 : (sm ? 75 : 62.5)),
      mainAxisAlignment: MainAxisAlignment.end,
      background: const _Photo('$_docs/neo1.jpeg', light: true),
      children: <Widget>[
        HeroCardFooter(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'NEO',
                  style: _text(
                    theme,
                    sm ? HeroFontSize.lg : HeroFontSize.base,
                    weight: HeroTypography.medium,
                    color: black,
                  ),
                ),
                Text(
                  r'$499/m',
                  style: _text(
                    theme,
                    sm ? HeroFontSize.sm : HeroFontSize.xs,
                    weight: HeroTypography.medium,
                    color: black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const _PhotoButton('Get now'),
          ],
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.image,
    required this.imageLabel,
    required this.title,
    required this.time,
  });

  final String image;
  final String imageLabel;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double size = theme.spacing(
      _atLeast(context, HeroBreakpoints.sm) ? 20 : 16,
    );
    return HeroCard(
      variant: HeroCardVariant.transparent,
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: EdgeInsets.all(theme.spacing(1)),
      children: <Widget>[
        _Photo(
          image,
          label: imageLabel,
          width: size,
          height: size,
          radius: theme.radii.xl,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: theme.spacing(1),
            children: <Widget>[
              HeroCardTitle.text(title),
              HeroCardDescription.text(time, style: _size(HeroFontSize.xs)),
            ],
          ),
        ),
      ],
    );
  }
}

const String _withImagesCode = r'''
// Excerpt: the image-background card and a transparent row card. See the
// gallery source for the full responsive grid.
final HeroThemeData theme = HeroTheme.of(context);
final Color black = theme.colors.black;

HeroCard(
  constraints: const BoxConstraints(minHeight: 200),
  // Header at the top, footer at the bottom (`mt-auto`).
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  background: Image.network(
    'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/docs/neo2.jpeg',
    fit: BoxFit.cover,
  ),
  children: <Widget>[
    HeroCardHeader(
      children: <Widget>[
        HeroCardTitle.text(
          'NEO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: black.withValues(alpha: 0.7),
          ),
        ),
        HeroCardDescription.text(
          'Home Robot',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: black.withValues(alpha: 0.5),
          ),
        ),
      ],
    ),
    HeroCardFooter(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[Text('Available soon'), Text('Get notified')],
        ),
        HeroButton(
          size: HeroSize.sm,
          variant: HeroButtonVariant.tertiary,
          onPressed: () {},
          style: HeroButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color?>(theme.colors.white),
            foregroundColor: WidgetStatePropertyAll<Color?>(black),
          ),
          child: const Text('Notify me'),
        ),
      ],
    ),
  ],
)

HeroCard(
  variant: HeroCardVariant.transparent,
  direction: Axis.horizontal,
  crossAxisAlignment: CrossAxisAlignment.center,
  padding: const EdgeInsets.all(4),
  children: <Widget>[
    ClipPath(
      clipper: ShapeBorderClipper(shape: theme.shapeAll(theme.radii.xl)),
      child: Image.network(
        'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/docs/robot1.jpeg',
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        semanticLabel: 'Futuristic Robot',
      ),
    ),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: <Widget>[
          const HeroCardTitle.text('Bridging the Future'),
          HeroCardDescription.text(
            'Today, 6:30 PM',
            style: const TextStyle(fontSize: 12, height: 16 / 12),
          ),
        ],
      ),
    ),
  ],
)''';

class _LoginCard extends StatefulWidget {
  const _LoginCard();

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.spacing(3),
      children: <Widget>[
        HeroCard(
          constraints: BoxConstraints(maxWidth: theme.spacing(112)),
          children: <Widget>[
            const HeroCardHeader(
              children: <Widget>[
                HeroCardTitle.text('Login'),
                HeroCardDescription.text(
                  'Enter your credentials to access your account',
                ),
              ],
            ),
            HeroForm(
              onSubmit: (Map<String, Object?> data) =>
                  setState(() => _submitted = true),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: theme.spacing(4),
                children: <Widget>[
                  HeroCardContent(
                    gap: theme.spacing(4),
                    children: const <Widget>[
                      HeroTextField(
                        name: 'email',
                        type: HeroInputType.email,
                        fullWidth: true,
                        children: <Widget>[
                          HeroLabel.text('Email'),
                          HeroInput(
                            placeholder: 'email@example.com',
                            variant: HeroFieldVariant.secondary,
                          ),
                        ],
                      ),
                      HeroTextField(
                        name: 'password',
                        type: HeroInputType.password,
                        fullWidth: true,
                        children: <Widget>[
                          HeroLabel.text('Password'),
                          HeroInput(
                            placeholder: '••••••••',
                            variant: HeroFieldVariant.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  HeroCardFooter(
                    direction: Axis.vertical,
                    gap: theme.spacing(2),
                    children: <Widget>[
                      const HeroButton(
                        type: HeroButtonType.submit,
                        fullWidth: true,
                        child: Text('Sign In'),
                      ),
                      // text-sm keeps the link's medium weight.
                      DefaultTextStyle.merge(
                        style: _size(HeroFontSize.sm),
                        child: HeroLink(
                          href: Uri.parse('#'),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_submitted)
          Text(
            'Form submitted successfully!',
            style: _text(theme, HeroFontSize.sm, color: theme.colors.muted),
          ),
      ],
    );
  }
}

const List<String> _proFeatures = <String>[
  'Unlimited projects and collaborators',
  'Priority support with 24h response',
  'Advanced analytics and exports',
];

/// A blurred accent circle (`rounded-full bg-accent/* blur-*`).
class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color, required this.blur});

  final double size;
  final Color color;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      // CSS `blur(r)` is a Gaussian with a standard deviation of r.
      imageFilter: ImageFilter.blur(
        sigmaX: blur,
        sigmaY: blur,
        tileMode: TileMode.decal,
      ),
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: color,
            shape: const CircleBorder(),
          ),
        ),
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final bool dark = theme.isDark;
    final Color accent = colors.accent;
    final Color accentText = dark ? colors.accentSoftForeground : accent;
    final bool sm = _atLeast(context, HeroBreakpoints.sm);
    final Widget upgrade = HeroButton(
      fullWidth: true,
      onPressed: () {},
      style: HeroButtonStyle(
        // shadow-md shadow-accent/20
        shadows: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: -2,
          ),
        ],
      ),
      child: const Text('Upgrade now'),
    );
    final Widget compare = HeroButton(
      fullWidth: true,
      variant: HeroButtonVariant.secondary,
      onPressed: () {},
      child: const Text('Compare plans'),
    );
    final Color shadow = accent.withValues(alpha: dark ? 0.05 : 0.1);
    return HeroCard(
      constraints: BoxConstraints(maxWidth: theme.spacing(112)),
      clipBehavior: Clip.antiAlias,
      style: HeroCardStyle(
        border: BorderSide(
          color: accent.withValues(alpha: dark ? 0.3 : 0.2),
          width: theme.borderWidth,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.alphaBlend(
              accent.withValues(alpha: dark ? 0.2 : 0.12),
              colors.surface,
            ),
            colors.surface,
            dark
                ? Color.alphaBlend(
                    accent.withValues(alpha: 0.08),
                    colors.surface,
                  )
                : colors.surfaceSecondary,
          ],
        ),
        // shadow-lg shadow-accent/10
        shadows: <BoxShadow>[
          BoxShadow(
            color: shadow,
            offset: const Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: shadow,
            offset: const Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
        ],
      ),
      background: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            top: -theme.spacing(12),
            right: -theme.spacing(12),
            child: _Blob(
              size: theme.spacing(40),
              color: accent.withValues(alpha: dark ? 0.3 : 0.2),
              blur: theme.spacing(16),
            ),
          ),
          Positioned(
            bottom: -theme.spacing(8),
            left: -theme.spacing(8),
            child: _Blob(
              size: theme.spacing(28),
              color: accent.withValues(alpha: dark ? 0.2 : 0.1),
              blur: theme.spacing(10),
            ),
          ),
        ],
      ),
      children: <Widget>[
        HeroCardHeader(
          gap: theme.spacing(3),
          children: <Widget>[
            DecoratedBox(
              decoration: ShapeDecoration(
                color: accent.withValues(alpha: dark ? 0.25 : 0.15),
                shape: const StadiumBorder(),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing(2.5),
                  vertical: theme.spacing(0.5),
                ),
                child: Text(
                  'Recommended',
                  style: _text(
                    theme,
                    HeroFontSize.xs,
                    weight: HeroTypography.medium,
                    color: accentText,
                  ).copyWith(letterSpacing: HeroFontSize.xs.fontSize * 0.025),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: theme.spacing(3),
              children: <Widget>[
                SizedBox.square(
                  dimension: theme.spacing(10),
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: accent.withValues(alpha: dark ? 0.2 : 0.15),
                      shape: theme.shapeAll(theme.radii.xl),
                    ),
                    child: Center(
                      child: HeroIcon(
                        HeroIcons.star,
                        size: theme.spacing(5),
                        color: accentText,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: theme.spacing(1),
                    children: const <Widget>[
                      HeroCardTitle.text('Upgrade to Pro'),
                      HeroCardDescription.text(
                        'Unlock team workflows and insights built for '
                        'growing products.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        HeroCardContent(
          gap: theme.spacing(2),
          children: <Widget>[
            for (final String feature in _proFeatures)
              Row(
                spacing: theme.spacing(2),
                children: <Widget>[
                  HeroIcon(
                    HeroIcons.check,
                    size: theme.spacing(4),
                    color: accent,
                  ),
                  Flexible(
                    child: Text(
                      feature,
                      style: _text(theme, HeroFontSize.sm, color: colors.muted),
                    ),
                  ),
                ],
              ),
          ],
        ),
        HeroCardFooter(
          direction: sm ? Axis.horizontal : Axis.vertical,
          gap: theme.spacing(2),
          children: sm
              ? <Widget>[Expanded(child: upgrade), Expanded(child: compare)]
              : <Widget>[upgrade, compare],
        ),
      ],
    );
  }
}

const String _customCode = r'''
final HeroThemeData theme = HeroTheme.of(context);
final HeroColors colors = theme.colors;
final Color accent = colors.accent;

HeroCard(
  constraints: const BoxConstraints(maxWidth: 448),
  clipBehavior: Clip.antiAlias,
  style: HeroCardStyle(
    border: BorderSide(color: accent.withValues(alpha: 0.2)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color.alphaBlend(accent.withValues(alpha: 0.12), colors.surface),
        colors.surface,
        colors.surfaceSecondary,
      ],
    ),
    shadows: <BoxShadow>[
      BoxShadow(
        color: accent.withValues(alpha: 0.1),
        offset: const Offset(0, 10),
        blurRadius: 15,
        spreadRadius: -3,
      ),
    ],
  ),
  // Blurred accent blobs behind the content.
  background: Stack(
    clipBehavior: Clip.none,
    children: <Widget>[
      Positioned(
        top: -48,
        right: -48,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
          child: Container(
            width: 160,
            height: 160,
            decoration: ShapeDecoration(
              color: accent.withValues(alpha: 0.2),
              shape: const CircleBorder(),
            ),
          ),
        ),
      ),
    ],
  ),
  children: <Widget>[
    HeroCardHeader(
      gap: 12,
      children: <Widget>[
        recommendedPill,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: <Widget>[
            starTile,
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: <Widget>[
                  HeroCardTitle.text('Upgrade to Pro'),
                  HeroCardDescription.text(
                    'Unlock team workflows and insights built for growing '
                    'products.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
    HeroCardContent(
      gap: 8,
      children: <Widget>[
        for (final String feature in features)
          Row(
            spacing: 8,
            children: <Widget>[
              HeroIcon(HeroIcons.check, size: 16, color: accent),
              Text(feature),
            ],
          ),
      ],
    ),
    HeroCardFooter(
      gap: 8,
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
)''';
