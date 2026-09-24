import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

/// A round icon button used by the gallery chrome.
class GalleryIconButton extends StatelessWidget {
  const GalleryIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
  });

  final HeroIconData icon;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroInteractable(
      onPressed: onPressed,
      semanticsLabel: label,
      builder: (BuildContext context, HeroInteractionState state, _) {
        final OutlinedBorder shape = theme.shapeAll(theme.radii.full);
        return HeroFocusRing(
          visible: state.isFocusVisible,
          shape: shape,
          child: HeroPressScale(
            pressed: state.isPressed,
            child: AnimatedContainer(
              duration: HeroMotion.fast,
              width: 36,
              height: 36,
              decoration: ShapeDecoration(
                color: state.isHovered || state.isPressed
                    ? theme.colors.defaultColor
                    : const Color(0x00000000),
                shape: shape,
              ),
              alignment: Alignment.center,
              child: HeroIcon(icon, size: 18, color: theme.colors.foreground),
            ),
          ),
        );
      },
    );
  }
}

/// The gallery's navigation bar.
class GalleryTopBar extends StatelessWidget {
  const GalleryTopBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const <Widget>[],
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(bottom: BorderSide(color: theme.colors.separator)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: padding.top),
        child: SizedBox(
          height: 56,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 8),
              if (leading != null) leading! else const SizedBox(width: 8),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography
                      .style(HeroFontSize.lg, weight: HeroTypography.semibold)
                      .copyWith(color: theme.colors.foreground),
                ),
              ),
              ...actions,
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// A selectable pill used by playground controls.
class GalleryPill extends StatelessWidget {
  const GalleryPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroInteractable(
      onPressed: onPressed,
      isSelected: selected,
      isToggle: true,
      builder: (BuildContext context, HeroInteractionState state, _) {
        final OutlinedBorder shape = theme.shapeAll(theme.radii.full);
        final Color bg = selected
            ? theme.colors.foreground
            : state.isHovered
            ? theme.colors.defaultHover
            : theme.colors.defaultColor;
        return HeroFocusRing(
          visible: state.isFocusVisible,
          shape: shape,
          child: AnimatedContainer(
            duration: HeroMotion.fast,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: ShapeDecoration(color: bg, shape: shape),
            child: Text(
              label,
              style: theme.typography
                  .style(HeroFontSize.xs, weight: HeroTypography.medium)
                  .copyWith(
                    color: selected
                        ? theme.colors.background
                        : theme.colors.foreground,
                  ),
            ),
          ),
        );
      },
    );
  }
}

/// A titled section of a gallery page.
class GallerySection extends StatelessWidget {
  const GallerySection({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.trailing,
  });

  final String title;
  final String? description;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: theme.typography.h5.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          if (description != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              description!,
              style: theme.typography.sm.copyWith(color: theme.colors.muted),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// A preview surface for an example, with a "Code" action.
class DemoCard extends StatelessWidget {
  const DemoCard({super.key, required this.child, required this.code});

  final Widget child;
  final String code;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final OutlinedBorder shape = theme.shapeAll(
      theme.radii.xl3,
      side: BorderSide(color: theme.colors.border),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(color: theme.colors.surface, shape: shape),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            child: Center(child: child),
          ),
          PositionedDirectional(
            top: 6,
            end: 6,
            child: GalleryIconButton(
              icon: HeroIcons.code,
              label: 'View code',
              onPressed: () => showCodeSheet(context, code),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens a bottom sheet showing [code].
Future<void> showCodeSheet(BuildContext context, String code) {
  return showGallerySheet<void>(
    context,
    title: 'Code',
    builder: (BuildContext context) => CodeView(code: code),
  );
}

/// Opens an iOS-style bottom sheet.
Future<T?> showGallerySheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
}) {
  final HeroThemeData theme = HeroTheme.of(context);
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: theme.colors.backdrop,
      transitionDuration: HeroMotion.slower,
      reverseTransitionDuration: HeroMotion.slow,
      pageBuilder: (BuildContext context, _, _) {
        final HeroThemeData theme = HeroTheme.of(context);
        final double maxHeight = MediaQuery.sizeOf(context).height * 0.85;
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 720, maxHeight: maxHeight),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: theme.colors.overlay,
                shape: theme.shape(
                  BorderRadius.vertical(top: Radius.circular(theme.radii.xl3)),
                ),
                shadows: theme.shadows.overlay.boxShadows,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: ShapeDecoration(
                          color: theme.colors.defaultColor,
                          shape: theme.shapeAll(theme.radii.full),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              title,
                              style: theme.typography.h5.copyWith(
                                color: theme.colors.overlayForeground,
                              ),
                            ),
                          ),
                          GalleryIconButton(
                            icon: HeroIcons.close,
                            label: 'Close',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Flexible(child: builder(context)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final Animation<double> curved = CurvedAnimation(
              parent: animation,
              curve: HeroMotion.easeOutFluid,
              reverseCurve: HeroMotion.easeOut,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          },
    ),
  );
}

/// Dart source with light syntax highlighting and a copy button.
class CodeView extends StatelessWidget {
  const CodeView({super.key, required this.code});

  final String code;

  static final RegExp _token = RegExp(
    r"(//[^\n]*)|('(?:[^'\\]|\\.)*')|\b(const|final|var|return|new|true|false|null|if|else|for|in|void|class|extends|import|static|await|async)\b|\b([A-Z][A-Za-z0-9_]*)\b|\b(\d+(?:\.\d+)?)\b",
  );

  List<TextSpan> _highlight(HeroThemeData theme) {
    final List<TextSpan> spans = <TextSpan>[];
    int last = 0;
    for (final RegExpMatch m in _token.allMatches(code)) {
      if (m.start > last) {
        spans.add(TextSpan(text: code.substring(last, m.start)));
      }
      final Color color;
      if (m.group(1) != null) {
        color = theme.colors.muted;
      } else if (m.group(2) != null) {
        color = theme.colors.successSoftForeground;
      } else if (m.group(3) != null) {
        color = theme.colors.dangerSoftForeground;
      } else if (m.group(4) != null) {
        color = theme.colors.accentSoftForeground;
      } else {
        color = theme.colors.warningSoftForeground;
      }
      spans.add(
        TextSpan(
          text: m.group(0),
          style: TextStyle(color: color),
        ),
      );
      last = m.end;
    }
    if (last < code.length) spans.add(TextSpan(text: code.substring(last)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: theme.colors.defaultColor,
          shape: theme.shapeAll(theme.radii.xl),
        ),
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text.rich(
                  TextSpan(children: _highlight(theme)),
                  style: theme.typography
                      .style(HeroFontSize.sm, mono: true, lineHeight: 22)
                      .copyWith(color: theme.colors.foreground),
                ),
              ),
            ),
            PositionedDirectional(
              top: 4,
              end: 4,
              child: GalleryIconButton(
                icon: HeroIcons.copy,
                label: 'Copy code',
                onPressed: () => Clipboard.setData(ClipboardData(text: code)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A minimal search box for the component index.
class GallerySearchBox extends StatefulWidget {
  const GallerySearchBox({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<GallerySearchBox> createState() => _GallerySearchBoxState();
}

class _GallerySearchBoxState extends State<GallerySearchBox> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle style = theme.typography.sm.copyWith(
      color: theme.colors.fieldForeground,
    );
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[_controller, _focus]),
      builder: (BuildContext context, _) {
        final OutlinedBorder shape = theme.shapeAll(theme.radii.field);
        return HeroFocusRing(
          visible: _focus.hasFocus,
          offset: 0,
          shape: shape,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: ShapeDecoration(
              color: theme.colors.fieldBackground,
              shape: shape,
              shadows: theme.shadows.field.boxShadows,
            ),
            child: Row(
              children: <Widget>[
                HeroIcon(
                  HeroIcons.search,
                  color: theme.colors.fieldPlaceholder,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: <Widget>[
                      if (_controller.text.isEmpty)
                        Text(
                          'Search components',
                          style: style.copyWith(
                            color: theme.colors.fieldPlaceholder,
                          ),
                        ),
                      EditableText(
                        controller: _controller,
                        focusNode: _focus,
                        style: style,
                        cursorColor: theme.colors.accent,
                        backgroundCursorColor: theme.colors.muted,
                        onChanged: widget.onChanged,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
