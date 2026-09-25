# Alert

Display important messages and notifications to users with status indicators.

HeroUI docs: [heroui.com/en/docs/react/components/alert](https://heroui.com/en/docs/react/components/alert)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const HeroAlert(
  title: Text('New features available'),
  description: Text('Check out our latest updates.'),
)
```

## Anatomy

| HeroUI | Flutter | Role |
| --- | --- | --- |
| `Alert` | `HeroAlert` | The `--surface` row; provides the status and a standard surface context. |
| `Alert.Indicator` | `HeroAlertIndicator` | The status icon (or any child, such as a spinner). |
| `Alert.Content` | `HeroAlertContent` | The text column; takes the free width. |
| `Alert.Title` | `HeroAlertTitle` | The title in the status color. |
| `Alert.Description` | `HeroAlertDescription` | The muted description. |

`title`, `description`, `indicator` (`showIndicator`) and `endContent` build the usual layout.
The same alert from its parts:

```dart
HeroAlert(
  children: <Widget>[
    const HeroAlertIndicator(),
    const HeroAlertContent(
      children: <Widget>[
        HeroAlertTitle.text('New features available'),
        HeroAlertDescription.text('Check out our latest updates.'),
      ],
    ),
    HeroCloseButton(onPressed: dismiss),
  ],
)
```

## Look

- A full-width row on `--surface` with the surface shadow (light mode only), a radius of
  `min(32, --radius-3xl)` (24 by default), 16 px horizontal and 12 px vertical padding and a
  16 px gap, aligned at the top. Unbounded widths fall back to 576 (`max-w-xl`).
- Indicator: 4 px padding around a 16 px icon, so it lines up with the 24 px title line.
- Title: 14 px medium on a 24 px line, in the status color. Description: 14 px in `--muted`.

## Statuses

| Status | Indicator and title | Icon |
| --- | --- | --- |
| `HeroColor.standard` (default) | `foreground` | info |
| `HeroColor.accent` | `accentSoftForeground` | info |
| `HeroColor.success` | `successSoftForeground` | check |
| `HeroColor.warning` | `warningSoftForeground` | triangle |
| `HeroColor.danger` | `dangerSoftForeground` | exclamation |

## Examples

### Actions

HeroUI's examples put the action under the text on narrow screens and after it from the `sm`
breakpoint (640) up:

```dart
final bool smUp = MediaQuery.sizeOf(context).width >= HeroBreakpoints.sm;
final Widget refresh = HeroButton(
  size: HeroSize.sm,
  onPressed: refresh,
  child: const Text('Refresh'),
);

HeroAlert(
  status: HeroColor.accent,
  children: <Widget>[
    const HeroAlertIndicator(),
    HeroAlertContent(
      children: <Widget>[
        const HeroAlertTitle.text('Update available'),
        const HeroAlertDescription.text('A new version is available.'),
        if (!smUp) Padding(padding: const EdgeInsets.only(top: 8), child: refresh),
      ],
    ),
    if (smUp) refresh,
  ],
)
```

### Close button and loading indicator

```dart
HeroAlert(
  status: HeroColor.success,
  title: const Text('Profile updated successfully'),
  endContent: HeroCloseButton(onPressed: dismiss),
)

const HeroAlert(
  status: HeroColor.accent,
  indicator: HeroSpinner(size: HeroSpinnerSize.sm),
  title: Text('Processing your request'),
  description: Text('Please wait while we sync your data.'),
)
```

### Customization

`style` overrides the container (`color`, `gradient`, `border`, `borderRadius`, `shadows`,
`padding`) and `background` paints a decorative layer clipped to the alert:

```dart
HeroAlert(
  status: HeroColor.warning,
  style: HeroAlertStyle(
    borderRadius: BorderRadius.circular(12),
    border: BorderSide(color: colors.warning.withValues(alpha: 0.2)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        colors.warning.withValues(alpha: 0.1),
        colors.surface,
        colors.surfaceSecondary,
      ],
    ),
  ),
  background: glow,
  children: <Widget>[
    HeroAlertIndicator(color: colors.warning),
    const HeroAlertContent(
      children: <Widget>[
        HeroAlertTitle.text('Payment method expires soon'),
        HeroAlertDescription.text('Your Visa ending in 4242 expires on March 28.'),
      ],
    ),
    HeroButton(
      size: HeroSize.sm,
      variant: HeroButtonVariant.tertiary,
      onPressed: updateBilling,
      child: const Text('Update billing'),
    ),
    HeroCloseButton(onPressed: dismiss),
  ],
)
```

## Accessibility

- HeroUI's alert has no role; `isLive: true` makes it a live region so updates are announced
  (`role="alert"`). `semanticLabel` names it.
- Buttons inside keep their own semantics; the default status icon is decorative.

## API

### HeroAlert

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `status` | `HeroColor` | `standard` | Indicator and title color, default icon. |
| `children` | `List<Widget>?` | `null` | The parts; replaces the slots below. |
| `title` | `Widget?` | `null` | Title of the default layout. |
| `description` | `Widget?` | `null` | Description of the default layout. |
| `indicator` | `Widget?` | status icon | Replaces the icon. |
| `showIndicator` | `bool` | `true` | Whether the default layout shows the indicator. |
| `endContent` | `Widget?` | `null` | Trailing actions or close button. |
| `background` | `Widget?` | `null` | Decorative layer behind the content. |
| `style` | `HeroAlertStyle?` | `null` | Container overrides. |
| `isLive` | `bool` | `false` | Announce changes (live region). |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

`HeroAlert.statusColorOf(colors, status)` and `HeroAlert.iconOf(status)` return the resolved
color and icon.

### HeroAlertIndicator

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | status icon | Indicator content. |
| `color` | `Color?` | status color | Icon color. |

### HeroAlertContent

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Title, description and extra content. |

### HeroAlertTitle / HeroAlertDescription

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` / `data` (`.text`) | `Widget` / `String` | required | Content. |
| `style` | `TextStyle?` | `null` | Merged over the part's style. |

### HeroAlertStyle

| Field | Type | Default |
| --- | --- | --- |
| `color` | `Color?` | `--surface` |
| `gradient` | `Gradient?` | `null` |
| `border` | `BorderSide?` | none |
| `borderRadius` | `BorderRadiusGeometry?` | `min(32, --radius-3xl)` |
| `shadows` | `List<BoxShadow>?` | `--surface-shadow` |
| `padding` | `EdgeInsetsGeometry?` | 16 × 12 |
