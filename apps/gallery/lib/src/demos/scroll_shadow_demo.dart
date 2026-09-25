import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroScrollShadow`, reproducing
/// heroui.com/docs/components/scroll-shadow.
final ComponentDemo scrollShadowDemo = ComponentDemo(
  slug: 'scroll-shadow',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('orientation', <String>['vertical', 'horizontal']),
      OptionsControl('size', <String>['40', '80']),
      OptionsControl('visibility', <String>[
        'auto',
        'both',
        'top',
        'bottom',
        'left',
        'right',
        'none',
      ]),
      ToggleControl('hideScrollBar'),
      ToggleControl('isEnabled', initial: true),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final Axis orientation = values.pick('orientation', Axis.values);
      final HeroScrollShadow shadow = orientation == Axis.vertical
          ? HeroScrollShadow(
              size: double.parse(values.option('size')),
              visibility: values.pick(
                'visibility',
                HeroScrollShadowVisibility.values,
              ),
              hideScrollBar: values.toggle('hideScrollBar'),
              isEnabled: values.toggle('isEnabled'),
              constraints: const BoxConstraints(maxHeight: 240),
              padding: const EdgeInsets.all(16),
              child: const _Paragraphs(),
            )
          : HeroScrollShadow(
              orientation: Axis.horizontal,
              size: double.parse(values.option('size')),
              visibility: values.pick(
                'visibility',
                HeroScrollShadowVisibility.values,
              ),
              hideScrollBar: values.toggle('hideScrollBar'),
              isEnabled: values.toggle('isEnabled'),
              padding: const EdgeInsets.all(16),
              child: const _EventRow(),
            );
      return _Narrow(child: shadow);
    },
    code: (PlaygroundValues values) {
      final bool horizontal = values.option('orientation') == 'horizontal';
      final String size = values.option('size');
      final String visibility = values.option('visibility');
      return '''
HeroScrollShadow(
${horizontal ? '  orientation: Axis.horizontal,\n' : ''}${size == '40' ? '' : '  size: $size,\n'}${visibility == 'auto' ? '' : '  visibility: HeroScrollShadowVisibility.$visibility,\n'}${values.toggle('hideScrollBar') ? '  hideScrollBar: true,\n' : ''}${values.toggle('isEnabled') ? '' : '  isEnabled: false,\n'}${horizontal ? '' : '  constraints: const BoxConstraints(maxHeight: 240),\n'}  padding: const EdgeInsets.all(16),
  child: content,
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _Narrow(
        child: HeroScrollShadow(
          constraints: BoxConstraints(maxHeight: 240),
          padding: EdgeInsets.all(16),
          child: _Paragraphs(),
        ),
      ),
      code: _defaultCode,
    ),
    DemoExample(
      title: 'Orientation',
      builder: (BuildContext context) => const _Orientation(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);

// Vertical
HeroCard(
  padding: EdgeInsets.zero,
  children: const <Widget>[
    HeroScrollShadow(
      constraints: BoxConstraints(maxHeight: 240),
      padding: EdgeInsets.all(16),
      child: paragraphs,
    ),
  ],
)

// Horizontal
HeroCard(
  padding: EdgeInsets.zero,
  children: <Widget>[
    HeroScrollShadow(
      orientation: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 16,
        children: <Widget>[
          for (int i = 0; i < 10; i++)
            HeroCard(
              variant: HeroCardVariant.transparent,
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              constraints: const BoxConstraints(minWidth: 200),
              padding: const EdgeInsets.all(4),
              children: <Widget>[
                ClipPath(
                  clipper: ShapeBorderClipper(
                    shape: theme.shapeAll(theme.radii.xl),
                  ),
                  child: Image.network(images[i % 3],
                      width: 64, height: 64, fit: BoxFit.cover),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: <Widget>[
                      const HeroCardTitle.text('Bridging the Future'),
                      HeroCardDescription.text(
                        'Today, 6:30 PM',
                        style: theme.typography.xs,
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
)''',
    ),
    DemoExample(
      title: 'Shadow Size',
      builder: (BuildContext context) => const _Narrow(
        child: HeroScrollShadow(
          size: 80,
          constraints: BoxConstraints(maxHeight: 240),
          padding: EdgeInsets.all(16),
          child: _Paragraphs(),
        ),
      ),
      code: '''
const HeroScrollShadow(
  size: 80,
  constraints: BoxConstraints(maxHeight: 240),
  padding: EdgeInsets.all(16),
  child: paragraphs,
)''',
    ),
    DemoExample(
      title: 'With Card',
      builder: (BuildContext context) => const _TermsCard(),
      code: '''
HeroCard(
  constraints: const BoxConstraints(maxWidth: 400),
  children: <Widget>[
    const HeroCardHeader(
      children: <Widget>[
        HeroCardTitle.text('Terms and Conditions'),
        HeroCardDescription.text('Please review before proceeding'),
      ],
    ),
    const HeroCardContent(
      children: <Widget>[
        HeroScrollShadow(
          height: 300,
          size: 80,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: paragraphs,
        ),
      ],
    ),
    Padding(
      padding: const EdgeInsets.only(top: 16),
      child: HeroCardFooter(
        gap: 8,
        children: <Widget>[
          Expanded(
            child: HeroButton(
              fullWidth: true,
              variant: HeroButtonVariant.secondary,
              onPressed: () {},
              child: const Text('Cancel'),
            ),
          ),
          Expanded(
            child: HeroButton(
              fullWidth: true,
              onPressed: () {},
              child: const Text('Accept'),
            ),
          ),
        ],
      ),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Hide Scroll Bar',
      builder: (BuildContext context) => const _Narrow(
        child: HeroScrollShadow(
          hideScrollBar: true,
          constraints: BoxConstraints(maxHeight: 240),
          padding: EdgeInsets.all(16),
          child: _Paragraphs(),
        ),
      ),
      code: '''
const HeroScrollShadow(
  hideScrollBar: true,
  constraints: BoxConstraints(maxHeight: 240),
  padding: EdgeInsets.all(16),
  child: paragraphs,
)''',
    ),
    DemoExample(
      title: 'Visibility Change',
      builder: (BuildContext context) => const _VisibilityChange(),
      code: r'''
HeroScrollShadowVisibility verticalState = HeroScrollShadowVisibility.none;

Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: 8,
  children: <Widget>[
    StatusBox(text: 'Vertical Shadow State: ${verticalState.name}'),
    HeroScrollShadow(
      constraints: const BoxConstraints(maxHeight: 240),
      padding: const EdgeInsets.all(16),
      onVisibilityChanged: (HeroScrollShadowVisibility visibility) =>
          setState(() => verticalState = visibility),
      child: paragraphs,
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A rounded, bordered box with a vertical gradient. The border and '
          'background fade with the content, as in HeroUI.',
      builder: (BuildContext context) => const _Changelog(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final bool dark = theme.isDark;

HeroScrollShadow(
  hideScrollBar: true,
  size: 48,
  constraints: const BoxConstraints(maxHeight: 192),
  padding: const EdgeInsets.all(16),
  decoration: ShapeDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: dark
          ? const <Color>[Color(0xCC171717), Color(0xFF171717)]
          : const <Color>[Color(0xE6FAFAFA), Color(0xFFFFFFFF)],
    ),
    shape: theme.shapeAll(
      theme.radii.xl,
      side: BorderSide(
        color: theme.colors.border.withValues(alpha: 0.8),
        width: theme.borderWidth,
      ),
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: <Widget>[
      for (final String entry in entries)
        Text(
          entry,
          style: TextStyle(
            fontSize: 14,
            height: 1.625,
            color: dark ? const Color(0xFFA1A1A1) : const Color(0xFF525252),
          ),
        ),
    ],
  ),
)''',
    ),
  ],
);

const String _lorem =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam '
    'pulvinar risus non risus hendrerit venenatis. Pellentesque sit amet '
    'hendrerit risus, sed porttitor quam. Morbi accumsan cursus enim, sed '
    'ultricies sapien.';

const String _defaultCode = '''
HeroScrollShadow(
  constraints: const BoxConstraints(maxHeight: 240),
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: <Widget>[
      for (int i = 0; i < 10; i++)
        const Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam '
          'pulvinar risus non risus hendrerit venenatis. Pellentesque sit amet '
          'hendrerit risus, sed porttitor quam. Morbi accumsan cursus enim, sed '
          'ultricies sapien.',
        ),
    ],
  ),
)''';

const String _docs =
    'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/docs';

const List<String> _images = <String>[
  '$_docs/robot1.jpeg',
  '$_docs/avocado.jpeg',
  '$_docs/oranges.jpeg',
];

bool _sm(BuildContext context) =>
    (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= HeroBreakpoints.sm;

/// `w-full sm:max-w-sm`: full width on phones, at most 384 from `sm`.
class _Narrow extends StatelessWidget {
  const _Narrow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: _sm(context)
            ? HeroTheme.of(context).spacing(96)
            : double.infinity,
      ),
      child: child,
    );
  }
}

/// Ten lorem paragraphs, 16 apart (`space-y-4`).
class _Paragraphs extends StatelessWidget {
  const _Paragraphs();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: HeroTheme.of(context).spacing(4),
      children: <Widget>[for (int i = 0; i < 10; i++) const Text(_lorem)],
    );
  }
}

/// A network photo with a neutral placeholder when it cannot be loaded.
class _Photo extends StatelessWidget {
  const _Photo(this.url, {required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return ClipPath(
      clipper: ShapeBorderClipper(shape: theme.shapeAll(theme.radii.xl)),
      child: SizedBox.square(
        dimension: size,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          semanticLabel: 'Lorem Card',
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stack) =>
                  ColoredBox(
                    color: theme.colors.defaultColor,
                    child: Center(
                      child: HeroIcon(
                        HeroIcons.picture,
                        size: theme.spacing(6),
                        color: theme.colors.muted,
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}

/// Ten transparent event cards in a row (`flex flex-row gap-4`).
class _EventRow extends StatelessWidget {
  const _EventRow();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double image = theme.spacing(_sm(context) ? 20 : 16);
    return Row(
      spacing: theme.spacing(4),
      children: <Widget>[
        for (int i = 0; i < 10; i++)
          HeroCard(
            variant: HeroCardVariant.transparent,
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            constraints: BoxConstraints(minWidth: theme.spacing(50)),
            padding: EdgeInsets.all(theme.spacing(1)),
            children: <Widget>[
              _Photo(_images[i % _images.length], size: image),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: theme.spacing(1),
                  children: <Widget>[
                    const HeroCardTitle.text('Bridging the Future'),
                    HeroCardDescription.text(
                      'Today, 6:30 PM',
                      style: TextStyle(
                        fontSize: HeroFontSize.xs.fontSize,
                        height:
                            HeroFontSize.xs.lineHeight /
                            HeroFontSize.xs.fontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing(2)),
      child: Text(
        text,
        style: theme.typography
            .style(HeroFontSize.sm, weight: HeroTypography.semibold)
            .copyWith(color: theme.colors.foreground),
      ),
    );
  }
}

class _Orientation extends StatelessWidget {
  const _Orientation();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return _Narrow(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _Heading('Vertical'),
          const HeroCard(
            padding: EdgeInsets.zero,
            children: <Widget>[
              HeroScrollShadow(
                constraints: BoxConstraints(maxHeight: 240),
                padding: EdgeInsets.all(16),
                child: _Paragraphs(),
              ),
            ],
          ),
          SizedBox(height: theme.spacing(8)),
          const _Heading('Horizontal'),
          const HeroCard(
            padding: EdgeInsets.zero,
            children: <Widget>[
              HeroScrollShadow(
                orientation: Axis.horizontal,
                padding: EdgeInsets.all(16),
                child: _EventRow(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TermsCard extends StatelessWidget {
  const _TermsCard();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroCard(
      constraints: const BoxConstraints(maxWidth: 400),
      children: <Widget>[
        const HeroCardHeader(
          children: <Widget>[
            HeroCardTitle.text('Terms and Conditions'),
            HeroCardDescription.text('Please review before proceeding'),
          ],
        ),
        HeroCardContent(
          children: <Widget>[
            HeroScrollShadow(
              height: 300,
              size: 80,
              padding: EdgeInsets.symmetric(horizontal: theme.spacing(4)),
              child: const _Paragraphs(),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: theme.spacing(4)),
          child: HeroCardFooter(
            gap: theme.spacing(2),
            children: <Widget>[
              Expanded(
                child: HeroButton(
                  fullWidth: true,
                  variant: HeroButtonVariant.secondary,
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                child: HeroButton(
                  fullWidth: true,
                  onPressed: () {},
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VisibilityChange extends StatefulWidget {
  const _VisibilityChange();

  @override
  State<_VisibilityChange> createState() => _VisibilityChangeState();
}

class _VisibilityChangeState extends State<_VisibilityChange> {
  HeroScrollShadowVisibility _vertical = HeroScrollShadowVisibility.none;
  HeroScrollShadowVisibility _horizontal = HeroScrollShadowVisibility.none;

  Widget _status(HeroThemeData theme, String text) => DecoratedBox(
    decoration: ShapeDecoration(
      color: theme.colors.defaultColor,
      shape: theme.shapeAll(theme.radii.sm),
    ),
    child: Padding(
      padding: EdgeInsets.all(theme.spacing(4)),
      child: Text(
        text,
        style: theme.typography
            .style(HeroFontSize.sm, weight: HeroTypography.semibold)
            .copyWith(color: theme.colors.defaultForeground),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return _Narrow(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: theme.spacing(2),
        children: <Widget>[
          _status(theme, 'Vertical Shadow State: ${_vertical.name}'),
          HeroScrollShadow(
            constraints: const BoxConstraints(maxHeight: 240),
            padding: EdgeInsets.all(theme.spacing(4)),
            onVisibilityChanged: (HeroScrollShadowVisibility visibility) =>
                setState(() => _vertical = visibility),
            child: const _Paragraphs(),
          ),
          SizedBox(height: theme.spacing(6)),
          _status(theme, 'Horizontal Shadow State: ${_horizontal.name}'),
          HeroScrollShadow(
            orientation: Axis.horizontal,
            padding: EdgeInsets.all(theme.spacing(4)),
            onVisibilityChanged: (HeroScrollShadowVisibility visibility) =>
                setState(() => _horizontal = visibility),
            child: const _EventRow(),
          ),
        ],
      ),
    );
  }
}

const List<String> _entries = <String>[
  'Reviewed quarterly goals with the design team.',
  'Shipped dark mode tokens to production.',
  'Merged accessibility fixes for form fields.',
  'Published updated component documentation.',
  'Scheduled performance audit for next sprint.',
  'Added scroll shadow demos to the docs site.',
];

class _Changelog extends StatelessWidget {
  const _Changelog();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool dark = theme.isDark;
    return _Narrow(
      child: HeroScrollShadow(
        hideScrollBar: true,
        size: 48,
        constraints: BoxConstraints(maxHeight: theme.spacing(48)),
        padding: EdgeInsets.all(theme.spacing(4)),
        // The `ring-1` outline of the HeroUI example sits outside the mask,
        // which clips it away in the browser, so it is left out.
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // neutral-50/90 → white; dark: neutral-900/80 → neutral-900.
            colors: dark
                ? const <Color>[Color(0xCC171717), Color(0xFF171717)]
                : const <Color>[Color(0xE6FAFAFA), Color(0xFFFFFFFF)],
          ),
          shape: theme.shapeAll(
            theme.radii.xl,
            side: BorderSide(
              color: theme.colors.border.withValues(alpha: 0.8),
              width: theme.borderWidth,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: theme.spacing(3),
          children: <Widget>[
            for (final String entry in _entries)
              Text(
                entry,
                style: theme.typography
                    .style(HeroFontSize.sm, lineHeight: 14 * 1.625)
                    .copyWith(
                      // neutral-600 / neutral-400
                      color: dark
                          ? const Color(0xFFA1A1A1)
                          : const Color(0xFF525252),
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
