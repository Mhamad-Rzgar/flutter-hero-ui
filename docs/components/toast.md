# Toast

Display temporary notifications and messages to users with automatic dismissal and customizable
placement.

HeroUI docs: [heroui.com/en/docs/react/components/toast](https://heroui.com/en/docs/react/components/toast)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Setup

Render the provider once around the app so toasts show above every page and modal:

```dart
HeroApp(
  builder: (context, child) => HeroToastProvider(child: child!),
  home: const HomePage(),
)
```

## Usage

```dart
HeroButton(
  onPressed: () {
    late final String id;
    id = heroToast(
      'You have been invited to join a team',
      description: 'Bob sent you an invitation to join HeroUI team',
      indicator: const HeroIcon(HeroIcons.persons),
      action: HeroToastAction(
        label: 'Dismiss',
        variant: HeroButtonVariant.tertiary,
        onPressed: () => heroToast.close(id),
      ),
    );
  },
  child: const Text('Show toast'),
)
```

`HeroToast.show(context, 'Saved')` does the same on the queue of the nearest provider and adds
a region to the root overlay when none renders that queue.

## Anatomy

```dart
HeroToastProvider(                      // Toast.Provider (region)
  builder: (context, toast) => HeroToast(    // Toast
    variant: toast.data.variant,
    children: [
      HeroToastIndicator(),               // Toast.Indicator
      HeroToastContent(children: [        // Toast.Content
        HeroToastTitle(child: ...),       // Toast.Title
        HeroToastDescription(child: ...), // Toast.Description
      ]),
      HeroToastActionButton(child: ...),  // Toast.ActionButton
      const HeroToastCloseButton(),       // Toast.CloseButton
    ],
  ),
)
```

| HeroUI | Flutter |
| --- | --- |
| `ToastQueue` | `HeroToastQueue` |
| `toast()` / `toast.success/info/warning/danger/promise/update/close/clear/pauseAll/resumeAll` | `heroToast` (a `HeroToaster` on `heroToastQueue`) with the same methods |
| `QueuedToast` / `ToastContentValue` | `HeroQueuedToast` / `HeroToastData` |
| `actionProps` | `HeroToastAction(label, onPressed, variant, style)` |

## Variants

| `HeroToastVariant` | Title | Indicator |
| --- | --- | --- |
| `standard` (default) | `overlayForeground` | info, `overlayForeground` |
| `accent` (`heroToast.info`) | `accentSoftForeground` | info, `overlayForeground` |
| `success` | `successSoftForeground` | success, `successSoftForeground` |
| `warning` | `warningSoftForeground` | warning, `warningSoftForeground` |
| `danger` | `dangerSoftForeground` | danger, `dangerSoftForeground` |

## Look and layout

- Toast: `surface` card, overlay shadow, 24 px corners, 16 × 12 padding, row with 6 px gaps.
  Indicator 16 px in a 24 px box (a spinner while loading); title 14/20 medium; description 14
  `muted`.
- The action button sits at the end of the row from 768 px and below the text (8 px above it)
  on touch layouts.
- The close button (20 px, radius 10) is pinned just outside the top end corner and appears
  while the pointer hovers the front toast (or any toast of an expanded stack).
- Region: 16 px from the screen edges (plus the safe area and the keyboard), `width` 460 from
  640 px, the screen width minus 32 below.

## Stacking and motion

- Collapsed: older toasts peek out 12 px (`gap`) behind the newest, each 5% smaller
  (`scaleFactor`) and as tall as the front toast, their content hidden.
- Expanded (pointer hover, keyboard focus or `isExpanded`, with at least two toasts): toasts
  fan out with 12 px gaps; the gaps belong to the toasts, so moving between them keeps the stack
  open. Escape folds it.
- Toasts beyond `maxVisibleToasts` (3) fade out but keep counting down.
- A new toast slides in from one toast height beyond the edge over 350 ms `ease-out-fluid`;
  toasts move and resize over 350 ms and fade over 150 ms. The front toast exits by sliding back
  over 250 ms; the others shrink to 96% over 200 ms. A settled promise icon fades in and zooms
  from 92%. Nothing animates under reduced motion.

## Timers

Toasts close after 4 s (`timeout`; `Duration.zero` keeps them open). A closing toast stays mounted
for the queue's `exitDuration` (300 ms) and `onClose` fires when it starts closing. Every
countdown pauses while the stack is hovered or focused, while the app is in the background and
between `pauseAll` and `resumeAll`.

## Examples

### Placements and custom queues

```dart
final errors = HeroToastQueue(maxVisibleToasts: 3);

HeroToastProvider(placement: HeroToastPlacement.bottomStart, queue: errors);

errors.add(const HeroToastData(
  title: 'Error occurred',
  description: 'Failed to save changes',
  variant: HeroToastVariant.danger,
));
```

Placements: `topStart`, `top`, `topEnd`, `bottomStart`, `bottom` (default), `bottomEnd`
(`start`/`end` follow the reading direction).

### Expanded stack

```dart
HeroToastProvider(queue: queue, isExpanded: true)
```

### Simple toasts and custom indicators

```dart
heroToast('Simple message');
heroToast.success('Operation completed');
heroToast.info('New update available');
heroToast.warning('Please check your settings');
heroToast.danger('Something went wrong');
heroToast('Custom icon indicator', indicator: const HeroIcon(HeroIcons.star));
```

### Custom toast rendering

```dart
HeroToastProvider(
  queue: queue,
  builder: (context, toast) => HeroToast(
    variant: toast.data.variant,
    borderRadius: 12,
    side: BorderSide(color: theme.colors.border),
    children: [
      HeroToastContent(children: [
        HeroToastTitle(child: Text(toast.data.title!)),
      ]),
      // Positioned children are placed over the card.
      const PositionedDirectional(
        end: 8,
        top: 0,
        bottom: 0,
        child: Center(child: HeroToastCloseButton(alwaysVisible: true)),
      ),
    ],
  ),
)
```

### Promise and loading

```dart
heroToast.promise<User>(
  fetchUser(),
  loading: 'Loading user...',
  success: (user) => 'Welcome back, ${user.name}!',
  error: (_) => 'Failed to fetch user',
);

final id = heroToast('Saving changes...', isLoading: true, timeout: Duration.zero);
// Later:
heroToast.update(id, 'Saved', variant: HeroToastVariant.success);
```

`update` keeps the key and position; a null `timeout` keeps the current countdown.

### Callbacks

```dart
heroToast(
  'File saved',
  timeout: const Duration(seconds: 3),
  onClose: () => debugPrint('closed'),
);
```

## Accessibility

- The region is a labelled landmark (`SemanticsRole.region`, "Notifications" by default); each
  toast is a live region, so assistive technologies announce new and updated toasts.
- Alt+T (`hotkey`) focuses the region and expands the stack; Tab moves between toasts and their
  buttons; Escape folds the stack. When a focused toast closes, keyboard focus moves to the
  nearest remaining toast.
- Countdowns pause while the stack is hovered or focused, so there is time to read and act.
- The close button also appears while it has keyboard focus.

## API

### HeroToastProvider

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | App content; without it the region renders over the nearest overlay. |
| `queue` | `HeroToastQueue?` | `heroToastQueue` | Queue to render. |
| `placement` | `HeroToastPlacement` | `bottom` | Region position. |
| `gap` | `double?` | 12 | Gap between toasts. |
| `isExpanded` | `bool` | `false` | Keep the stack expanded (does not pause timers). |
| `maxVisibleToasts` | `int?` | queue's, then 3 | Toasts shown at a time. |
| `hotkey` | `ShortcutActivator?` | Alt+T | Focuses the region; null disables it. |
| `scaleFactor` | `double` | `0.05` | Shrink per toast behind the front one. |
| `width` | `double?` | 460 | Toast width from 640 px. |
| `builder` | `HeroToastBuilder?` | HeroUI layout | Custom toast rendering. |
| `semanticLabel` | `String` | `'Notifications'` | Region label. |

### HeroToastQueue

| Member | Description |
| --- | --- |
| `HeroToastQueue({maxVisibleToasts, exitDuration = 300 ms})` | Creates a queue. |
| `add(HeroToastData, {timeout, onClose})` → `String` | Adds a toast (4 s default timeout). |
| `update(key, data, {timeout, onClose})` → `bool` | Updates in place. |
| `close(key)`, `clear()` | Close one or all toasts. |
| `pauseAll()`, `resumeAll()` | Pause and resume every countdown. |
| `visibleToasts` | Toasts, newest first. |

### heroToast / HeroToaster

`heroToast(title, {description, indicator, showIndicator, variant, action, isLoading, timeout,
onClose})` → key; `success`, `info`, `warning`, `danger`, `update(key, title, ...)`,
`promise<T>(future, loading:, success:, error:)`, `close`, `clear`, `pauseAll`, `resumeAll`.
`HeroToaster(queue)` binds the same API to another queue.

### HeroToast

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `variant` | `HeroToastVariant` | `standard` | Title and indicator colors. |
| `children` | `List<Widget>` | `[]` | Parts; `Positioned` children overlay the card. |
| `backgroundColor` | `Color?` | `surface` | Fill. |
| `side` | `BorderSide` | none | Border. |
| `borderRadius` | `double?` | 24 | Corner radius. |
| `shadows` | `List<BoxShadow>?` | overlay shadow | Drop shadows. |
| `padding` | `EdgeInsetsGeometry?` | 16 × 12 | Padding. |

`HeroToast.show(context, title, {...})` → key.

### Parts

| Widget | Parameters | Description |
| --- | --- | --- |
| `HeroToastIndicator` | `variant`, `child` | Variant icon or custom icon/spinner. |
| `HeroToastContent` | `children` | Text column. |
| `HeroToastTitle` | `child` | 14/20 medium, variant color. |
| `HeroToastDescription` | `child` | 14 `muted`. |
| `HeroToastActionButton` | `child`, `onPressed`, `variant`, `size`, `style` | `HeroButton`. |
| `HeroToastCloseButton` | `onPressed`, `semanticLabel`, `style`, `alwaysVisible` | Closes the toast. |
