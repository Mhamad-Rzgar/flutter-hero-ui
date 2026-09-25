/// HeroUI's Modal: a dialog overlay for focused interactions, and the
/// modal route shared by AlertDialog and Drawer.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import 'modal_parts.dart';
import 'modal_route.dart';

export 'dialog_layout.dart';
export 'modal_parts.dart';
export 'modal_route.dart';
export 'overlay_surface.dart';

/// A dialog overlay for focused user interactions and important content.
///
/// ```dart
/// HeroModal(
///   trigger: const HeroButton(
///     variant: HeroButtonVariant.secondary,
///     child: Text('Open Modal'),
///   ),
///   child: HeroModalBackdrop(
///     child: HeroModalContainer(
///       child: HeroModalDialog(
///         children: <Widget>[
///           const HeroModalCloseTrigger(),
///           HeroModalHeader(children: <Widget>[
///             const HeroModalHeading(child: Text('Welcome to HeroUI')),
///           ]),
///           const HeroModalBody(child: Text('A beautiful, fast UI library.')),
///           HeroModalFooter(children: <Widget>[
///             const HeroButton(
///               slot: HeroButtonSlot.close,
///               child: Text('Continue'),
///             ),
///           ]),
///         ],
///       ),
///     ),
///   ),
/// )
/// ```
///
/// Pressing the [trigger] (any button or [HeroModalTrigger]) opens [child]
/// in a [HeroModalRoute]: the [HeroModalBackdrop] ([HeroBackdropVariant]
/// opaque, blur or transparent) covers the app, the [HeroModalContainer]
/// places the [HeroModalDialog] (auto placement is a bottom sheet below
/// 640 px and centered above) with its [HeroModalMotion] and
/// [HeroModalSize], and the dialog holds the header, body, footer and
/// close trigger.
///
/// The modal closes on Escape (unless `isKeyboardDismissDisabled`), on a
/// press outside the dialog (when `isDismissable`), from a
/// [HeroModalCloseTrigger], from buttons with
/// `slot: HeroButtonSlot.close` and from the `close` function of
/// [HeroModalDialog.builder]. Focus is trapped inside while it is open and
/// returns to the trigger afterwards.
///
/// The open state is uncontrolled ([defaultOpen]) or controlled with
/// [isOpen] and [onOpenChanged], or with a [HeroOverlayController]. Use
/// [HeroModal.show] to open a modal imperatively.
class HeroModal extends StatelessWidget {
  /// Creates a modal.
  const HeroModal({
    super.key,
    required this.child,
    this.trigger,
    this.isOpen,
    this.defaultOpen = false,
    this.onOpenChanged,
    this.controller,
    this.useRootNavigator = true,
  });

  /// The overlay: a [HeroModalBackdrop] holding a [HeroModalContainer].
  final Widget child;

  /// The widget that opens the modal when pressed, usually a `HeroButton`
  /// or a [HeroModalTrigger].
  final Widget? trigger;

  /// Controlled open state; defaults to the backdrop's `isOpen`.
  final bool? isOpen;

  /// Initial open state when uncontrolled.
  final bool defaultOpen;

  /// Called when the open state should change (`onOpenChange`).
  final ValueChanged<bool>? onOpenChanged;

  /// External open state (`useOverlayState`).
  final HeroOverlayController? controller;

  /// Whether to open in the root navigator; false opens in the nearest
  /// navigator, e.g. a [HeroOverlayHost].
  final bool useRootNavigator;

  /// Opens a modal and completes with the value it is closed with (or null
  /// when it is dismissed).
  ///
  /// [builder] returns the [HeroModalDialog]; its `close` argument closes
  /// the modal. The remaining arguments configure the backdrop and the
  /// container.
  ///
  /// ```dart
  /// final bool? confirmed = await HeroModal.show<bool>(
  ///   context,
  ///   builder: (context, close) => HeroModalDialog(children: <Widget>[...]),
  /// );
  /// ```
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget Function(BuildContext context, VoidCallback close) builder,
    HeroBackdropVariant backdropVariant = HeroBackdropVariant.opaque,
    HeroModalPlacement placement = HeroModalPlacement.auto,
    HeroModalScroll scroll = HeroModalScroll.inside,
    HeroModalSize size = HeroModalSize.md,
    bool isDismissable = true,
    bool isKeyboardDismissDisabled = false,
    bool useRootNavigator = true,
    RouteSettings? settings,
  }) {
    return showHeroModalRoute<T>(
      context,
      useRootNavigator: useRootNavigator,
      settings: settings,
      content: HeroModalBackdrop(
        variant: backdropVariant,
        isDismissable: isDismissable,
        isKeyboardDismissDisabled: isKeyboardDismissDisabled,
        child: HeroModalContainer(
          placement: placement,
          scroll: scroll,
          size: size,
          child: Builder(
            builder: (BuildContext context) => builder(
              context,
              () => HeroDialogScope.maybeOf(context)?.close(),
            ),
          ),
        ),
      ),
    );
  }

  /// Closes the modal (or other dialog) around [context] with [result].
  static void close(BuildContext context, [Object? result]) =>
      HeroDialogScope.maybeOf(context)?.close(result);

  @override
  Widget build(BuildContext context) {
    final Widget child = this.child;
    final HeroModalBackdrop? backdrop = child is HeroModalBackdrop
        ? child
        : null;
    final HeroModalAnimatedLayer? layer = child is HeroModalAnimatedLayer
        ? child as HeroModalAnimatedLayer
        : null;
    final ValueChanged<bool>? backdropChanged = backdrop?.onOpenChanged;
    return HeroModalHost(
      content: child,
      trigger: trigger,
      isOpen: isOpen ?? backdrop?.isOpen,
      defaultOpen: defaultOpen,
      onOpenChanged: onOpenChanged == null && backdropChanged == null
          ? null
          : (bool value) {
              onOpenChanged?.call(value);
              backdropChanged?.call(value);
            },
      controller: controller,
      transitionDuration: layer?.enterDuration ?? HeroMotion.slow,
      reverseTransitionDuration: layer?.exitDuration ?? HeroMotion.fast,
      useRootNavigator: useRootNavigator,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('isOpen', value: isOpen, ifTrue: 'open'))
      ..add(FlagProperty('defaultOpen', value: defaultOpen))
      ..add(
        DiagnosticsProperty<HeroOverlayController>(
          'controller',
          controller,
          defaultValue: null,
        ),
      );
  }
}
