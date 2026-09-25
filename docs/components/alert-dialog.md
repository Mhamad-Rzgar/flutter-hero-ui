# AlertDialog

Modal dialog for critical confirmations requiring user attention and explicit action.

HeroUI docs: [heroui.com/en/docs/react/components/alert-dialog](https://heroui.com/en/docs/react/components/alert-dialog)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroAlertDialog(
  trigger: const HeroButton(
    variant: HeroButtonVariant.danger,
    child: Text('Delete Project'),
  ),
  child: HeroAlertDialogBackdrop(
    child: HeroAlertDialogContainer(
      child: HeroAlertDialogDialog(
        maxWidth: 400,
        children: const [
          HeroAlertDialogCloseTrigger(),
          HeroAlertDialogHeader(children: [
            HeroAlertDialogIcon(status: HeroColor.danger),
            HeroAlertDialogHeading(child: Text('Delete project permanently?')),
          ]),
          HeroAlertDialogBody(
            child: Text(
              'This will permanently delete My Awesome Project and all of '
              'its data. This action cannot be undone.',
            ),
          ),
          HeroAlertDialogFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.tertiary,
              child: Text('Cancel'),
            ),
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.danger,
              child: Text('Delete Project'),
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
HeroAlertDialog(
  trigger: HeroButton(child: Text('Open')),        // AlertDialog trigger
  child: HeroAlertDialogBackdrop(                   // AlertDialog.Backdrop
    child: HeroAlertDialogContainer(                // AlertDialog.Container
      child: HeroAlertDialogDialog(children: [      // AlertDialog.Dialog
        HeroAlertDialogCloseTrigger(),              // optional
        HeroAlertDialogHeader(children: [
          HeroAlertDialogIcon(),                    // optional status icon
          HeroAlertDialogHeading(child: ...),
        ]),
        HeroAlertDialogBody(child: ...),
        HeroAlertDialogFooter(children: [...]),
      ]),
    ),
  ),
)
```

`HeroAlertDialogTrigger` is a custom pressable trigger (`AlertDialog.Trigger`). The alert
dialog is built on the [Modal](modal.md) route and parts: same backdrop variants, placements,
motion, focus trap and close methods. The differences:

- It requires an explicit action: `HeroAlertDialogBackdrop.isDismissable` defaults to `false`
  and `isKeyboardDismissDisabled` to `true` (the system back action follows it too).
- The dialog is announced with the alert dialog role.
- The body always scrolls inside the dialog (there is no `scroll` option).
- Sizes are `xs`, `sm`, `md` (default), `lg` and `cover` (no `full`).
- `HeroAlertDialogIcon` shows a status icon.

## Status icon

| `status` | Fill / glyph color | Glyph |
| --- | --- | --- |
| `HeroColor.standard` | `defaultColor` / `foreground` | info |
| `HeroColor.accent` | `accentSoft` / `accentSoftForeground` | info |
| `HeroColor.success` | `successSoft` / `successSoftForeground` | check circle |
| `HeroColor.warning` | `warningSoft` / `warningSoftForeground` | warning triangle |
| `HeroColor.danger` (default) | `dangerSoft` / `dangerSoftForeground` | exclamation circle |

The icon is a 40 px circle with a 20 px glyph; a `child` replaces the glyph and keeps the
colors.

## Sizes and placements

| `HeroAlertDialogSize` | Dialog width |
| --- | --- |
| `xs` / `sm` / `md` (default) / `lg` | up to 320 / 384 / 448 / 512 |
| `cover` | fills the container (16 px margins, 40 px from 640 px) |

Placements are `HeroModalPlacement.auto` (bottom below 640 px, centered above), `center`,
`top` and `bottom`. The footer stacks its actions vertically when they do not fit on one line.

## Examples

### Statuses

```dart
const HeroAlertDialogIcon(status: HeroColor.success)
```

### Placements and sizes

```dart
HeroAlertDialogContainer(
  placement: HeroModalPlacement.top,
  size: HeroAlertDialogSize.sm,
  child: HeroAlertDialogDialog(children: [...]),
)
```

### Controlled state

```dart
HeroAlertDialogBackdrop(
  isOpen: isOpen,
  onOpenChanged: (value) => setState(() => isOpen = value),
  child: HeroAlertDialogContainer(child: HeroAlertDialogDialog(children: [...])),
)

final state = HeroOverlayController();
HeroAlertDialogBackdrop(
  isOpen: state.isOpen,
  onOpenChanged: state.setOpen,
  child: ...,
)
```

### Custom icon

```dart
const HeroAlertDialogIcon(
  status: HeroColor.warning,
  child: HeroIcon(HeroIcons.lockOpen),
)
```

### Custom trigger

```dart
HeroAlertDialog(
  trigger: HeroAlertDialogTrigger(
    borderRadius: BorderRadius.circular(16),
    builder: (context, state) => DecoratedBox(
      decoration: ShapeDecoration(
        color: state.isHovered
            ? theme.colors.surfaceSecondary
            : theme.colors.surface,
        shape: theme.shapeAll(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Delete Item'),
      ),
    ),
  ),
  child: HeroAlertDialogBackdrop(child: ...),
)
```

### Backdrop variants and custom backdrop

```dart
HeroAlertDialogBackdrop(
  variant: HeroBackdropVariant.blur,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [red950.withValues(alpha: 0.9), red950.withValues(alpha: 0.5), red950.withValues(alpha: 0)],
    ),
  ),
  child: ...,
)
```

### Dismiss behaviour

```dart
// Allow closing with a backdrop press and Escape.
HeroAlertDialogBackdrop(
  isDismissable: true,
  isKeyboardDismissDisabled: false,
  child: ...,
)
```

### Close methods

```dart
const HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm'));

HeroAlertDialogDialog(
  builder: (context, close) => [
    HeroAlertDialogFooter(children: [
      HeroButton(onPressed: close, child: const Text('Confirm')),
    ]),
  ],
);
```

### Imperative API

```dart
final bool? confirmed = await HeroAlertDialog.show<bool>(
  context,
  builder: (context, close) => HeroAlertDialogDialog(children: [
    const HeroAlertDialogHeader(children: [
      HeroAlertDialogIcon(),
      HeroAlertDialogHeading(child: Text('Delete?')),
    ]),
    HeroAlertDialogFooter(children: [
      HeroButton(onPressed: close, child: const Text('Cancel')),
      Builder(
        builder: (context) => HeroButton(
          variant: HeroButtonVariant.danger,
          onPressed: () => HeroModal.close(context, true),
          child: const Text('Delete'),
        ),
      ),
    ]),
  ]),
);
```

### Custom animations, portal and styles

`HeroAlertDialogBackdrop.motion` and `HeroAlertDialogContainer.motion` take a
`HeroModalMotion`; `HeroOverlayHost` with `useRootNavigator: false` renders the dialog inside a
bounded area; `HeroAlertDialogDialog` accepts `maxWidth`, `backgroundColor`, `side`,
`shadows`, `backdropBlur` and `Positioned` decoration children (see [Modal](modal.md)).

## Accessibility

- Announced with the alert dialog role (`SemanticsRole.alertDialog`), named by its heading.
- Focus moves into the dialog and is trapped there; it returns to the trigger on close.
- By default only an explicit action (a footer button, a `slot: close` button or the close
  trigger) closes it; Escape and backdrop presses are ignored.

## API

### HeroAlertDialog

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The overlay: a `HeroAlertDialogBackdrop`. |
| `trigger` | `Widget?` | `null` | Opens the dialog when pressed. |
| `isOpen` | `bool?` | backdrop's `isOpen` | Controlled open state. |
| `defaultOpen` | `bool` | `false` | Initial state when uncontrolled. |
| `onOpenChanged` | `ValueChanged<bool>?` | `null` | Called when the state should change. |
| `controller` | `HeroOverlayController?` | `null` | External open state. |
| `useRootNavigator` | `bool` | `true` | Open in the root navigator or the nearest one. |

`HeroAlertDialog.show<T>(context, {builder, backdropVariant, placement, size, isDismissable =
false, isKeyboardDismissDisabled = true, useRootNavigator, settings})`.

### HeroAlertDialogBackdrop

Same parameters as `HeroModalBackdrop`, with `isDismissable` defaulting to `false` and
`isKeyboardDismissDisabled` to `true`.

### HeroAlertDialogContainer

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The dialog. |
| `placement` | `HeroModalPlacement` | `auto` | Position on screen. |
| `size` | `HeroAlertDialogSize` | `md` | Dialog size. |
| `motion` | `HeroModalMotion` | HeroUI motion | Enter/exit overrides. |
| `transitionBuilder` | `HeroModalTransitionBuilder?` | `null` | Custom transition. |

### HeroAlertDialogDialog

Same parameters as `HeroModalDialog`; `role` defaults to `SemanticsRole.alertDialog`.

### HeroAlertDialogIcon

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `status` | `HeroColor` | `danger` | Colors and default glyph. |
| `child` | `Widget?` | status glyph | Custom glyph. |

### Other parts

`HeroAlertDialogTrigger`, `HeroAlertDialogHeader`, `HeroAlertDialogHeading`,
`HeroAlertDialogBody`, `HeroAlertDialogFooter` and `HeroAlertDialogCloseTrigger` take the
parameters of their `HeroModal*` counterparts.
