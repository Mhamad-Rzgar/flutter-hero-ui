import 'dart:async';

import 'package:flutter/widgets.dart';

import '../button/button.dart';

/// The color scheme of a toast (`variant`).
enum HeroToastVariant {
  /// `overlay-foreground` title and info icon, the default.
  standard,

  /// Accent title (`toast.info`).
  accent,

  /// Success title and icon.
  success,

  /// Warning title and icon.
  warning,

  /// Danger title and icon.
  danger,
}

/// Where the toast region sits on screen (`Toast.Provider` `placement`).
///
/// `start` and `end` follow the reading direction.
enum HeroToastPlacement {
  /// Top start corner.
  topStart,

  /// Top center.
  top,

  /// Top end corner.
  topEnd,

  /// Bottom start corner.
  bottomStart,

  /// Bottom center, the default.
  bottom,

  /// Bottom end corner.
  bottomEnd;

  /// Whether toasts stack from the top edge downwards.
  bool get isTop => this == topStart || this == top || this == topEnd;
}

/// The action button of a toast (HeroUI's `actionProps`).
@immutable
class HeroToastAction {
  /// Creates an action.
  const HeroToastAction({
    required this.label,
    this.onPressed,
    this.variant = HeroButtonVariant.primary,
    this.style,
  });

  /// The button label.
  final String label;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// The button variant.
  final HeroButtonVariant variant;

  /// Button style overrides (e.g. a success fill).
  final HeroButtonStyle? style;
}

/// The content of a queued toast (HeroUI's `ToastContentValue`).
@immutable
class HeroToastData {
  /// Creates toast content.
  const HeroToastData({
    this.title,
    this.description,
    this.indicator,
    this.showIndicator = true,
    this.variant = HeroToastVariant.standard,
    this.action,
    this.isLoading = false,
  });

  /// The title.
  final String? title;

  /// The description below the title.
  final String? description;

  /// Replaces the variant's icon (e.g. a [HeroIcon]).
  final Widget? indicator;

  /// Whether to show an indicator at all (`indicator: null` hides it).
  final bool showIndicator;

  /// The color scheme.
  final HeroToastVariant variant;

  /// An optional action button.
  final HeroToastAction? action;

  /// Shows a spinner in place of the indicator.
  final bool isLoading;
}

/// A toast in a [HeroToastQueue].
class HeroQueuedToast {
  HeroQueuedToast._(this.key, this.data, this.timeout, this.onClose);

  /// A unique key within the queue.
  final String key;

  /// The content.
  HeroToastData data;

  /// The auto-dismiss delay; [Duration.zero] keeps the toast open.
  Duration timeout;

  /// Called when the toast is dismissed (its exit animation may still run).
  VoidCallback? onClose;

  _HeroToastTimer? _timer;
  bool _isExiting = false;

  /// Whether the toast is playing its exit animation.
  bool get isExiting => _isExiting;
}

/// A countdown that can be paused and resumed.
class _HeroToastTimer {
  _HeroToastTimer(this._remaining, this._onFire);

  Duration _remaining;
  final VoidCallback _onFire;
  Timer? _timer;
  Stopwatch? _stopwatch;

  bool get isRunning => _timer != null;

  void resume() {
    if (_timer != null || _remaining <= Duration.zero) return;
    _stopwatch = Stopwatch()..start();
    _timer = Timer(_remaining, () {
      _timer = null;
      _remaining = Duration.zero;
      _onFire();
    });
  }

  void pause() {
    final Timer? timer = _timer;
    if (timer == null) return;
    timer.cancel();
    _timer = null;
    _remaining -= _stopwatch?.elapsed ?? Duration.zero;
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Manages toasts outside the widget tree so they can be shown from
/// anywhere (HeroUI's `ToastQueue`).
///
/// Toasts close after their timeout (4 s by default; [Duration.zero] keeps
/// them open), stay mounted for [exitDuration] while they animate out, and
/// can be updated in place. Every running countdown pauses while any
/// source suspends the timers: the region while it is hovered or focused,
/// the app while it is in the background, and [pauseAll].
///
/// ```dart
/// final HeroToastQueue queue = HeroToastQueue(maxVisibleToasts: 2);
/// queue.add(const HeroToastData(title: 'Saved'));
/// HeroToastProvider(queue: queue);
/// ```
class HeroToastQueue extends ChangeNotifier {
  /// Creates a queue.
  HeroToastQueue({
    this.maxVisibleToasts,
    this.exitDuration = const Duration(milliseconds: 300),
  });

  /// The number of toasts shown at a time (older ones fade out but keep
  /// counting down); null uses the provider's value (3 by default).
  final int? maxVisibleToasts;

  /// How long a closing toast stays mounted for its exit animation.
  final Duration exitDuration;

  /// The auto-dismiss delay used when none is given.
  static const Duration defaultTimeout = Duration(milliseconds: 4000);

  final List<HeroQueuedToast> _toasts = <HeroQueuedToast>[];
  final Map<String, Timer> _exitTimers = <String, Timer>{};
  final Set<Object> _suspensions = <Object>{};
  final List<Object> _regions = <Object>[];
  int _nextKey = 0;
  bool _disposed = false;

  /// The toasts, newest first, including those animating out.
  List<HeroQueuedToast> get visibleToasts =>
      List<HeroQueuedToast>.unmodifiable(_toasts);

  /// Whether the timers are suspended.
  bool get isPaused => _suspensions.isNotEmpty;

  /// Adds a toast and returns its key. [timeout] defaults to 4 s;
  /// [Duration.zero] keeps the toast open.
  String add(HeroToastData data, {Duration? timeout, VoidCallback? onClose}) {
    final HeroQueuedToast toast = HeroQueuedToast._(
      'toast-${_nextKey++}',
      data,
      timeout ?? defaultTimeout,
      onClose,
    );
    _toasts.insert(0, toast);
    _startTimer(toast);
    _notify();
    return toast.key;
  }

  void _startTimer(HeroQueuedToast toast) {
    toast._timer?.cancel();
    toast._timer = null;
    if (toast.timeout <= Duration.zero) return;
    final _HeroToastTimer timer = _HeroToastTimer(
      toast.timeout,
      () => close(toast.key),
    );
    toast._timer = timer;
    if (!isPaused) timer.resume();
  }

  HeroQueuedToast? _find(String key) {
    for (final HeroQueuedToast toast in _toasts) {
      if (toast.key == key) return toast;
    }
    return null;
  }

  /// Updates a toast in place (same key, same position) and returns whether
  /// it still existed. A [timeout] restarts the countdown ([Duration.zero]
  /// keeps it open); null keeps the current countdown. [onClose] replaces
  /// the handler when [replaceOnClose] is true.
  bool update(
    String key,
    HeroToastData data, {
    Duration? timeout,
    VoidCallback? onClose,
    bool replaceOnClose = false,
  }) {
    final HeroQueuedToast? toast = _find(key);
    if (toast == null || toast._isExiting) return false;
    toast.data = data;
    if (replaceOnClose || onClose != null) toast.onClose = onClose;
    if (timeout != null) {
      toast.timeout = timeout;
      _startTimer(toast);
    }
    _notify();
    return true;
  }

  /// Closes a toast: [HeroQueuedToast.onClose] fires now and the toast is
  /// removed after [exitDuration].
  void close(String key) {
    final HeroQueuedToast? toast = _find(key);
    if (toast == null || toast._isExiting) return;
    toast._timer?.cancel();
    toast._timer = null;
    final VoidCallback? onClose = toast.onClose;
    toast.onClose = null;
    if (exitDuration <= Duration.zero) {
      _toasts.remove(toast);
    } else {
      toast._isExiting = true;
      _exitTimers[key] = Timer(exitDuration, () {
        _exitTimers.remove(key);
        _toasts.remove(toast);
        _notify();
      });
    }
    _notify();
    onClose?.call();
  }

  /// Closes every toast; each animates out and fires its `onClose`.
  void clear() {
    for (final HeroQueuedToast toast in List<HeroQueuedToast>.of(_toasts)) {
      close(toast.key);
    }
  }

  /// Pauses every countdown until [resumeAll].
  void pauseAll() => suspendTimers(#external);

  /// Resumes the countdowns paused by [pauseAll].
  void resumeAll() => resumeTimers(#external);

  /// Pauses every countdown while [source] is registered. Sources form a
  /// set: timers pause when the first one is added and resume when the last
  /// one is removed.
  void suspendTimers(Object source) {
    final bool wasEmpty = _suspensions.isEmpty;
    _suspensions.add(source);
    if (wasEmpty) {
      for (final HeroQueuedToast toast in _toasts) {
        toast._timer?.pause();
      }
    }
  }

  /// Removes a suspension [source]; see [suspendTimers].
  void resumeTimers(Object source) {
    _suspensions.remove(source);
    if (_suspensions.isEmpty) {
      for (final HeroQueuedToast toast in _toasts) {
        toast._timer?.resume();
      }
    }
  }

  /// Registers a region rendering this queue; only the first registered
  /// region renders the toasts.
  void attachRegion(Object region) {
    if (!_regions.contains(region)) _regions.add(region);
    _notify();
  }

  /// Unregisters a region.
  void detachRegion(Object region) {
    if (_regions.remove(region)) _notify();
  }

  /// Whether [region] is the one that renders this queue.
  bool isActiveRegion(Object region) =>
      _regions.isNotEmpty && identical(_regions.first, region);

  /// Whether any region renders this queue.
  bool get hasRegion => _regions.isNotEmpty;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final Timer timer in _exitTimers.values) {
      timer.cancel();
    }
    _exitTimers.clear();
    for (final HeroQueuedToast toast in _toasts) {
      toast._timer?.cancel();
    }
    super.dispose();
  }
}

/// A toast function bound to a queue (HeroUI's `toast`); [heroToast] uses
/// the default queue.
///
/// ```dart
/// heroToast('Simple message');
/// heroToast.success('Operation completed');
/// final String id = heroToast('Uploading...', isLoading: true,
///     timeout: Duration.zero);
/// heroToast.update(id, 'Uploaded', variant: HeroToastVariant.success);
/// heroToast.promise(save(), loading: 'Saving...',
///     success: (_) => 'Saved', error: (e) => '$e');
/// ```
class HeroToaster {
  /// Creates a toaster for [queue].
  const HeroToaster(this.queue);

  /// The queue toasts are added to.
  final HeroToastQueue queue;

  /// Shows a toast and returns its key.
  String call(
    String title, {
    String? description,
    Widget? indicator,
    bool showIndicator = true,
    HeroToastVariant variant = HeroToastVariant.standard,
    HeroToastAction? action,
    bool isLoading = false,
    Duration timeout = HeroToastQueue.defaultTimeout,
    VoidCallback? onClose,
  }) {
    return queue.add(
      HeroToastData(
        title: title,
        description: description,
        indicator: indicator,
        showIndicator: showIndicator,
        variant: variant,
        action: action,
        isLoading: isLoading,
      ),
      timeout: timeout,
      onClose: onClose,
    );
  }

  /// Shows a success toast.
  String success(
    String title, {
    String? description,
    Widget? indicator,
    HeroToastAction? action,
    Duration timeout = HeroToastQueue.defaultTimeout,
    VoidCallback? onClose,
  }) => call(
    title,
    description: description,
    indicator: indicator,
    variant: HeroToastVariant.success,
    action: action,
    timeout: timeout,
    onClose: onClose,
  );

  /// Shows an informational toast (the accent variant).
  String info(
    String title, {
    String? description,
    Widget? indicator,
    HeroToastAction? action,
    Duration timeout = HeroToastQueue.defaultTimeout,
    VoidCallback? onClose,
  }) => call(
    title,
    description: description,
    indicator: indicator,
    variant: HeroToastVariant.accent,
    action: action,
    timeout: timeout,
    onClose: onClose,
  );

  /// Shows a warning toast.
  String warning(
    String title, {
    String? description,
    Widget? indicator,
    HeroToastAction? action,
    Duration timeout = HeroToastQueue.defaultTimeout,
    VoidCallback? onClose,
  }) => call(
    title,
    description: description,
    indicator: indicator,
    variant: HeroToastVariant.warning,
    action: action,
    timeout: timeout,
    onClose: onClose,
  );

  /// Shows a danger toast.
  String danger(
    String title, {
    String? description,
    Widget? indicator,
    HeroToastAction? action,
    Duration timeout = HeroToastQueue.defaultTimeout,
    VoidCallback? onClose,
  }) => call(
    title,
    description: description,
    indicator: indicator,
    variant: HeroToastVariant.danger,
    action: action,
    timeout: timeout,
    onClose: onClose,
  );

  /// Updates a toast in place, or shows a new one when [key] no longer
  /// exists; returns the key in use. A null [timeout] keeps the current
  /// countdown.
  String update(
    String key,
    String title, {
    String? description,
    Widget? indicator,
    bool showIndicator = true,
    HeroToastVariant variant = HeroToastVariant.standard,
    HeroToastAction? action,
    bool isLoading = false,
    Duration? timeout,
    VoidCallback? onClose,
  }) {
    final HeroToastData data = HeroToastData(
      title: title,
      description: description,
      indicator: indicator,
      showIndicator: showIndicator,
      variant: variant,
      action: action,
      isLoading: isLoading,
    );
    if (queue.update(key, data, timeout: timeout, onClose: onClose)) {
      return key;
    }
    return queue.add(data, timeout: timeout, onClose: onClose);
  }

  /// Shows a loading toast that settles in place to a success or danger
  /// toast when [future] completes; the 4 s countdown starts then.
  String promise<T>(
    Future<T> future, {
    required String loading,
    required String Function(T value) success,
    required String Function(Object error) error,
  }) {
    final String key = queue.add(
      HeroToastData(title: loading, isLoading: true),
      timeout: Duration.zero,
    );
    future.then(
      (T value) => update(
        key,
        success(value),
        variant: HeroToastVariant.success,
        timeout: HeroToastQueue.defaultTimeout,
      ),
      onError: (Object e) => update(
        key,
        error(e),
        variant: HeroToastVariant.danger,
        timeout: HeroToastQueue.defaultTimeout,
      ),
    );
    return key;
  }

  /// Closes a toast.
  void close(String key) => queue.close(key);

  /// Closes every toast.
  void clear() => queue.clear();

  /// Pauses every countdown.
  void pauseAll() => queue.pauseAll();

  /// Resumes the countdowns paused by [pauseAll].
  void resumeAll() => queue.resumeAll();
}

/// The default toast queue, rendered by a `HeroToastProvider` without a
/// `queue`.
final HeroToastQueue heroToastQueue = HeroToastQueue();

/// Shows toasts on [heroToastQueue] (HeroUI's global `toast`).
final HeroToaster heroToast = HeroToaster(heroToastQueue);
