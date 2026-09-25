# Form

Wrapper component for form validation and submission handling.

HeroUI docs: [heroui.com/en/docs/react/components/form](https://heroui.com/en/docs/react/components/form)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroForm(
  onSubmit: (Map<String, Object?> data) => debugPrint('$data'),
  child: SizedBox(
    width: 384,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        HeroTextField(
          name: 'email',
          type: HeroInputType.email,
          isRequired: true,
          validator: (String? value) => emailPattern.hasMatch(value ?? '')
              ? null
              : 'Please enter a valid email address',
          children: const <Widget>[
            HeroLabel.text('Email'),
            HeroInput(placeholder: 'john@example.com'),
            HeroFieldError(),
          ],
        ),
        HeroTextField(
          name: 'password',
          type: HeroInputType.password,
          isRequired: true,
          minLength: 8,
          validator: validatePassword,
          children: const <Widget>[
            HeroLabel.text('Password'),
            HeroInput(placeholder: 'Enter your password'),
            HeroDescription.text(
              'Must be at least 8 characters with 1 uppercase and 1 number',
            ),
            HeroFieldError(),
          ],
        ),
        const Row(
          spacing: 8,
          children: <Widget>[
            HeroButton(
              type: HeroButtonType.submit,
              startContent: HeroIcon(HeroIcons.check),
              child: Text('Submit'),
            ),
            HeroButton(
              type: HeroButtonType.reset,
              variant: HeroButtonVariant.secondary,
              child: Text('Reset'),
            ),
          ],
        ),
      ],
    ),
  ),
)
```

## Anatomy

```dart
HeroForm(
  child: Column(
    children: <Widget>[
      // Form fields go here
      HeroButton(type: HeroButtonType.submit, child: Text('Submit')),
      HeroButton(type: HeroButtonType.reset, child: Text('Reset')),
    ],
  ),
)
```

`HeroForm` wraps a Flutter `Form`: every field inside it (`HeroTextField`,
`HeroInput`, `HeroTextArea`, or any `FormField`) registers with it. The form has no styles
of its own; lay it out with its child.

## Validation behavior

| `validationBehavior` | Errors appear | Submission |
| --- | --- | --- |
| `HeroValidationBehavior.native` (default) | once a value is committed (the field loses focus after an edit) or the form is submitted | blocked while a field is invalid; `onInvalid` is called and the first invalid field is focused |
| `HeroValidationBehavior.aria` | in realtime while the user edits | never blocked; `onSubmit` is always called |

Fields inherit the behavior and can override it. With `aria`, built-in
constraints such as `isRequired` are only announced to assistive
technologies, like React Aria's `aria-required`.

`validationErrors` maps field names to server-side errors. A field shows them
immediately and clears them once the user edits it; passing a new map shows
them again.

## Submission

A form is submitted by:

- a `HeroButton` with `type: HeroButtonType.submit` (after its `onPressed`);
- Enter, or the done / go / send / search keyboard action, in a single-line
  input (the browser's implicit submission);
- `HeroForm.of(context).submit()` or a `GlobalKey<HeroFormState>`.

On submission every field is saved (`onSaved`) and `onSubmit` receives the
values of the named fields, like `FormData`: `name` → value, a `List` when
several fields share a name, disabled fields left out.

A `HeroButton` with `type: HeroButtonType.reset` (or `reset()`) restores
every field's initial value, clears the errors and calls `onReset`.

## Examples

### Render function

React renders the form through a custom element (`render`). In Flutter the
form is composed like any other widget; wrap or replace its child instead.

### Customization

The form has no look of its own; style its child:

```dart
HeroForm(
  onSubmit: submit,
  child: Container(
    width: 320,
    padding: EdgeInsets.all(theme.spacing(4)),
    decoration: ShapeDecoration(
      color: theme.colors.surface,
      shape: theme.shapeAll(
        theme.radii.xl,
        side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
      ),
      shadows: theme.shadows.surface.boxShadows,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.spacing(3),
      children: const <Widget>[
        HeroTextField(
          name: 'email',
          type: HeroInputType.email,
          isRequired: true,
          label: 'Work email',
          placeholder: 'you@company.com',
        ),
        HeroButton(
          type: HeroButtonType.submit,
          fullWidth: true,
          child: Text('Continue'),
        ),
      ],
    ),
  ),
)
```

### Server errors

```dart
HeroForm(
  validationErrors: const <String, List<String>>{
    'username': <String>['This username is already taken.'],
  },
  child: const HeroTextField(
    name: 'username',
    label: 'Username',
  ),
)
```

### Submitting programmatically

```dart
final GlobalKey<HeroFormState> formKey = GlobalKey<HeroFormState>();

HeroForm(key: formKey, onSubmit: save, child: ...);

formKey.currentState!.submit(); // validate, then onSubmit
formKey.currentState!.reset();
```

## Accessibility

- The form is exposed with the form role; `semanticLabel` names it
  (`aria-label`).
- A blocked submission focuses the first invalid field (in focus order) and
  announces its error; set `focusInvalidField: false` to handle focus in
  `onInvalid` instead.
- Submit and reset buttons are regular buttons: Enter and Space activate them.

## API

### HeroForm

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Form content. |
| `onSubmit` | `ValueChanged<Map<String, Object?>>?` | – | Called with the named values on submission (when valid, for `native`). |
| `onInvalid` | `VoidCallback?` | – | Called when a submission is blocked by an invalid field. |
| `onReset` | `VoidCallback?` | – | Called after the form was reset. |
| `onChanged` | `VoidCallback?` | – | Called whenever a field's value changes. |
| `validationBehavior` | `HeroValidationBehavior` | `native` | How fields validate; fields can override it. |
| `validationErrors` | `Map<String, List<String>>?` | – | Server-side errors by field name. |
| `autovalidateMode` | `AutovalidateMode?` | `disabled` | Automatic validation of the underlying `Form`. |
| `focusInvalidField` | `bool` | `true` | Whether a blocked submission focuses the first invalid field. |
| `semanticLabel` | `String?` | – | Accessibility label (`aria-label`). |

### HeroFormState

| Member | Description |
| --- | --- |
| `submit()` | Validates (for `native`) and calls `onSubmit`; returns whether it was called. |
| `reset()` | Restores initial values, clears errors, calls `onReset`. |
| `validate()` | Validates every field and shows the errors. |
| `save()` | Saves every field and returns the named values. |
| `addValue(name, value)` | Adds a value to the data being saved (for custom fields' `onSaved`). |
| `validationBehavior` | The form's validation behavior. |
| `validationErrorsFor(name)` | The server-side errors of a field. |
| `form` | The underlying `FormState`. |
| `HeroForm.of(context)` / `HeroForm.maybeOf(context)` | The closest form. |

### HeroValidationBehavior

| Value | Description |
| --- | --- |
| `native` | Errors after commit or submit; invalid fields block submission. |
| `aria` | Realtime errors; submission is never blocked. |

### HeroButtonType (on `HeroButton.type`)

| Value | Description |
| --- | --- |
| `button` (default) | A plain button. |
| `submit` | Submits the enclosing `HeroForm` after `onPressed`. |
| `reset` | Resets the enclosing `HeroForm` after `onPressed`. |
