# Modal

Dialog overlay for focused user interactions and important content.

HeroUI docs: [heroui.com/en/docs/react/components/modal](https://heroui.com/en/docs/react/components/modal)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroModal(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Open Modal'),
  ),
  child: HeroModalBackdrop(
    child: HeroModalContainer(
      child: HeroModalDialog(
        maxWidth: 360,
        children: [
          const HeroModalCloseTrigger(),
          HeroModalHeader(children: [
            HeroModalIcon(
              backgroundColor: theme.colors.defaultColor,
              foregroundColor: theme.colors.foreground,
              child: const HeroIcon(HeroIcons.rocket),
            ),
            const HeroModalHeading(child: Text('Welcome to HeroUI')),
          ]),
          const HeroModalBody(
            child: Text(
              'A beautiful, fast, and modern UI library for building '
              'accessible and customizable applications with ease.',
            ),
          ),
          const HeroModalFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              fullWidth: true,
              child: Text('Continue'),
            ),
          ]),
        ],
      ),
    ),
  ),
)
```

## Anatomy

```dart
HeroModal(
  trigger: HeroButton(child: Text('Open Modal')),   // Modal trigger
  child: HeroModalBackdrop(                          // Modal.Backdrop
    child: HeroModalContainer(                       // Modal.Container
      child: HeroModalDialog(children: [             // Modal.Dialog
        HeroModalCloseTrigger(),                     // optional close button
        HeroModalHeader(children: [
          HeroModalIcon(child: ...),                 // optional icon
          HeroModalHeading(child: ...),
        ]),
        HeroModalBody(child: ...),
        HeroModalFooter(children: [...]),
      ]),
    ),
  ),
)
```

| HeroUI | Flutter |
| --- | --- |
| `Modal` | `HeroModal` (trigger + open state) |
| `Modal.Trigger` | `HeroModalTrigger` (custom pressable trigger) |
| `Modal.Backdrop` | `HeroModalBackdrop` |
| `Modal.Container` | `HeroModalContainer` |
| `Modal.Dialog` | `HeroModalDialog` |
| `Modal.Header` / `Heading` / `Icon` / `Body` / `Footer` | `HeroModalHeader` / `HeroModalHeading` / `HeroModalIcon` / `HeroModalBody` / `HeroModalFooter` |
| `Modal.CloseTrigger` | `HeroModalCloseTrigger` |
| `useOverlayState` | `HeroOverlayController` |

The modal opens in a `HeroModalRoute`, a Navigator `PopupRoute` (not a Material dialog) that
traps focus, blocks the page below and returns focus to the trigger when it closes.
`HeroAlertDialog` and `HeroDrawer` use the same route.

Any `HeroButton` (or `HeroModalTrigger`) passed as `trigger` opens the modal when pressed.
Inside the dialog, header, body and footer are spaced like HeroUI's CSS (header → body 8,
header → footer 20, body → footer 20). Close triggers are pinned 16 px from the top and end
edges; `Positioned` children are painted behind the content as decorations.

## Backdrop variants

| `HeroBackdropVariant` | Look |
| --- | --- |
| `opaque` (default) | `backdrop` token (black 50% light / 60% dark) |
| `blur` | `backdrop` token + 12 px blur of the page (`backdrop-blur-md`) |
| `transparent` | no fill; the page still cannot be used |

`color` and `decoration` (e.g. a gradient) replace the fill; the blur stays.

## Placement

| `HeroModalPlacement` | Below 640 px | From 640 px |
| --- | --- | --- |
| `auto` (default) | bottom (bottom-sheet style) | centered |
| `center` | centered | centered |
| `top` | top | top |
| `bottom` | bottom | bottom |

The container keeps 16 px from the edges below 640 px and 40 px above (the safe area wins
when it is larger). The visual viewport ends at the keyboard, so forms stay visible.

## Sizes

| `HeroModalSize` | Dialog width |
| --- | --- |
| `xs` | up to 320 |
| `sm` | up to 384 |
| `md` (default) | up to 448 |
| `lg` | up to 512 |
| `cover` | fills the container (16 / 40 px margins), keeps corners and shadow |
| `full` | fills the screen, no corners, no shadow, no margins |

`HeroModalDialog.maxWidth` overrides the cap (HeroUI's `sm:max-w-[360px]`).

## Scroll behaviour

| `HeroModalScroll` | Behaviour |
| --- | --- |
| `inside` (default) | the dialog stays on screen; the body scrolls between header and footer |
| `outside` | the dialog keeps its natural height and the backdrop scrolls |

## Motion

| Layer | Enter | Exit |
| --- | --- | --- |
| Backdrop | fade, 150 ms `ease-out` | fade, 100 ms `ease-out` |
| Container | fade, zoom from 105%, 4 px slide (from the bottom for auto/bottom below 640 px, from the top for top), 250 ms `ease-out-quad` | fade, zoom to 95%, 100 ms `ease-out-quad` |
| Container, `full` size | fade only | fade only |

`HeroModalMotion` on the backdrop and the container overrides durations, curves, scales and
offsets (see Custom Animations); `transitionBuilder` replaces the container transition.
Nothing animates when the platform asks for reduced motion.

## Examples

### Sizes

```dart
for (final size in HeroModalSize.values)
  HeroModal(
    trigger: HeroButton(
      variant: HeroButtonVariant.secondary,
      child: Text(size.name),
    ),
    child: HeroModalBackdrop(
      child: HeroModalContainer(
        size: size,
        child: HeroModalDialog(children: [...]),
      ),
    ),
  )
```

### Placement

```dart
HeroModalContainer(
  placement: HeroModalPlacement.top,
  child: HeroModalDialog(maxWidth: 360, children: [...]),
)
```

### Controlled state

```dart
// With a bool and setState.
HeroModalBackdrop(
  isOpen: isOpen,
  onOpenChanged: (value) => setState(() => isOpen = value),
  child: HeroModalContainer(child: HeroModalDialog(children: [...])),
)

// With HeroOverlayController.
final state = HeroOverlayController();
HeroButton(onPressed: state.open, child: const Text('Open Modal'));
HeroButton(onPressed: state.toggle, child: const Text('Toggle'));
HeroModal(
  controller: state,
  child: HeroModalBackdrop(child: ...),
)
```

In controlled mode a dismissal (Escape, backdrop, close buttons) only calls `onOpenChanged`
with `false`; the modal closes when the owner passes `isOpen: false`.

### Custom trigger

```dart
HeroModal(
  trigger: HeroModalTrigger(
    borderRadius: BorderRadius.circular(16),
    builder: (context, state) => AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: state.isHovered
            ? theme.colors.surfaceSecondary
            : theme.colors.surface,
        shape: theme.shapeAll(16),
      ),
      child: const Text('Settings'),
    ),
  ),
  child: HeroModalBackdrop(child: ...),
)
```

### Backdrop variants and custom backdrop

```dart
HeroModalBackdrop(
  variant: HeroBackdropVariant.blur,
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xCC000000), Color(0x66000000), Color(0x00000000)],
    ),
  ),
  child: HeroModalContainer(child: ...),
)
```

### Dismiss behaviour

```dart
HeroModalBackdrop(isDismissable: false, child: ...);          // backdrop press ignored
HeroModalBackdrop(isKeyboardDismissDisabled: true, child: ...); // Escape ignored
```

### Close methods

```dart
// slot: HeroButtonSlot.close closes the enclosing dialog.
const HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm'));

// The dialog builder receives a close function.
HeroModalDialog(
  builder: (context, close) => [
    HeroModalFooter(children: [
      HeroButton(onPressed: close, child: const Text('Confirm')),
    ]),
  ],
);

// Anywhere inside the dialog, with a result for HeroModal.show.
HeroModal.close(context, 'saved');
```

### Imperative API

```dart
final String? result = await HeroModal.show<String>(
  context,
  size: HeroModalSize.sm,
  builder: (context, close) => HeroModalDialog(children: [...]),
);
```

### Custom animations

```dart
HeroModalBackdrop(
  motion: const HeroModalMotion(
    enterDuration: Duration(milliseconds: 400),
    exitDuration: Duration(milliseconds: 200),
    enterCurve: Cubic(0.16, 1, 0.3, 1),
    exitCurve: Cubic(0.7, 0, 0.84, 0),
  ),
  child: HeroModalContainer(
    motion: const HeroModalMotion(
      enterDuration: Duration(milliseconds: 400),
      exitDuration: Duration(milliseconds: 200),
      enterCurve: Cubic(0.16, 1, 0.3, 1),
      exitCurve: Cubic(0.7, 0, 0.84, 0),
      enterScale: 0.95,
      exitScale: 0.95,
      enterOffset: Offset.zero,
    ),
    child: HeroModalDialog(children: [...]),
  ),
)
```

### Custom portal

```dart
SizedBox(
  height: 380,
  child: HeroOverlayHost(
    child: HeroModal(
      useRootNavigator: false,
      trigger: const HeroButton(child: Text('Open Modal')),
      child: HeroModalBackdrop(child: ...),
    ),
  ),
)
```

### Custom styles

```dart
HeroModalDialog(
  maxWidth: 340,
  backgroundColor: theme.colors.surface.withValues(alpha: 0.9),
  side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
  shadows: const [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 25),
      blurRadius: 50,
      spreadRadius: -12,
    ),
  ],
  backdropBlur: 24,
  children: [...],
)
```

## Accessibility

- The dialog is announced with the dialog role (`SemanticsRole.dialog`), scopes the route and
  is named by its `HeroModalHeading` (or `semanticLabel`).
- The trigger announces its expanded state.
- Focus moves into the dialog when it opens; Tab and Shift+Tab cycle inside it; focus returns
  to the trigger when it closes.
- Escape closes the modal unless `isKeyboardDismissDisabled`; the system back action follows
  the same setting. A press outside the dialog closes it when `isDismissable`.
- The page below is blocked for pointers and hidden from assistive technologies.

## API

### HeroModal

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The overlay: a `HeroModalBackdrop`. |
| `trigger` | `Widget?` | `null` | Opens the modal when pressed. |
| `isOpen` | `bool?` | backdrop's `isOpen` | Controlled open state. |
| `defaultOpen` | `bool` | `false` | Initial state when uncontrolled. |
| `onOpenChanged` | `ValueChanged<bool>?` | `null` | Called when the state should change. |
| `controller` | `HeroOverlayController?` | `null` | External open state. |
| `useRootNavigator` | `bool` | `true` | Open in the root navigator or the nearest one. |

`HeroModal.show<T>(context, {builder, backdropVariant, placement, scroll, size, isDismissable,
isKeyboardDismissDisabled, useRootNavigator, settings})` opens a modal and completes with the
result passed to `HeroModal.close(context, result)` (null when dismissed).

### HeroModalTrigger

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | Content. |
| `builder` | `HeroButtonWidgetBuilder?` | `null` | Content for the interaction state. |
| `onPressed` | `VoidCallback?` | `null` | Called before the modal opens. |
| `borderRadius` | `BorderRadiusGeometry` | `BorderRadius.zero` | Shape of the focus ring. |
| `isDisabled` | `bool` | `false` | Disables the trigger. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### HeroModalBackdrop

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The container. |
| `variant` | `HeroBackdropVariant` | `opaque` | Fill. |
| `isDismissable` | `bool` | `true` | Close on a press outside the dialog. |
| `isKeyboardDismissDisabled` | `bool` | `false` | Ignore Escape and the back action. |
| `isOpen` | `bool?` | `null` | Controlled state when used as the root. |
| `onOpenChanged` | `ValueChanged<bool>?` | `null` | State change handler. |
| `color` | `Color?` | `null` | Replaces the fill color. |
| `decoration` | `Decoration?` | `null` | Replaces the fill (gradients). |
| `motion` | `HeroModalMotion` | HeroUI fade | Fade timing. |
| `useRootNavigator` | `bool` | `true` | Navigator used when it is the root. |

### HeroModalContainer

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The dialog. |
| `placement` | `HeroModalPlacement` | `auto` | Position on screen. |
| `scroll` | `HeroModalScroll` | `inside` | Scroll behaviour. |
| `size` | `HeroModalSize` | `md` | Dialog size. |
| `motion` | `HeroModalMotion` | HeroUI motion | Enter/exit overrides. |
| `transitionBuilder` | `HeroModalTransitionBuilder?` | `null` | Custom transition. |

### HeroModalDialog

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | The parts. |
| `builder` | `HeroDialogPartsBuilder?` | `null` | Builds the parts with `close`. |
| `role` | `SemanticsRole` | `dialog` | Semantics role. |
| `semanticLabel` | `String?` | heading | Accessibility label. |
| `maxWidth` | `double?` | size cap | Maximum width. |
| `padding` | `EdgeInsets?` | 24 | Panel padding. |
| `backgroundColor` | `Color?` | `overlay` | Fill. |
| `side` | `BorderSide` | none | Border. |
| `shadows` | `List<BoxShadow>?` | overlay shadow | Drop shadows. |
| `backdropBlur` | `double` | `0` | Blur behind a translucent panel. |

### Parts

| Widget | Parameters | Description |
| --- | --- | --- |
| `HeroModalHeader` | `children`, `crossAxisAlignment` (`start`) | Column with 12 px gaps. |
| `HeroModalHeading` | `child`, `textAlign` | 16 px medium `foreground`; names the dialog. |
| `HeroModalIcon` | `child`, `backgroundColor`, `foregroundColor` | 40 px circle, 20 px icon. |
| `HeroModalBody` | `child` or `children`, `padding` (3) | 14 px `muted`, line height 1.43; scrolls inside. |
| `HeroModalFooter` | `children` or `child` | End-aligned row, 8 px gaps; `fullWidth` buttons share the row. |
| `HeroModalCloseTrigger` | `child`, `onPressed`, `semanticLabel` (`'Close'`) | `HeroCloseButton` at top 16 / end 16. |

### HeroOverlayController

| Member | Description |
| --- | --- |
| `HeroOverlayController({defaultOpen, onOpenChanged})` | Creates the state. |
| `isOpen` | Current state. |
| `open()`, `close()`, `toggle()`, `setOpen(bool)` | Change the state. |

### HeroModalMotion

| Field | Type | Description |
| --- | --- | --- |
| `enterDuration`, `exitDuration` | `Duration?` | Durations. |
| `enterCurve`, `exitCurve` | `Curve?` | Easing. |
| `enterScale`, `exitScale` | `double?` | Scale entered from / exited to. |
| `enterOffset`, `exitOffset` | `Offset?` | Offset entered from / exited to. |

### Building blocks

| Widget / function | Description |
| --- | --- |
| `HeroModalRoute<T>` | The modal `PopupRoute` shared by modal, alert dialog and drawer. |
| `HeroModalHost` | Root that keeps a route in sync with an open state and a trigger. |
| `showHeroModalRoute<T>` | Pushes backdrop content in an uncontrolled route. |
| `HeroOverlayHost` | Bounded area modals open into (`useRootNavigator: false`). |
| `HeroOverlaySurface` | Overlay fill, shadow and dark inner highlight. |
| `HeroDialogLayout`, `HeroDialogPart` | Header/body/footer layout and spacing. |
