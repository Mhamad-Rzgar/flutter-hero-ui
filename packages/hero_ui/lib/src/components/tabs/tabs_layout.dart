part of 'tabs.dart';

/// Lays out horizontal tabs like HeroUI's `w-max min-w-full` flex row of
/// `w-full` tabs: when the tabs fit, the incoming minimum width is shared
/// equally, except that no tab gets less than its natural width; when they
/// do not fit, every tab keeps its natural width (and the list scrolls).
/// All tabs get the height of the tallest one.
class _TabRow extends MultiChildRenderObjectWidget {
  const _TabRow({required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTabRow(textDirection: Directionality.of(context));

  @override
  void updateRenderObject(BuildContext context, _RenderTabRow renderObject) {
    renderObject.textDirection = Directionality.of(context);
  }
}

class _TabRowParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderTabRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TabRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TabRowParentData> {
  _RenderTabRow({required TextDirection textDirection})
    : _textDirection = textDirection;

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TabRowParentData) {
      child.parentData = _TabRowParentData();
    }
  }

  List<RenderBox> get _children {
    final List<RenderBox> result = <RenderBox>[];
    RenderBox? child = firstChild;
    while (child != null) {
      result.add(child);
      child = childAfter(child);
    }
    return result;
  }

  List<double> _naturalWidths(List<RenderBox> children) => <double>[
    for (final RenderBox child in children)
      child.getMaxIntrinsicWidth(double.infinity),
  ];

  /// Shares [target] between the tabs: equal shares, but never less than a
  /// tab's natural width (CSS flex shrinking of equal bases down to
  /// `min-width: auto`).
  static List<double> _distribute(List<double> natural, double target) {
    final double total = natural.fold(0, (double a, double b) => a + b);
    if (target <= total) {
      if (total == 0 || target >= total) return List<double>.of(natural);
      // Not enough room and no scroll view: shrink proportionally.
      return <double>[for (final double w in natural) w * target / total];
    }
    final List<double> widths = List<double>.filled(natural.length, 0);
    final Set<int> fixed = <int>{};
    double remaining = target;
    while (fixed.length < natural.length) {
      final double share = remaining / (natural.length - fixed.length);
      final List<int> wide = <int>[
        for (int i = 0; i < natural.length; i++)
          if (!fixed.contains(i) && natural[i] > share) i,
      ];
      if (wide.isEmpty) {
        for (int i = 0; i < natural.length; i++) {
          if (!fixed.contains(i)) widths[i] = share;
        }
        break;
      }
      for (final int i in wide) {
        widths[i] = natural[i];
        remaining -= natural[i];
        fixed.add(i);
      }
    }
    return widths;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _naturalWidths(_children).fold(0, (double a, double b) => a + b);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      computeMinIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) => _children.fold(
    0,
    (double h, RenderBox c) =>
        math.max(h, c.getMinIntrinsicHeight(double.infinity)),
  );

  @override
  double computeMaxIntrinsicHeight(double width) => _children.fold(
    0,
    (double h, RenderBox c) =>
        math.max(h, c.getMaxIntrinsicHeight(double.infinity)),
  );

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToHighestActualBaseline(baseline);

  (List<double>, double) _measure(BoxConstraints constraints) {
    final List<RenderBox> children = _children;
    final List<double> natural = _naturalWidths(children);
    final double total = natural.fold(0, (double a, double b) => a + b);
    final double target = constraints.constrainWidth(
      math.max(total, constraints.minWidth),
    );
    final List<double> widths = _distribute(natural, target);
    double height = 0;
    for (int i = 0; i < children.length; i++) {
      height = math.max(height, children[i].getMaxIntrinsicHeight(widths[i]));
    }
    return (widths, constraints.constrainHeight(height));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (firstChild == null) return constraints.smallest;
    final (List<double> widths, double height) = _measure(constraints);
    return constraints.constrain(
      Size(widths.fold(0, (double a, double b) => a + b), height),
    );
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.smallest;
      return;
    }
    final (List<double> widths, double height) = _measure(constraints);
    final double width = widths.fold(0, (double a, double b) => a + b);
    size = constraints.constrain(Size(width, height));
    final bool rtl = _textDirection == TextDirection.rtl;
    double x = rtl ? size.width : 0;
    int i = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(
        BoxConstraints.tightFor(width: widths[i], height: height),
        parentUsesSize: true,
      );
      final _TabRowParentData data = child.parentData! as _TabRowParentData;
      if (rtl) {
        x -= widths[i];
        data.offset = Offset(x, 0);
      } else {
        data.offset = Offset(x, 0);
        x += widths[i];
      }
      i++;
      child = data.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}

/// The scrolling part of a [HeroTabListContainer] (HeroUI's `ScrollShadow`
/// with `size={64}` and a hidden scrollbar, plus the chevron buttons).
class _TabListScroller extends StatefulWidget {
  const _TabListScroller({
    required this.controller,
    required this.axis,
    required this.child,
  });

  final ScrollController controller;
  final Axis axis;
  final Widget child;

  @override
  State<_TabListScroller> createState() => _TabListScrollerState();
}

class _TabListScrollerState extends State<_TabListScroller> {
  double _startFade = 0;
  double _endFade = 0;
  bool _canScrollBack = false;
  bool _canScrollForward = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didUpdateWidget(_TabListScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_update);
      widget.controller.addListener(_update);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (!mounted || !widget.controller.hasClients) return;
    final ScrollPosition position = widget.controller.position;
    if (!position.hasContentDimensions || !position.hasPixels) return;
    final double fade = HeroTheme.of(context).spacing(16);
    final double before = position.pixels - position.minScrollExtent;
    final double after = position.maxScrollExtent - position.pixels;
    final double startFade = before.clamp(0, fade);
    final double endFade = after.clamp(0, fade);
    // `scrollStart > 0` and `scrollStart + clientSize < scrollSize - 1`.
    final bool back = before > 0;
    final bool forward = after > 1;
    if (startFade == _startFade &&
        endFade == _endFade &&
        back == _canScrollBack &&
        forward == _canScrollForward) {
      return;
    }
    setState(() {
      _startFade = startFade;
      _endFade = endFade;
      _canScrollBack = back;
      _canScrollForward = forward;
    });
  }

  void _scrollBy(int direction) {
    if (!widget.controller.hasClients) return;
    final ScrollPosition position = widget.controller.position;
    final double target =
        (position.pixels + direction * position.viewportDimension * 0.8).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
    if (target == position.pixels) return;
    final Duration duration = HeroTheme.of(
      context,
    ).motion.resolve(context, HeroMotion.slower);
    if (duration == Duration.zero) {
      position.jumpTo(target);
    } else {
      position.animateTo(
        target,
        duration: duration,
        curve: HeroMotion.easeInOut,
      );
    }
  }

  Shader _mask(Rect bounds, Color opaque) {
    final bool horizontal = widget.axis == Axis.horizontal;
    final double length = horizontal ? bounds.width : bounds.height;
    final Color clear = opaque.withValues(alpha: 0);
    final double start = length <= 0 ? 0 : (_startFade / length).clamp(0, 1);
    final double end = length <= 0
        ? 1
        : (1 - _endFade / length).clamp(start, 1);
    final bool rtl =
        horizontal && Directionality.of(context) == TextDirection.rtl;
    return LinearGradient(
      begin: horizontal
          ? (rtl ? Alignment.centerRight : Alignment.centerLeft)
          : Alignment.topCenter,
      end: horizontal
          ? (rtl ? Alignment.centerLeft : Alignment.centerRight)
          : Alignment.bottomCenter,
      colors: <Color>[
        _startFade > 0 ? clear : opaque,
        opaque,
        opaque,
        _endFade > 0 ? clear : opaque,
      ],
      stops: <double>[0, start, end, 1],
    ).createShader(bounds);
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool horizontal = widget.axis == Axis.horizontal;
    // Only the mask's alpha matters.
    final Color opaque = theme.colors.foreground.withValues(alpha: 1);
    final Widget scroller = NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _update());
        return false;
      },
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect bounds) => _mask(bounds, opaque),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            controller: widget.controller,
            scrollDirection: widget.axis,
            child: widget.child,
          ),
        ),
      ),
    );
    final double inset = theme.spacing(1);
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        scroller,
        if (_canScrollBack)
          horizontal
              ? PositionedDirectional(
                  start: inset,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _ScrollChevron(
                      icon: HeroIcons.chevronLeft,
                      label: 'Scroll tabs left',
                      onPressed: () => _scrollBy(-1),
                    ),
                  ),
                )
              : Positioned(
                  top: inset,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _ScrollChevron(
                      icon: HeroIcons.chevronUp,
                      label: 'Scroll tabs up',
                      onPressed: () => _scrollBy(-1),
                    ),
                  ),
                ),
        if (_canScrollForward)
          horizontal
              ? PositionedDirectional(
                  end: inset,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _ScrollChevron(
                      icon: HeroIcons.chevronRight,
                      label: 'Scroll tabs right',
                      onPressed: () => _scrollBy(1),
                    ),
                  ),
                )
              : Positioned(
                  bottom: inset,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _ScrollChevron(
                      icon: HeroIcons.chevronDown,
                      label: 'Scroll tabs down',
                      onPressed: () => _scrollBy(1),
                    ),
                  ),
                ),
      ],
    );
  }
}

/// A 16 px chevron button that scrolls an overflowing tab list. It is not a
/// Tab stop (`tabIndex={-1}`), and fades to 70% on hover.
class _ScrollChevron extends StatelessWidget {
  const _ScrollChevron({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final HeroIconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double size = theme.spacing(4);
    return HeroInteractable(
      onPressed: onPressed,
      canRequestFocus: false,
      semanticsLabel: label,
      builder: (BuildContext context, HeroInteractionState state, _) =>
          AnimatedOpacity(
            opacity: state.isHovered ? 0.7 : 1,
            duration: theme.motion.resolve(context, HeroMotion.normal),
            curve: HeroMotion.smooth,
            child: SizedBox.square(
              dimension: size,
              child: HeroIcon(icon, size: size, color: theme.colors.foreground),
            ),
          ),
    );
  }
}

/// Lays out the parts of [HeroTabs] like HeroUI's `.tabs` flex container.
///
/// Horizontal: the children stack vertically and stretch to a bounded
/// width. Vertical: the first child (the tab list) sits at the start with
/// its natural width, the second (the panels) takes the remaining width,
/// and both stretch to the taller of the two (`align-items: stretch`) or
/// to a tight incoming height, so an overflowing list scrolls.
class _TabsRootLayout extends MultiChildRenderObjectWidget {
  const _TabsRootLayout({required this.axis, required super.children});

  final Axis axis;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTabsRoot(axis: axis, textDirection: Directionality.of(context));

  @override
  void updateRenderObject(BuildContext context, _RenderTabsRoot renderObject) {
    renderObject
      ..axis = axis
      ..textDirection = Directionality.of(context);
  }
}

class _TabsRootParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderTabsRoot extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TabsRootParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TabsRootParentData> {
  _RenderTabsRoot({required Axis axis, required TextDirection textDirection})
    : _axis = axis,
      _textDirection = textDirection;

  Axis _axis;
  set axis(Axis value) {
    if (value == _axis) return;
    _axis = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TabsRootParentData) {
      child.parentData = _TabsRootParentData();
    }
  }

  Iterable<RenderBox> get _children sync* {
    RenderBox? child = firstChild;
    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => _axis == Axis.horizontal
      ? _children.fold(
          0,
          (double w, RenderBox c) =>
              math.max(w, c.getMinIntrinsicWidth(height)),
        )
      : _children.fold(
          0,
          (double w, RenderBox c) => w + c.getMinIntrinsicWidth(height),
        );

  @override
  double computeMaxIntrinsicWidth(double height) => _axis == Axis.horizontal
      ? _children.fold(
          0,
          (double w, RenderBox c) =>
              math.max(w, c.getMaxIntrinsicWidth(height)),
        )
      : _children.fold(
          0,
          (double w, RenderBox c) => w + c.getMaxIntrinsicWidth(height),
        );

  @override
  double computeMinIntrinsicHeight(double width) => _axis == Axis.horizontal
      ? _children.fold(
          0,
          (double h, RenderBox c) => h + c.getMinIntrinsicHeight(width),
        )
      : _children.fold(
          0,
          (double h, RenderBox c) =>
              math.max(h, c.getMinIntrinsicHeight(double.infinity)),
        );

  @override
  double computeMaxIntrinsicHeight(double width) => _axis == Axis.horizontal
      ? _children.fold(
          0,
          (double h, RenderBox c) => h + c.getMaxIntrinsicHeight(width),
        )
      : _children.fold(
          0,
          (double h, RenderBox c) =>
              math.max(h, c.getMaxIntrinsicHeight(double.infinity)),
        );

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToFirstActualBaseline(baseline);

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _layout(constraints, dry: true);

  @override
  void performLayout() {
    size = _layout(constraints, dry: false);
  }

  Size _layoutChild(RenderBox child, BoxConstraints constraints, bool dry) {
    if (dry) return child.getDryLayout(constraints);
    child.layout(constraints, parentUsesSize: true);
    return child.size;
  }

  void _place(RenderBox child, Offset offset, bool dry) {
    if (!dry) (child.parentData! as _TabsRootParentData).offset = offset;
  }

  Size _layout(BoxConstraints constraints, {required bool dry}) {
    if (firstChild == null) return constraints.smallest;
    if (_axis == Axis.horizontal) {
      final bool bounded = constraints.hasBoundedWidth;
      final BoxConstraints childConstraints = bounded
          ? BoxConstraints.tightFor(width: constraints.maxWidth)
          : const BoxConstraints();
      double y = 0;
      double width = bounded ? constraints.maxWidth : 0;
      for (final RenderBox child in _children) {
        final Size childSize = _layoutChild(child, childConstraints, dry);
        _place(child, Offset(0, y), dry);
        y += childSize.height;
        if (!bounded) width = math.max(width, childSize.width);
      }
      return constraints.constrain(Size(width, y));
    }

    final RenderBox list = firstChild!;
    final RenderBox? panels = childAfter(list);
    Size listSize = _layoutChild(
      list,
      BoxConstraints(
        maxWidth: constraints.maxWidth,
        maxHeight: constraints.maxHeight,
      ),
      dry,
    );
    Size panelsSize = Size.zero;
    BoxConstraints? panelConstraints;
    if (panels != null) {
      panelConstraints = constraints.hasBoundedWidth
          ? BoxConstraints.tightFor(
              width: math.max(0, constraints.maxWidth - listSize.width),
            ).copyWith(maxHeight: constraints.maxHeight)
          : BoxConstraints(maxHeight: constraints.maxHeight);
      panelsSize = _layoutChild(panels, panelConstraints, dry);
    }
    final double height = constraints.constrainHeight(
      math.max(listSize.height, panelsSize.height),
    );
    if (listSize.height != height) {
      listSize = _layoutChild(
        list,
        BoxConstraints.tightFor(width: listSize.width, height: height),
        dry,
      );
    }
    if (panels != null && panelsSize.height != height) {
      panelsSize = _layoutChild(
        panels,
        BoxConstraints.tightFor(width: panelsSize.width, height: height),
        dry,
      );
    }
    final Size size = constraints.constrain(
      Size(
        constraints.hasBoundedWidth
            ? constraints.maxWidth
            : listSize.width + panelsSize.width,
        height,
      ),
    );
    final bool rtl = _textDirection == TextDirection.rtl;
    _place(list, Offset(rtl ? size.width - listSize.width : 0, 0), dry);
    if (panels != null) {
      _place(
        panels,
        Offset(
          rtl ? size.width - listSize.width - panelsSize.width : listSize.width,
          0,
        ),
        dry,
      );
    }
    return size;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}
