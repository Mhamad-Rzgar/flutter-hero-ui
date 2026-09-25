import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The role of a part inside a dialog-like panel (modal, alert dialog,
/// drawer), which decides its placement and the spacing around it.
enum HeroDialogPartKind {
  /// The title area (`*.Header`).
  header,

  /// The main content (`*.Body`); it takes the remaining height and scrolls
  /// when the panel is height-constrained.
  body,

  /// The actions row (`*.Footer`).
  footer,

  /// The close button pinned to the top end corner (`*.CloseTrigger`).
  closeTrigger,

  /// The drag handle of a drawer (`Drawer.Handle`).
  handle,
}

/// Base class of the parts a [HeroDialogLayout] arranges.
abstract class HeroDialogPart extends StatelessWidget {
  /// Creates a dialog part.
  const HeroDialogPart({super.key});

  /// The role of this part.
  HeroDialogPartKind get kind;
}

/// Layout information a [HeroDialogLayout] shares with its parts.
class HeroDialogLayoutScope extends InheritedWidget {
  /// Creates the scope.
  const HeroDialogLayoutScope({
    super.key,
    required this.scrollableBody,
    required super.child,
  });

  /// Whether the body scrolls inside the panel (`overflow-y-auto`).
  final bool scrollableBody;

  /// The nearest scope, or null.
  static HeroDialogLayoutScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroDialogLayoutScope>();

  @override
  bool updateShouldNotify(HeroDialogLayoutScope oldWidget) =>
      scrollableBody != oldWidget.scrollableBody;
}

/// Arranges the parts of a dialog-like panel the way HeroUI's CSS does.
///
/// * Header, body and footer stack in a column with HeroUI's adjacent
///   spacing: header → body 8, header → footer 20, body → footer 20,
///   handle → header/body 0.
/// * The body takes the remaining height ([fillHeight]) or shrinks to its
///   content and scrolls when the panel is height-constrained
///   ([scrollableBody]). It extends 3 px into the panel padding on each
///   side with 3 px of inner padding (`-m-[3px] p-[3px]`), so focus rings
///   of its content are not clipped.
/// * Close triggers are pinned 16 px from the top and end edges of the
///   panel (`absolute top-4 end-4`) above the content.
/// * [Positioned] and [PositionedDirectional] children are laid out
///   against the panel behind the content (decorations).
class HeroDialogLayout extends StatelessWidget {
  /// Creates a dialog layout.
  const HeroDialogLayout({
    super.key,
    required this.children,
    required this.padding,
    this.scrollableBody = true,
    this.fillHeight = false,
  });

  /// The parts, in order.
  final List<Widget> children;

  /// The panel padding (`p-6`).
  final EdgeInsets padding;

  /// Whether the body scrolls inside the panel.
  final bool scrollableBody;

  /// Whether the panel has a definite height the body grows into.
  final bool fillHeight;

  /// The spacing HeroUI puts between two adjacent parts.
  static double spacingBetween(
    HeroThemeData theme,
    HeroDialogPartKind? previous,
    HeroDialogPartKind? next,
  ) {
    return switch ((previous, next)) {
      (HeroDialogPartKind.header, HeroDialogPartKind.body) => theme.spacing(2),
      (HeroDialogPartKind.header, HeroDialogPartKind.footer) => theme.spacing(
        5,
      ),
      (HeroDialogPartKind.body, HeroDialogPartKind.footer) => theme.spacing(5),
      _ => 0,
    };
  }

  static HeroDialogPartKind? _kindOf(Widget widget) =>
      widget is HeroDialogPart ? widget.kind : null;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    // The body's negative margin: the column is 3 px wider on each side and
    // every other part is inset by those 3 px again.
    final double bleed = theme.spacing(0.75);
    final List<Widget> background = <Widget>[];
    final List<Widget> overlay = <Widget>[];
    final List<Widget> flow = <Widget>[];
    HeroDialogPartKind? previous;
    bool first = true;
    for (final Widget child in children) {
      if (child is Positioned || child is PositionedDirectional) {
        background.add(child);
        continue;
      }
      final HeroDialogPartKind? kind = _kindOf(child);
      if (kind == HeroDialogPartKind.closeTrigger) {
        overlay.add(
          PositionedDirectional(
            top: theme.spacing(4),
            end: theme.spacing(4),
            child: child,
          ),
        );
        continue;
      }
      if (!first) {
        final double gap = spacingBetween(theme, previous, kind);
        if (gap > 0) flow.add(SizedBox(height: gap));
      }
      first = false;
      previous = kind;
      if (kind == HeroDialogPartKind.body) {
        flow.add(
          scrollableBody
              ? Flexible(
                  fit: fillHeight ? FlexFit.tight : FlexFit.loose,
                  child: child,
                )
              : child,
        );
      } else {
        flow.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: bleed),
            child: child,
          ),
        );
      }
    }

    final Widget column = Padding(
      padding: padding.copyWith(
        left: padding.left - bleed,
        right: padding.right - bleed,
      ),
      child: Column(
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: flow,
      ),
    );
    return HeroDialogLayoutScope(
      scrollableBody: scrollableBody,
      child: background.isEmpty && overlay.isEmpty
          ? column
          : Stack(
              fit: fillHeight ? StackFit.expand : StackFit.loose,
              children: <Widget>[...background, column, ...overlay],
            ),
    );
  }
}
