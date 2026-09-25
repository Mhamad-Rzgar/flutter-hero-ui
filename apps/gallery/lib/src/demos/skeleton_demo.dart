import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroSkeleton`, reproducing
/// heroui.com/docs/components/skeleton.
final ComponentDemo skeletonDemo = ComponentDemo(
  slug: 'skeleton',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('animationType', <String>['shimmer', 'pulse', 'none']),
    ],
    builder: (BuildContext context, PlaygroundValues values) => _BasicCard(
      animationType: values.pick('animationType', HeroSkeletonAnimation.values),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroSkeleton(
  height: 128,
  borderRadius: BorderRadius.circular(theme.radii.lg),
  animationType: HeroSkeletonAnimation.${values.option('animationType')},
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _BasicCard(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final BorderRadius rounded = BorderRadius.circular(theme.radii.lg);
SizedBox(
  width: 250,
  child: Padding(
    padding: EdgeInsets.all(theme.spacing(4)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: <Widget>[
        HeroSkeleton(height: 128, borderRadius: rounded),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: <Widget>[
            FractionallySizedBox(
              widthFactor: 3 / 5,
              child: HeroSkeleton(height: 12, borderRadius: rounded),
            ),
            FractionallySizedBox(
              widthFactor: 4 / 5,
              child: HeroSkeleton(height: 12, borderRadius: rounded),
            ),
            FractionallySizedBox(
              widthFactor: 2 / 5,
              child: HeroSkeleton(height: 12, borderRadius: rounded),
            ),
          ],
        ),
      ],
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Text Content',
      builder: (BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 448),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: <Widget>[
            for (final double factor in <double>[1, 5 / 6, 4 / 6, 1, 3 / 6])
              FractionallySizedBox(
                widthFactor: factor,
                child: const HeroSkeleton(height: 16),
              ),
          ],
        ),
      ),
      code: '''
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 448),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: <Widget>[
      for (final double factor in <double>[1, 5 / 6, 4 / 6, 1, 3 / 6])
        FractionallySizedBox(
          widthFactor: factor,
          child: const HeroSkeleton(height: 16),
        ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'User Profile',
      builder: (BuildContext context) {
        final BorderRadius rounded = BorderRadius.circular(
          HeroTheme.of(context).radii.lg,
        );
        return Row(
          spacing: 12,
          children: <Widget>[
            const HeroSkeleton(width: 40, height: 40, shape: BoxShape.circle),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  HeroSkeleton(width: 144, height: 12, borderRadius: rounded),
                  HeroSkeleton(width: 96, height: 12, borderRadius: rounded),
                ],
              ),
            ),
          ],
        );
      },
      code: '''
Row(
  spacing: 12,
  children: <Widget>[
    const HeroSkeleton(width: 40, height: 40, shape: BoxShape.circle),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          HeroSkeleton(width: 144, height: 12, borderRadius: rounded),
          HeroSkeleton(width: 96, height: 12, borderRadius: rounded),
        ],
      ),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'List Items',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 384),
          child: Column(
            spacing: 16,
            children: <Widget>[
              for (int i = 0; i < 3; i++)
                Row(
                  spacing: 12,
                  children: <Widget>[
                    HeroSkeleton(
                      width: 40,
                      height: 40,
                      borderRadius: BorderRadius.circular(theme.radii.lg),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: <Widget>[
                          HeroSkeleton(height: 12),
                          FractionallySizedBox(
                            widthFactor: 4 / 5,
                            child: HeroSkeleton(height: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
      code: '''
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 384),
  child: Column(
    spacing: 16,
    children: <Widget>[
      for (int i = 0; i < 3; i++)
        Row(
          spacing: 12,
          children: <Widget>[
            HeroSkeleton(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.circular(theme.radii.lg),
            ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  HeroSkeleton(height: 12),
                  FractionallySizedBox(
                    widthFactor: 4 / 5,
                    child: HeroSkeleton(height: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Grid',
      builder: (BuildContext context) => const _Grid(),
      code: '''
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 576),
  child: Row(
    spacing: 16,
    children: <Widget>[
      for (int i = 0; i < 3; i++)
        Expanded(
          child: HeroSkeleton(
            height: 96,
            borderRadius: BorderRadius.circular(theme.radii.xl),
          ),
        ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Single Shimmer',
      description:
          'One synchronized shimmer passes over every skeleton of a '
          'HeroSkeletonGroup; the children use animationType none.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return ClipPath(
          clipper: ShapeBorderClipper(shape: theme.shapeAll(theme.radii.xl)),
          child: const HeroSkeletonGroup(
            child: _Grid(animationType: HeroSkeletonAnimation.none),
          ),
        );
      },
      code: '''
ClipPath(
  clipper: ShapeBorderClipper(shape: theme.shapeAll(theme.radii.xl)),
  child: HeroSkeletonGroup(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: Row(
        spacing: 16,
        children: <Widget>[
          for (int i = 0; i < 3; i++)
            Expanded(
              child: HeroSkeleton(
                height: 96,
                animationType: HeroSkeletonAnimation.none,
                borderRadius: BorderRadius.circular(theme.radii.xl),
              ),
            ),
        ],
      ),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Animation Types',
      builder: (BuildContext context) => const _AnimationTypes(),
      code: '''
// One column per animation type (1 column below sm, 2 from sm, 3 from lg).
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 8,
  children: <Widget>[
    Text('Shimmer', style: theme.typography.xs.copyWith(color: theme.colors.muted)),
    Padding(
      padding: EdgeInsets.all(theme.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          HeroSkeleton(
            height: 80,
            animationType: HeroSkeletonAnimation.shimmer,
            borderRadius: rounded,
          ),
          FractionallySizedBox(
            widthFactor: 3 / 5,
            child: HeroSkeleton(
              height: 12,
              animationType: HeroSkeletonAnimation.shimmer,
              borderRadius: rounded,
            ),
          ),
          FractionallySizedBox(
            widthFactor: 4 / 5,
            child: HeroSkeleton(
              height: 12,
              animationType: HeroSkeletonAnimation.shimmer,
              borderRadius: rounded,
            ),
          ),
        ],
      ),
    ),
  ],
)
// ...the same with HeroSkeletonAnimation.pulse and HeroSkeletonAnimation.none.''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'Bones with a custom color and a custom "shine" sweep in a bordered '
          'card.',
      builder: (BuildContext context) => const _CustomCard(),
      code: '''
// A bone: a static skeleton with a custom color, and a 3 s shine sweep
// (transparent → white 30% → white 10% → transparent at 120°) on top.
HeroSkeleton(
  height: 128,
  color: theme.colors.defaultColor.withValues(alpha: 0.9),
  animationType: HeroSkeletonAnimation.none,
  borderRadius: BorderRadius.circular(theme.radii.lg),
)

// The card around the bones.
HeroSurface(
  width: 250,
  borderRadius: BorderRadius.circular(theme.radii.xl),
  border: BorderSide(
    color: theme.colors.border.withValues(alpha: 0.8),
    width: theme.borderWidth,
  ),
  shadow: HeroShadow(
    boxShadows: <BoxShadow>[
      BoxShadow(
        color: theme.isDark
            ? theme.colors.white.withValues(alpha: 0.1)
            : theme.colors.black.withValues(alpha: 0.05),
        spreadRadius: 1,
      ),
      ...theme.shadows.surface.boxShadows,
    ],
  ),
  padding: EdgeInsets.all(theme.spacing(4)),
  child: bones,
)''',
    ),
  ],
);

/// HeroUI's basic skeleton card: an image block and three lines.
class _BasicCard extends StatelessWidget {
  const _BasicCard({this.animationType});

  final HeroSkeletonAnimation? animationType;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final BorderRadius rounded = BorderRadius.circular(theme.radii.lg);
    Widget line(double factor) => FractionallySizedBox(
      widthFactor: factor,
      child: HeroSkeleton(
        height: 12,
        animationType: animationType,
        borderRadius: rounded,
      ),
    );
    return SizedBox(
      width: 250,
      child: Padding(
        padding: EdgeInsets.all(theme.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: <Widget>[
            HeroSkeleton(
              height: 128,
              animationType: animationType,
              borderRadius: rounded,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: <Widget>[line(3 / 5), line(4 / 5), line(2 / 5)],
            ),
          ],
        ),
      ),
    );
  }
}

/// Three 96 px tiles in a row.
class _Grid extends StatelessWidget {
  const _Grid({this.animationType});

  final HeroSkeletonAnimation? animationType;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: Row(
        spacing: 16,
        children: <Widget>[
          for (int i = 0; i < 3; i++)
            Expanded(
              child: HeroSkeleton(
                height: 96,
                animationType: animationType,
                borderRadius: BorderRadius.circular(theme.radii.xl),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimationTypes extends StatelessWidget {
  const _AnimationTypes();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double viewport = MediaQuery.sizeOf(context).width;
    final int columns = viewport >= HeroBreakpoints.lg
        ? 3
        : viewport >= HeroBreakpoints.sm
        ? 2
        : 1;
    final BorderRadius rounded = BorderRadius.circular(theme.radii.lg);

    Widget column(String label, HeroSkeletonAnimation type) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.xs.copyWith(color: theme.colors.muted),
        ),
        Padding(
          padding: EdgeInsets.all(theme.spacing(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: <Widget>[
              HeroSkeleton(
                height: 80,
                animationType: type,
                borderRadius: rounded,
              ),
              FractionallySizedBox(
                widthFactor: 3 / 5,
                child: HeroSkeleton(
                  height: 12,
                  animationType: type,
                  borderRadius: rounded,
                ),
              ),
              FractionallySizedBox(
                widthFactor: 4 / 5,
                child: HeroSkeleton(
                  height: 12,
                  animationType: type,
                  borderRadius: rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final List<Widget> cells = <Widget>[
      column('Shimmer', HeroSkeletonAnimation.shimmer),
      column('Pulse', HeroSkeletonAnimation.pulse),
      column('None', HeroSkeletonAnimation.none),
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: Column(
        spacing: 24,
        children: <Widget>[
          for (int start = 0; start < cells.length; start += columns)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: <Widget>[
                for (int i = start; i < start + columns; i++)
                  Expanded(
                    child: i < cells.length ? cells[i] : const SizedBox(),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CustomCard extends StatelessWidget {
  const _CustomCard();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroSurface(
      width: 250,
      borderRadius: BorderRadius.circular(theme.radii.xl),
      border: BorderSide(
        color: theme.colors.border.withValues(alpha: 0.8),
        width: theme.borderWidth,
      ),
      shadow: HeroShadow(
        boxShadows: <BoxShadow>[
          BoxShadow(
            color: theme.isDark
                ? theme.colors.white.withValues(alpha: 0.1)
                : theme.colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
          ),
          ...theme.shadows.surface.boxShadows,
        ],
      ),
      padding: EdgeInsets.all(theme.spacing(4)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: <Widget>[
          _ShineBone(height: 128),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 3 / 5,
                child: _ShineBone(height: 12),
              ),
              FractionallySizedBox(
                widthFactor: 4 / 5,
                child: _ShineBone(height: 12),
              ),
              FractionallySizedBox(
                widthFactor: 2 / 5,
                child: _ShineBone(height: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A skeleton bone with the docs' custom `animate-shine` sweep.
class _ShineBone extends StatefulWidget {
  const _ShineBone({required this.height});

  final double height;

  @override
  State<_ShineBone> createState() => _ShineBoneState();
}

class _ShineBoneState extends State<_ShineBone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
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
    final OutlinedBorder shape = theme.shapeAll(theme.radii.lg);
    final Color white = theme.colors.white;
    final (double strong, double soft) = theme.isDark
        ? (0.1, 0.04)
        : (0.3, 0.1);
    return Stack(
      children: <Widget>[
        HeroSkeleton(
          height: widget.height,
          color: theme.colors.defaultColor.withValues(alpha: 0.9),
          animationType: HeroSkeletonAnimation.none,
          borderRadius: BorderRadius.circular(theme.radii.lg),
        ),
        Positioned.fill(
          child: ClipPath(
            clipper: ShapeBorderClipper(shape: shape),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) =>
                  FractionalTranslation(
                    translation: Offset(
                      -1 + 2 * Curves.easeInOut.transform(_controller.value),
                      0,
                    ),
                    child: child,
                  ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    transform: const GradientRotation(math.pi / 6),
                    stops: const <double>[0.1, 0.45, 0.55, 0.9],
                    colors: <Color>[
                      white.withValues(alpha: 0),
                      white.withValues(alpha: strong),
                      white.withValues(alpha: soft),
                      white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
