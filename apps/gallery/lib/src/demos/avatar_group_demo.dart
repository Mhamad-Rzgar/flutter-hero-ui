import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const String _avatars =
    'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/avatars';

const List<(String, String)> _users = <(String, String)>[
  ('John Doe', '$_avatars/blue.jpg'),
  ('Kate Wilson', '$_avatars/green.jpg'),
  ('Emily Chen', '$_avatars/purple.jpg'),
  ('Michael Brown', '$_avatars/orange.jpg'),
  ('Olivia Davis', '$_avatars/red.jpg'),
];

List<Widget> _people(int count) => <Widget>[
  for (final (String name, String src) in _users.take(count))
    HeroAvatar(src: src, name: name),
];

const String _usersCode = r'''
const List<(String, String)> users = <(String, String)>[
  ('John Doe', '$avatars/blue.jpg'),
  ('Kate Wilson', '$avatars/green.jpg'),
  ('Emily Chen', '$avatars/purple.jpg'),
  ('Michael Brown', '$avatars/orange.jpg'),
  ('Olivia Davis', '$avatars/red.jpg'),
];
''';

final ComponentDemo avatarGroupDemo = ComponentDemo(
  slug: 'avatar-group',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      OptionsControl('overlap', <String>['clip', 'ring']),
      OptionsControl('max', <String>['none', '2', '3', '4']),
      ToggleControl('isGrid'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final String max = values.option('max');
      return HeroAvatarGroup(
        size: values.pick('size', HeroSize.values),
        overlap: values.pick('overlap', HeroAvatarGroupOverlap.values),
        max: max == 'none' ? null : int.parse(max),
        isGrid: values.toggle('isGrid'),
        children: _people(5),
      );
    },
    code: (PlaygroundValues values) {
      final List<String> args = <String>[
        if (values.option('size') != 'md')
          'size: HeroSize.${values.option('size')}',
        if (values.option('overlap') != 'clip')
          'overlap: HeroAvatarGroupOverlap.${values.option('overlap')}',
        if (values.option('max') != 'none') 'max: ${values.option('max')}',
        if (values.toggle('isGrid')) 'isGrid: true',
      ];
      return '''
HeroAvatarGroup(
${args.map((String a) => '  $a,\n').join()}  children: <Widget>[
    for (final (String name, String src) in users)
      HeroAvatar(src: src, name: name),
  ],
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => HeroAvatarGroup(children: _people(4)),
      code:
          '''
$_usersCode
HeroAvatarGroup(
  children: <Widget>[
    for (final (String name, String src) in users.take(4))
      HeroAvatar(
        children: <Widget>[
          HeroAvatarImage.network(src, semanticLabel: name),
          HeroAvatarFallback(child: Text(HeroAvatar.initialsOf(name))),
        ],
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Max',
      builder: (BuildContext context) =>
          HeroAvatarGroup(max: 3, children: _people(5)),
      code: '''
HeroAvatarGroup(
  max: 3,
  children: <Widget>[
    for (final (String name, String src) in users)
      HeroAvatar(src: src, name: name),
  ],
)''',
    ),
    DemoExample(
      title: 'With Count',
      builder: (BuildContext context) => HeroAvatarGroup(
        size: HeroSize.sm,
        children: <Widget>[
          ..._people(3),
          const HeroAvatarGroupCount(child: Text('+${12 - 3}')),
        ],
      ),
      code: r'''
const int total = 12;

HeroAvatarGroup(
  size: HeroSize.sm,
  children: <Widget>[
    for (final (String name, String src) in users.take(3))
      HeroAvatar(src: src, name: name),
    HeroAvatarGroupCount(child: Text('+${total - 3}')),
  ],
)''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final TextStyle caption = theme.typography.sm.copyWith(
          color: theme.colors.muted,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.spacing(6),
          children: <Widget>[
            for (final (String label, HeroSize size)
                in const <(String, HeroSize)>[
                  ('Small', HeroSize.sm),
                  ('Medium (default)', HeroSize.md),
                  ('Large', HeroSize.lg),
                ])
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: theme.spacing(2),
                children: <Widget>[
                  Text(label, style: caption),
                  HeroAvatarGroup(size: size, children: _people(4)),
                ],
              ),
          ],
        );
      },
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  spacing: 24,
  children: <Widget>[
    Text('Small'),
    HeroAvatarGroup(size: HeroSize.sm, children: avatars),
    Text('Medium (default)'),
    HeroAvatarGroup(children: avatars),
    Text('Large'),
    HeroAvatarGroup(size: HeroSize.lg, children: avatars),
  ],
)''',
    ),
    DemoExample(
      title: 'Grid',
      builder: (BuildContext context) =>
          HeroAvatarGroup(isGrid: true, max: 5, children: _people(5)),
      code: '''
HeroAvatarGroup(
  isGrid: true,
  max: 5,
  children: <Widget>[
    for (final (String name, String src) in users)
      HeroAvatar(src: src, name: name),
  ],
)''',
    ),
    DemoExample(
      title: 'Overlap',
      description:
          'clip cuts a transparent crescent where avatars overlap, so the '
          'backdrop shows through; ring outlines each avatar in the page '
          'background color.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: theme.spacing(6),
          children: <Widget>[
            for (final HeroAvatarGroupOverlap overlap
                in HeroAvatarGroupOverlap.values)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: theme.spacing(2),
                children: <Widget>[
                  Text(
                    overlap.name,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.muted,
                    ),
                  ),
                  _StripeBackdrop(child: _OverlapGroup(overlap: overlap)),
                ],
              ),
          ],
        );
      },
      code: '''
HeroAvatarGroup(
  overlap: HeroAvatarGroupOverlap.clip, // or ring
  size: HeroSize.lg,
  children: <Widget>[
    HeroAvatar(src: '\$avatars/blue.jpg', fallback: Text('JD')),
    HeroAvatar(fallback: Text('AB')),
    HeroAvatar(src: '\$avatars/purple.jpg', fallback: Text('EC')),
    HeroAvatar(fallback: Text('SM')),
    HeroAvatarGroupCount(child: Text('+2')),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) => const _AssigneesPill(),
      code: '''
DecoratedBox(
  decoration: ShapeDecoration(
    color: theme.colors.surface.withValues(alpha: 0.95),
    shape: theme.shapeAll(
      theme.radii.full,
      side: BorderSide(color: theme.colors.border.withValues(alpha: 0.7)),
    ),
    shadows: shadowSm,
  ),
  child: Padding(
    padding: EdgeInsetsDirectional.fromSTEB(4, 4, 12, 4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: <Widget>[
        HeroAvatarGroup(
          semanticLabel: 'Assignees',
          overlap: HeroAvatarGroupOverlap.clip,
          overlapDistance: 11.2,
          seam: 2,
          size: HeroSize.sm,
          children: <Widget>[
            for (final (String name, String src) in assignees)
              HeroAvatar(src: src, name: name),
            HeroAvatar(fallback: HeroIcon(HeroIcons.person)),
            HeroAvatarGroupCount(child: Text('+3')),
          ],
        ),
        Text('Assignees'),
      ],
    ),
  ),
)''',
    ),
  ],
);

class _OverlapGroup extends StatelessWidget {
  const _OverlapGroup({required this.overlap});

  final HeroAvatarGroupOverlap overlap;

  @override
  Widget build(BuildContext context) => HeroAvatarGroup(
    overlap: overlap,
    size: HeroSize.lg,
    children: const <Widget>[
      HeroAvatar(
        src: '$_avatars/blue.jpg',
        semanticLabel: 'John',
        fallback: Text('JD'),
      ),
      HeroAvatar(fallback: Text('AB')),
      HeroAvatar(
        src: '$_avatars/purple.jpg',
        semanticLabel: 'Emily',
        fallback: Text('EC'),
      ),
      HeroAvatar(fallback: Text('SM')),
      HeroAvatarGroupCount(child: Text('+2')),
    ],
  );
}

/// Diagonal danger-tinted stripes that drift 24 px every 2.8 s, like the
/// docs' `ag-stripes` backdrop.
class _StripeBackdrop extends StatefulWidget {
  const _StripeBackdrop({required this.child});

  final Widget child;

  @override
  State<_StripeBackdrop> createState() => _StripeBackdropState();
}

class _StripeBackdropState extends State<_StripeBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (HeroTheme.of(context).motion.shouldReduceMotion(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final OutlinedBorder shape = theme.shapeAll(theme.radii.xl);
    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: CustomPaint(
        painter: _StripesPainter(
          progress: _controller,
          background: colorMix(
            theme.colors.danger,
            theme.colors.surface,
            p1: 0.06,
          ),
          thin: theme.colors.danger.withValues(alpha: 0.12),
          thick: theme.colors.danger.withValues(alpha: 0.28),
        ),
        child: Padding(
          padding: EdgeInsets.all(theme.spacing(6)),
          child: widget.child,
        ),
      ),
    );
  }
}

class _StripesPainter extends CustomPainter {
  _StripesPainter({
    required this.progress,
    required this.background,
    required this.thin,
    required this.thick,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color background;
  final Color thin;
  final Color thick;

  /// Stripe period along `x + y`; two periods per 24 px diagonal move keep
  /// the loop seamless.
  static const double _period = 24;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final double shift = progress.value * 2 * _period;
    final Paint thinPaint = Paint()
      ..color = thin
      ..strokeWidth = 1;
    final Paint thickPaint = Paint()
      ..color = thick
      ..strokeWidth = 1;
    final double extent = size.width + size.height;
    for (double c = -_period + (shift % _period); c < extent; c += _period) {
      for (final (double at, Paint paint) in <(double, Paint)>[
        (c + _period * 10 / 22, thinPaint),
        (c + _period * 21 / 22, thickPaint),
      ]) {
        // Lines where x + y = at, from the bottom edge to the top edge.
        canvas.drawLine(
          Offset(at - size.height, size.height),
          Offset(at, 0),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StripesPainter oldDelegate) =>
      oldDelegate.background != background ||
      oldDelegate.thin != thin ||
      oldDelegate.thick != thick;
}

class _AssigneesPill extends StatelessWidget {
  const _AssigneesPill();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool dark = theme.isDark;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: theme.colors.surface.withValues(alpha: dark ? 0.9 : 0.95),
        shape: theme.shapeAll(
          theme.radii.full,
          side: BorderSide(
            color: theme.colors.border.withValues(alpha: dark ? 0.8 : 0.7),
          ),
        ),
        // Tailwind `shadow-sm`.
        shadows: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          theme.spacing(1),
          theme.spacing(1),
          theme.spacing(3),
          theme.spacing(1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.spacing(2.5),
          children: <Widget>[
            HeroAvatarGroup(
              semanticLabel: 'Assignees',
              overlapDistance: theme.spacing(2.8),
              seam: theme.spacing(0.5),
              size: HeroSize.sm,
              children: <Widget>[
                ..._people(3),
                const HeroAvatar(fallback: HeroIcon(HeroIcons.person)),
                const HeroAvatarGroupCount(child: Text('+3')),
              ],
            ),
            Text(
              'Assignees',
              style: theme.typography
                  .style(HeroFontSize.sm, weight: HeroTypography.medium)
                  .copyWith(color: theme.colors.foreground),
            ),
          ],
        ),
      ),
    );
  }
}
