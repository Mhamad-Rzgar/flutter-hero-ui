part of 'tabs.dart';

/// Shares the last painted indicator rectangle between the tabs of one list,
/// so the next selected tab can start its indicator where the previous one
/// was (React Aria's `SelectionIndicator` shared-element transition).
class _IndicatorCoordinator {
  RenderBox? origin;
  Rect? lastRect;
}

/// Marks the box whose coordinate space the indicator rectangles use.
class _IndicatorOrigin extends SingleChildRenderObjectWidget {
  const _IndicatorOrigin({required this.coordinator, super.child});

  final _IndicatorCoordinator coordinator;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderIndicatorOrigin(coordinator);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderIndicatorOrigin renderObject,
  ) {
    renderObject.coordinator = coordinator;
  }
}

class _RenderIndicatorOrigin extends RenderProxyBox {
  _RenderIndicatorOrigin(this._coordinator);

  _IndicatorCoordinator _coordinator;
  set coordinator(_IndicatorCoordinator value) {
    if (identical(value, _coordinator)) return;
    if (_coordinator.origin == this) _coordinator.origin = null;
    _coordinator = value;
    if (attached) _coordinator.origin = this;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _coordinator.origin = this;
  }

  @override
  void detach() {
    if (_coordinator.origin == this) _coordinator.origin = null;
    super.detach();
  }
}

/// HeroUI's `Tabs.Indicator`: the selection marker of a [HeroTab].
///
/// In the primary variant it fills the selected tab with the `--segment`
/// color, a 24 px radius and the surface shadow; in the secondary variant it
/// is a 2 px `--accent` line at the bottom of the tab (at its leading edge
/// when vertical). When the selection changes, the indicator of the newly
/// selected tab slides and resizes from the previous position over 250 ms
/// with `--ease-out-fluid`.
///
/// Every [HeroTab] shows one by default; pass a customised indicator as
/// [HeroTab.indicator] to restyle it.
class HeroTabIndicator extends StatefulWidget {
  /// Creates a selection indicator.
  const HeroTabIndicator({
    super.key,
    this.color,
    this.borderRadius,
    this.shadows,
  });

  /// Fill color; defaults to `--segment` (primary) or `--accent`
  /// (secondary).
  final Color? color;

  /// Corner radii; defaults to 24 (primary) or square (secondary).
  final BorderRadiusGeometry? borderRadius;

  /// Shadows; defaults to the surface shadow (primary) or none (secondary).
  final List<BoxShadow>? shadows;

  @override
  State<HeroTabIndicator> createState() => _HeroTabIndicatorState();
}

class _HeroTabIndicatorState extends State<HeroTabIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: 1,
  );
  Rect? _from;
  bool _wasSelected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool selected = _HeroTabScope.maybeOf(context)?.isSelected ?? false;
    if (selected && !_wasSelected) {
      _from = _HeroTabListScope.maybeOf(context)?.coordinator.lastRect;
      final Duration duration = HeroTheme.of(
        context,
      ).motion.resolve(context, HeroMotion.slow);
      if (_from != null && duration > Duration.zero) {
        _controller.duration = duration;
        _controller.forward(from: 0);
      } else {
        _from = null;
        _controller.value = 1;
      }
    }
    _wasSelected = selected;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(_HeroTabScope.maybeOf(context)?.isSelected ?? false)) {
      return const SizedBox.shrink();
    }
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroTabsScope tabs = _HeroTabsScope.of(context);
    final bool secondary = tabs.isSecondary;
    final ShapeDecoration decoration = ShapeDecoration(
      color:
          widget.color ??
          (secondary ? theme.colors.accent : theme.colors.segment),
      shape: theme.shape(
        widget.borderRadius ??
            (secondary
                ? BorderRadius.zero
                : BorderRadius.all(Radius.circular(theme.radii.xl3))),
      ),
      shadows:
          widget.shadows ??
          (secondary ? null : theme.shadows.surface.boxShadows),
    );
    final _IndicatorShape shape = !secondary
        ? _IndicatorShape.fill
        : tabs.orientation == Axis.horizontal
        ? _IndicatorShape.bottomLine
        : _IndicatorShape.startLine;
    return _IndicatorBox(
      decoration: decoration,
      shape: shape,
      thickness: theme.spacing(0.5),
      from: _from,
      animation: _controller,
      coordinator: _HeroTabListScope.maybeOf(context)?.coordinator,
      textDirection: Directionality.of(context),
    );
  }
}

enum _IndicatorShape { fill, bottomLine, startLine }

class _IndicatorBox extends LeafRenderObjectWidget {
  const _IndicatorBox({
    required this.decoration,
    required this.shape,
    required this.thickness,
    required this.from,
    required this.animation,
    required this.coordinator,
    required this.textDirection,
  });

  final Decoration decoration;
  final _IndicatorShape shape;
  final double thickness;
  final Rect? from;
  final Animation<double> animation;
  final _IndicatorCoordinator? coordinator;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderIndicatorBox(
    decoration: decoration,
    shape: shape,
    thickness: thickness,
    from: from,
    animation: animation,
    coordinator: coordinator,
    textDirection: textDirection,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderIndicatorBox renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..shape = shape
      ..thickness = thickness
      ..from = from
      ..animation = animation
      ..coordinator = coordinator
      ..textDirection = textDirection;
  }
}

class _RenderIndicatorBox extends RenderBox {
  _RenderIndicatorBox({
    required Decoration decoration,
    required _IndicatorShape shape,
    required double thickness,
    required Rect? from,
    required Animation<double> animation,
    required _IndicatorCoordinator? coordinator,
    required TextDirection textDirection,
  }) : _decoration = decoration,
       _shape = shape,
       _thickness = thickness,
       _from = from,
       _animation = animation,
       _coordinator = coordinator,
       _textDirection = textDirection;

  BoxPainter? _painter;

  Decoration _decoration;
  set decoration(Decoration value) {
    if (value == _decoration) return;
    _decoration = value;
    _painter?.dispose();
    _painter = null;
    markNeedsPaint();
  }

  _IndicatorShape _shape;
  set shape(_IndicatorShape value) {
    if (value == _shape) return;
    _shape = value;
    markNeedsPaint();
  }

  double _thickness;
  set thickness(double value) {
    if (value == _thickness) return;
    _thickness = value;
    markNeedsPaint();
  }

  Rect? _from;
  set from(Rect? value) {
    if (value == _from) return;
    _from = value;
    markNeedsPaint();
  }

  Animation<double> _animation;
  set animation(Animation<double> value) {
    if (identical(value, _animation)) return;
    if (attached) _animation.removeListener(markNeedsPaint);
    _animation = value;
    if (attached) _animation.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  _IndicatorCoordinator? _coordinator;
  set coordinator(_IndicatorCoordinator? value) {
    if (identical(value, _coordinator)) return;
    _coordinator = value;
    markNeedsPaint();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _animation.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _painter?.dispose();
    super.dispose();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  bool hitTestSelf(Offset position) => false;

  Rect _ownRect() {
    final Rect all = Offset.zero & size;
    return switch (_shape) {
      _IndicatorShape.fill => all,
      _IndicatorShape.bottomLine => Rect.fromLTWH(
        0,
        size.height - _thickness,
        size.width,
        _thickness,
      ),
      _IndicatorShape.startLine => Rect.fromLTWH(
        _textDirection == TextDirection.rtl ? size.width - _thickness : 0,
        0,
        _thickness,
        size.height,
      ),
    };
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    Rect rect = _ownRect();
    final RenderBox? origin = _coordinator?.origin;
    if (origin != null && origin.attached) {
      // Work in the list's coordinates so the rectangle can be handed to the
      // next selected tab.
      final Offset shift =
          MatrixUtils.getAsTranslation(getTransformTo(origin)) ?? Offset.zero;
      final Rect target = rect.shift(shift);
      Rect painted = target;
      final Rect? from = _from;
      if (from != null && _animation.value < 1) {
        painted = Rect.lerp(
          from,
          target,
          HeroMotion.easeOutFluid.transform(_animation.value),
        )!;
      }
      _coordinator!.lastRect = painted;
      rect = painted.shift(-shift);
    }
    _painter ??= _decoration.createBoxPainter(markNeedsPaint);
    _painter!.paint(
      context.canvas,
      offset + rect.topLeft,
      ImageConfiguration(size: rect.size, textDirection: _textDirection),
    );
  }
}
