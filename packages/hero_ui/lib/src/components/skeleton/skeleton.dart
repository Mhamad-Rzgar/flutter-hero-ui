/// HeroUI's `Skeleton`: a placeholder that shows a loading state and the
/// expected shape of content.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// Tailwind's `animate-pulse` timing function.
const Curve _pulseCurve = Cubic(0.4, 0, 0.6, 1);

/// A loading placeholder (HeroUI `Skeleton`).
///
/// A block in `--surface-tertiary` at 70% with `rounded-sm` corners that
/// animates with [animationType]:
///
/// * [HeroSkeletonAnimation.shimmer]: a `--surface-tertiary` highlight sweeps
///   from left to right every 2 s;
/// * [HeroSkeletonAnimation.pulse]: the block fades to 50% and back every
///   2 s;
/// * [HeroSkeletonAnimation.none]: static.
///
/// The animation defaults to the theme's [HeroThemeData.skeletonAnimation]
/// (HeroUI's `--skeleton-animation`). Nothing animates under reduced motion
/// or while tickers are disabled.
///
/// Size it with [width] and [height] (without a width it fills the available
/// width, like a block element), or give it a [child] to take that child's
/// size; the child itself is hidden. Inside a [HeroSkeletonGroup] the
/// group's single synchronized sweep replaces the skeleton's own shimmer.
///
/// ```dart
/// Column(
///   crossAxisAlignment: CrossAxisAlignment.start,
///   spacing: 12,
///   children: <Widget>[
///     HeroSkeleton(height: 128, borderRadius: BorderRadius.circular(8)),
///     const HeroSkeleton(width: 120, height: 12),
///   ],
/// )
/// ```
class HeroSkeleton extends StatefulWidget {
  /// Creates a skeleton.
  const HeroSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.animationType,
    this.color,
    this.semanticLabel,
    this.child,
  });

  /// Fixed width; null fills the available width (or takes [child]'s).
  final double? width;

  /// Fixed height; null takes [child]'s height (or 0).
  final double? height;

  /// Corner radius; defaults to `rounded-sm` (4).
  final BorderRadiusGeometry? borderRadius;

  /// [BoxShape.circle] for round placeholders such as avatars.
  final BoxShape shape;

  /// The animation; null uses [HeroThemeData.skeletonAnimation].
  final HeroSkeletonAnimation? animationType;

  /// Background override (the counterpart of a `bg-*` class).
  final Color? color;

  /// Announces the placeholder (for example "Loading"); the skeleton is
  /// decorative and hidden from assistive technologies otherwise.
  final String? semanticLabel;

  /// Content the skeleton takes its size from; it is not shown.
  final Widget? child;

  @override
  State<HeroSkeleton> createState() => _HeroSkeletonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('width', width, defaultValue: null))
      ..add(DoubleProperty('height', height, defaultValue: null))
      ..add(
        EnumProperty<HeroSkeletonAnimation>(
          'animationType',
          animationType,
          defaultValue: null,
        ),
      );
  }
}

class _HeroSkeletonState extends State<HeroSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  HeroSkeletonAnimation _type(HeroThemeData theme) {
    if (theme.motion.shouldReduceMotion(context)) {
      return HeroSkeletonAnimation.none;
    }
    return widget.animationType ?? theme.skeletonAnimation;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(HeroSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    final HeroSkeletonAnimation type = _type(HeroTheme.of(context));
    final bool inGroup = _HeroSkeletonGroupScope.maybeOf(context) != null;
    final bool animate =
        type == HeroSkeletonAnimation.pulse ||
        (type == HeroSkeletonAnimation.shimmer && !inGroup);
    if (animate) {
      final AnimationController controller = _controller ??=
          AnimationController(vsync: this, duration: HeroMotion.skeleton);
      if (!controller.isAnimating) controller.repeat();
    } else {
      _controller
        ?..stop()
        ..value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroSkeletonAnimation type = _type(theme);
    final _HeroSkeletonGroupScope? group = _HeroSkeletonGroupScope.maybeOf(
      context,
    );
    final ShapeBorder shape = widget.shape == BoxShape.circle
        ? const CircleBorder()
        : theme.shape(
            widget.borderRadius ??
                BorderRadius.all(Radius.circular(theme.radii.sm)),
          );
    final Color tertiary = theme.colors.surfaceTertiary;

    Widget content = widget.child == null
        ? const SizedBox.expand()
        : Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: widget.child!,
          );

    content = CustomPaint(
      painter: _HeroSkeletonPainter(
        shape: shape,
        color: widget.color ?? tertiary.withValues(alpha: tertiary.a * 0.7),
        shimmerColor: tertiary,
        type: type,
        animation: _controller ?? kAlwaysDismissedAnimation,
        group: group,
        groupColor: theme.colors.white,
        textDirection: Directionality.maybeOf(context),
        box: () => context.findRenderObject() as RenderBox?,
      ),
      child: content,
    );

    if (_controller != null || group != null) {
      content = RepaintBoundary(child: content);
    }

    if (widget.child == null && widget.width == null) {
      // A block element: fills the available width when it is bounded.
      content = LimitedBox(
        maxWidth: 0,
        child: SizedBox(
          width: double.infinity,
          height: widget.height ?? 0,
          child: content,
        ),
      );
    } else if (widget.child == null ||
        widget.width != null ||
        widget.height != null) {
      content = SizedBox(
        width: widget.width,
        height: widget.child == null ? (widget.height ?? 0) : widget.height,
        child: content,
      );
    }

    content = IgnorePointer(child: content);
    final String? label = widget.semanticLabel;
    return label == null
        ? ExcludeSemantics(child: content)
        : Semantics(
            label: label,
            child: ExcludeSemantics(child: content),
          );
  }
}

/// A container that plays one synchronized shimmer over all the skeletons
/// inside it (HeroUI's `skeleton--shimmer` class on a parent).
///
/// The sweep (`transparent → white 50% → transparent`, blended with
/// `overlay`) moves across the whole group every 2 s and is drawn on the
/// skeletons only; their own shimmer is suppressed. Give the children
/// `animationType: HeroSkeletonAnimation.none`, like HeroUI's example.
class HeroSkeletonGroup extends StatefulWidget {
  /// Plays one shimmer over the skeletons in [child].
  const HeroSkeletonGroup({super.key, required this.child});

  /// The content holding skeletons.
  final Widget child;

  @override
  State<HeroSkeletonGroup> createState() => _HeroSkeletonGroupState();
}

class _HeroSkeletonGroupState extends State<HeroSkeletonGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: HeroMotion.skeleton,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (HeroTheme.of(context).motion.shouldReduceMotion(context)) {
      _controller
        ..stop()
        ..value = 0;
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
    final bool reduced = HeroTheme.of(
      context,
    ).motion.shouldReduceMotion(context);
    return _HeroSkeletonGroupScope(
      animation: _controller,
      enabled: !reduced,
      box: () => context.findRenderObject() as RenderBox?,
      child: widget.child,
    );
  }
}

class _HeroSkeletonGroupScope extends InheritedWidget {
  const _HeroSkeletonGroupScope({
    required this.animation,
    required this.enabled,
    required this.box,
    required super.child,
  });

  final Animation<double> animation;
  final bool enabled;
  final RenderBox? Function() box;

  static _HeroSkeletonGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroSkeletonGroupScope>();

  @override
  bool updateShouldNotify(_HeroSkeletonGroupScope oldWidget) =>
      animation != oldWidget.animation || enabled != oldWidget.enabled;
}

class _HeroSkeletonPainter extends CustomPainter {
  _HeroSkeletonPainter({
    required this.shape,
    required this.color,
    required this.shimmerColor,
    required this.type,
    required this.animation,
    required this.group,
    required this.groupColor,
    required this.textDirection,
    required this.box,
  }) : super(
         repaint: Listenable.merge(<Listenable?>[animation, group?.animation]),
       );

  final ShapeBorder shape;
  final Color color;
  final Color shimmerColor;
  final HeroSkeletonAnimation type;
  final Animation<double> animation;
  final _HeroSkeletonGroupScope? group;
  final Color groupColor;
  final TextDirection? textDirection;
  final RenderBox? Function() box;

  /// `animate-pulse`: opacity 1 → 0.5 → 1.
  static double _pulseOpacity(double t) {
    if (t < 0.5) return 1 - 0.5 * _pulseCurve.transform(t * 2);
    return 0.5 + 0.5 * _pulseCurve.transform((t - 0.5) * 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final Rect rect = Offset.zero & size;
    final Path path = shape.getOuterPath(rect, textDirection: textDirection);
    final double t = animation.value;
    final double opacity = type == HeroSkeletonAnimation.pulse
        ? _pulseOpacity(t)
        : 1;

    canvas
      ..save()
      ..clipPath(path);
    canvas.drawRect(
      rect,
      Paint()..color = color.withValues(alpha: color.a * opacity),
    );

    final _HeroSkeletonGroupScope? group = this.group;
    if (group == null) {
      if (type == HeroSkeletonAnimation.shimmer && t > 0) {
        // The highlight starts one width to the left (`-translate-x-full`)
        // and ends one width to the right (`translateX(200%)`).
        final Rect band = Rect.fromLTWH(
          size.width * (-1 + 2 * t),
          0,
          size.width,
          size.height,
        );
        canvas.drawRect(
          rect,
          Paint()
            ..shader = LinearGradient(
              colors: <Color>[
                shimmerColor.withValues(alpha: 0),
                shimmerColor,
                shimmerColor.withValues(alpha: 0),
              ],
            ).createShader(band),
        );
      }
    } else if (group.enabled) {
      _paintGroupBand(canvas, rect, group);
    }
    canvas.restore();
  }

  void _paintGroupBand(
    Canvas canvas,
    Rect rect,
    _HeroSkeletonGroupScope group,
  ) {
    final RenderBox? groupBox = group.box();
    final RenderBox? ownBox = box();
    if (groupBox == null ||
        ownBox == null ||
        !groupBox.hasSize ||
        !ownBox.attached ||
        !groupBox.attached) {
      return;
    }
    final double t = group.animation.value;
    if (t <= 0) return;
    final Offset origin = ownBox.localToGlobal(Offset.zero, ancestor: groupBox);
    final Size groupSize = groupBox.size;
    final Rect band = Rect.fromLTWH(
      groupSize.width * (-1 + 2 * t) - origin.dx,
      -origin.dy,
      groupSize.width,
      groupSize.height,
    );
    // `transparent 0% → rgba(255, 255, 255, 0.5) 50% → transparent 100%`
    // with `mix-blend-mode: overlay`.
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.overlay
        ..shader = LinearGradient(
          colors: <Color>[
            groupColor.withValues(alpha: 0),
            groupColor.withValues(alpha: 0.5),
            groupColor.withValues(alpha: 0),
          ],
        ).createShader(band),
    );
  }

  @override
  bool shouldRepaint(_HeroSkeletonPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.color != color ||
      oldDelegate.shimmerColor != shimmerColor ||
      oldDelegate.type != type ||
      oldDelegate.animation != animation ||
      oldDelegate.group != group ||
      oldDelegate.groupColor != groupColor ||
      oldDelegate.textDirection != textDirection;
}
