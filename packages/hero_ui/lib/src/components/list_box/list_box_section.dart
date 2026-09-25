part of 'list_box.dart';

/// HeroUI's `ListBox.Section`: a group of items under an optional
/// [header], usually a [HeroHeader].
///
/// Items of a section follow each other without a gap. Separate sections
/// with a [HeroSeparator] between them in the list's children.
///
/// ```dart
/// HeroListBoxSection(
///   header: const HeroHeader.text('Actions'),
///   children: const <Widget>[
///     HeroListBoxItem(id: 'new', label: 'New file'),
///     HeroListBoxItem(id: 'edit', label: 'Edit file'),
///   ],
/// )
/// ```
///
/// A [HeroHeader] among [children] works as well.
class HeroListBoxSection extends StatelessWidget {
  /// Creates a section.
  const HeroListBoxSection({super.key, this.header, required this.children});

  /// The section title, usually a [HeroHeader].
  final Widget? header;

  /// The items (and [HeroCollection]s of items).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final Widget? header = this.header;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[?header, ...children],
    );
  }
}

/// HeroUI's `Header`: the title of a section in a list box, menu or
/// dropdown.
///
/// `text-xs font-medium` in `--muted`, start-aligned, with 8 px horizontal,
/// 6 px top and 4 px bottom padding. It is announced as a heading.
class HeroHeader extends StatelessWidget {
  /// Creates a header showing [child].
  const HeroHeader({super.key, required Widget this.child, this.style})
    : data = null;

  /// Creates a header showing [data].
  const HeroHeader.text(String this.data, {super.key, this.style})
    : child = null;

  /// The content (text widgets inherit the header style).
  final Widget? child;

  /// The header text, for [HeroHeader.text].
  final String? data;

  /// Style merged over the header style (the counterpart of `className`).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle textStyle = theme.typography
        .style(HeroFontSize.xs, weight: HeroTypography.medium)
        .copyWith(color: theme.colors.muted)
        .merge(style?.copyWith(inherit: true));
    final String? data = this.data;
    return Semantics(
      header: true,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: theme.spacing(2),
          end: theme.spacing(2),
          top: theme.spacing(1.5),
          bottom: theme.spacing(1),
        ),
        child: data != null
            ? Text(data, style: textStyle, textAlign: TextAlign.start)
            : DefaultTextStyle.merge(
                style: textStyle,
                textAlign: TextAlign.start,
                child: child!,
              ),
      ),
    );
  }
}

/// React Aria's `ListBoxLoadMoreItem`: a sentinel at the end of a
/// [HeroListBox] that asks for more items when it scrolls into view.
///
/// [onLoadMore] runs once the sentinel is within [scrollOffset] viewport
/// heights of the visible area and again each time loading finished while
/// it is still near. While [isLoading] it shows [child], by default a
/// small spinner.
class HeroListBoxLoadMoreItem extends StatefulWidget {
  /// Creates a load-more sentinel.
  const HeroListBoxLoadMoreItem({
    super.key,
    this.isLoading = false,
    this.onLoadMore,
    this.scrollOffset = 1,
    this.child,
  });

  /// Whether more items are being loaded.
  final bool isLoading;

  /// Called to load more items.
  final VoidCallback? onLoadMore;

  /// How close to the visible area, in viewport heights, loading starts.
  final double scrollOffset;

  /// Shown while [isLoading]; defaults to a small spinner.
  final Widget? child;

  @override
  State<HeroListBoxLoadMoreItem> createState() =>
      _HeroListBoxLoadMoreItemState();
}

class _HeroListBoxLoadMoreItemState extends State<HeroListBoxLoadMoreItem> {
  ScrollPosition? _position;
  bool _requested = false;
  bool _checkScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ScrollPosition? position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_check);
      _position = position;
      _position?.addListener(_check);
    }
  }

  @override
  void didUpdateWidget(HeroListBoxLoadMoreItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A finished load allows the next one.
    if (oldWidget.isLoading && !widget.isLoading) _requested = false;
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }

  void _scheduleCheck() {
    if (_checkScheduled) return;
    _checkScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      _check();
    }, debugLabel: 'HeroListBoxLoadMoreItem.check');
  }

  void _check() {
    if (!mounted || widget.isLoading || _requested) return;
    final VoidCallback? onLoadMore = widget.onLoadMore;
    if (onLoadMore == null || !_isNear()) return;
    _requested = true;
    onLoadMore();
  }

  bool _isNear() {
    final RenderObject? object = context.findRenderObject();
    if (object == null || !object.attached) return false;
    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(
      object,
    );
    final ScrollPosition? position = _position;
    if (viewport == null || position == null || !position.hasPixels) {
      return true;
    }
    final double reveal = viewport.getOffsetToReveal(object, 1).offset;
    return position.pixels + position.viewportDimension * widget.scrollOffset >=
        reveal;
  }

  @override
  Widget build(BuildContext context) {
    _scheduleCheck();
    if (!widget.isLoading) return const SizedBox.shrink();
    final HeroThemeData theme = HeroTheme.of(context);
    return widget.child ??
        Padding(
          padding: EdgeInsets.symmetric(vertical: theme.spacing(2)),
          child: const Center(child: HeroSpinner(size: HeroSpinnerSize.sm)),
        );
  }
}
