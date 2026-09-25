// Component catalog mirroring https://heroui.com/en/docs/react/components.

/// A documentation category of the HeroUI component index.
enum ComponentCategory {
  buttons('Buttons'),
  collections('Collections'),
  colors('Colors'),
  controls('Controls'),
  dataDisplay('Data Display'),
  dateTime('Date and Time'),
  feedback('Feedback'),
  forms('Forms'),
  layout('Layout'),
  media('Media'),
  navigation('Navigation'),
  overlays('Overlays'),
  pickers('Pickers'),
  typography('Typography'),
  utilities('Utilities'),
  pro('Pro');

  const ComponentCategory(this.label);

  final String label;
}

/// One entry of the component index.
class CatalogEntry {
  const CatalogEntry({
    required this.slug,
    required this.name,
    required this.category,
    required this.description,
    this.group,
  });

  /// Docs slug, e.g. `button-group`.
  final String slug;

  /// HeroUI component name, e.g. `ButtonGroup`.
  final String name;

  final ComponentCategory category;

  final String description;

  /// Sub-group inside [category] (used by Pro components, e.g. `Charts`).
  final String? group;

  /// Whether this is a Pro component.
  bool get isPro => category == ComponentCategory.pro;

  /// Widget name prefix used in the gallery (`HeroPro` for Pro components).
  String get widgetName => isPro ? 'HeroPro$name' : 'Hero$name';

  /// Link to the HeroUI documentation page.
  String get docsUrl => isPro
      ? 'https://heroui.pro/docs/react/components/${slug.replaceFirst('pro-', '')}'
      : 'https://heroui.com/en/docs/react/components/$slug';
}

const List<CatalogEntry> catalog = <CatalogEntry>[
  CatalogEntry(
    slug: 'button',
    name: 'Button',
    category: ComponentCategory.buttons,
    description:
        'A clickable button component with multiple variants and states',
  ),
  CatalogEntry(
    slug: 'button-group',
    name: 'ButtonGroup',
    category: ComponentCategory.buttons,
    description:
        'Group related buttons together with consistent styling and spacing',
  ),
  CatalogEntry(
    slug: 'close-button',
    name: 'CloseButton',
    category: ComponentCategory.buttons,
    description:
        'Button component for closing dialogs, modals, or dismissing content',
  ),
  CatalogEntry(
    slug: 'toggle-button',
    name: 'ToggleButton',
    category: ComponentCategory.buttons,
    description:
        'An interactive toggle control for on/off or selected/unselected states',
  ),
  CatalogEntry(
    slug: 'toggle-button-group',
    name: 'ToggleButtonGroup',
    category: ComponentCategory.buttons,
    description:
        'Groups multiple ToggleButtons into a unified control, allowing users to select one or multiple options.',
  ),
  CatalogEntry(
    slug: 'dropdown',
    name: 'Dropdown',
    category: ComponentCategory.collections,
    description:
        'A dropdown displays a list of actions or options that a user can choose',
  ),
  CatalogEntry(
    slug: 'list-box',
    name: 'ListBox',
    category: ComponentCategory.collections,
    description:
        'A listbox displays a list of options and allows a user to select one or more of them',
  ),
  CatalogEntry(
    slug: 'tag-group',
    name: 'TagGroup',
    category: ComponentCategory.collections,
    description:
        'A focusable list of tags with support for keyboard navigation, selection, and removal',
  ),
  CatalogEntry(
    slug: 'color-area',
    name: 'ColorArea',
    category: ComponentCategory.colors,
    description:
        'A 2D color picker that allows users to select colors from a gradient area',
  ),
  CatalogEntry(
    slug: 'color-field',
    name: 'ColorField',
    category: ComponentCategory.colors,
    description:
        'Color input field with labels, descriptions, and validation built on React Aria ColorField',
  ),
  CatalogEntry(
    slug: 'color-picker',
    name: 'ColorPicker',
    category: ComponentCategory.colors,
    description:
        'A composable color picker that synchronizes color value between multiple color components',
  ),
  CatalogEntry(
    slug: 'color-slider',
    name: 'ColorSlider',
    category: ComponentCategory.colors,
    description:
        'A color slider allows users to adjust an individual channel of a color value',
  ),
  CatalogEntry(
    slug: 'color-swatch',
    name: 'ColorSwatch',
    category: ComponentCategory.colors,
    description: 'A visual preview of a color value with accessibility support',
  ),
  CatalogEntry(
    slug: 'color-swatch-picker',
    name: 'ColorSwatchPicker',
    category: ComponentCategory.colors,
    description:
        'A list of color swatches that allows users to select a color from a predefined palette.',
  ),
  CatalogEntry(
    slug: 'slider',
    name: 'Slider',
    category: ComponentCategory.controls,
    description:
        'A slider allows a user to select one or more values within a range',
  ),
  CatalogEntry(
    slug: 'switch',
    name: 'Switch',
    category: ComponentCategory.controls,
    description: 'A toggle switch component for boolean states',
  ),
  CatalogEntry(
    slug: 'badge',
    name: 'Badge',
    category: ComponentCategory.dataDisplay,
    description:
        'Displays a small indicator positioned relative to another element, commonly used for notification counts, status dots, and labels',
  ),
  CatalogEntry(
    slug: 'chip',
    name: 'Chip',
    category: ComponentCategory.dataDisplay,
    description:
        'Small informational badges for displaying labels, statuses, and categories',
  ),
  CatalogEntry(
    slug: 'table',
    name: 'Table',
    category: ComponentCategory.dataDisplay,
    description:
        'Tables display structured data in rows and columns with support for sorting, selection, column resizing, and infinite scrolling.',
  ),
  CatalogEntry(
    slug: 'calendar',
    name: 'Calendar',
    category: ComponentCategory.dateTime,
    description:
        'Composable date picker with month grid, navigation, and year picker support built on React Aria Calendar',
  ),
  CatalogEntry(
    slug: 'date-field',
    name: 'DateField',
    category: ComponentCategory.dateTime,
    description:
        'Date input field with labels, descriptions, and validation built on React Aria DateField',
  ),
  CatalogEntry(
    slug: 'date-picker',
    name: 'DatePicker',
    category: ComponentCategory.dateTime,
    description:
        'Composable date picker built on React Aria DatePicker with DateField and Calendar composition',
  ),
  CatalogEntry(
    slug: 'date-range-picker',
    name: 'DateRangePicker',
    category: ComponentCategory.dateTime,
    description:
        'Composable date range picker built on React Aria DateRangePicker with DateField and RangeCalendar composition',
  ),
  CatalogEntry(
    slug: 'range-calendar',
    name: 'RangeCalendar',
    category: ComponentCategory.dateTime,
    description:
        'Composable date range picker with month grid, navigation, and year picker support built on React Aria RangeCalendar',
  ),
  CatalogEntry(
    slug: 'time-field',
    name: 'TimeField',
    category: ComponentCategory.dateTime,
    description:
        'Time input field with labels, descriptions, and validation built on React Aria TimeField',
  ),
  CatalogEntry(
    slug: 'alert',
    name: 'Alert',
    category: ComponentCategory.feedback,
    description:
        'Display important messages and notifications to users with status indicators',
  ),
  CatalogEntry(
    slug: 'meter',
    name: 'Meter',
    category: ComponentCategory.feedback,
    description:
        'A meter represents a quantity within a known range, or a fractional value.',
  ),
  CatalogEntry(
    slug: 'progress-bar',
    name: 'ProgressBar',
    category: ComponentCategory.feedback,
    description:
        'A progress bar shows either determinate or indeterminate progress of an operation over time.',
  ),
  CatalogEntry(
    slug: 'progress-circle',
    name: 'ProgressCircle',
    category: ComponentCategory.feedback,
    description:
        'A circular progress indicator that shows determinate or indeterminate progress.',
  ),
  CatalogEntry(
    slug: 'skeleton',
    name: 'Skeleton',
    category: ComponentCategory.feedback,
    description:
        'Skeleton is a placeholder to show a loading state and the expected shape of a component.',
  ),
  CatalogEntry(
    slug: 'spinner',
    name: 'Spinner',
    category: ComponentCategory.feedback,
    description: 'A loading indicator component to show pending states',
  ),
  CatalogEntry(
    slug: 'checkbox',
    name: 'Checkbox',
    category: ComponentCategory.forms,
    description:
        'Checkboxes allow users to select multiple items from a list of individual items, or to mark one individual item as selected.',
  ),
  CatalogEntry(
    slug: 'checkbox-group',
    name: 'CheckboxGroup',
    category: ComponentCategory.forms,
    description:
        'A checkbox group component for managing multiple checkbox selections',
  ),
  CatalogEntry(
    slug: 'description',
    name: 'Description',
    category: ComponentCategory.forms,
    description:
        'Provides supplementary text for form fields and other components',
  ),
  CatalogEntry(
    slug: 'error-message',
    name: 'ErrorMessage',
    category: ComponentCategory.forms,
    description: 'A low-level error message component for displaying errors',
  ),
  CatalogEntry(
    slug: 'field-error',
    name: 'FieldError',
    category: ComponentCategory.forms,
    description: 'Displays validation error messages for form fields',
  ),
  CatalogEntry(
    slug: 'fieldset',
    name: 'Fieldset',
    category: ComponentCategory.forms,
    description:
        'Group related form controls with legends, descriptions, and actions',
  ),
  CatalogEntry(
    slug: 'form',
    name: 'Form',
    category: ComponentCategory.forms,
    description:
        'Wrapper component for form validation and submission handling',
  ),
  CatalogEntry(
    slug: 'input',
    name: 'Input',
    category: ComponentCategory.forms,
    description:
        'Primitive single-line text input component that accepts standard HTML attributes',
  ),
  CatalogEntry(
    slug: 'input-group',
    name: 'InputGroup',
    category: ComponentCategory.forms,
    description:
        'Group related input controls with prefix and suffix elements for enhanced form fields',
  ),
  CatalogEntry(
    slug: 'input-otp',
    name: 'InputOTP',
    category: ComponentCategory.forms,
    description:
        'A one-time password input component for verification codes and secure authentication',
  ),
  CatalogEntry(
    slug: 'label',
    name: 'Label',
    category: ComponentCategory.forms,
    description: 'Renders an accessible label associated with form controls',
  ),
  CatalogEntry(
    slug: 'number-field',
    name: 'NumberField',
    category: ComponentCategory.forms,
    description:
        'Number input fields with increment/decrement buttons, validation, and internationalized formatting',
  ),
  CatalogEntry(
    slug: 'radio-group',
    name: 'RadioGroup',
    category: ComponentCategory.forms,
    description: 'Radio group for selecting a single option from a list',
  ),
  CatalogEntry(
    slug: 'search-field',
    name: 'SearchField',
    category: ComponentCategory.forms,
    description: 'Search input field with clear button and search icon',
  ),
  CatalogEntry(
    slug: 'text-area',
    name: 'TextArea',
    category: ComponentCategory.forms,
    description:
        'Primitive multiline text input component that accepts standard HTML attributes',
  ),
  CatalogEntry(
    slug: 'text-field',
    name: 'TextField',
    category: ComponentCategory.forms,
    description:
        'Composition-friendly text fields with labels, descriptions, and inline validation',
  ),
  CatalogEntry(
    slug: 'card',
    name: 'Card',
    category: ComponentCategory.layout,
    description:
        'Flexible container component for grouping related content and actions',
  ),
  CatalogEntry(
    slug: 'separator',
    name: 'Separator',
    category: ComponentCategory.layout,
    description: 'Visually divide content sections',
  ),
  CatalogEntry(
    slug: 'surface',
    name: 'Surface',
    category: ComponentCategory.layout,
    description:
        'Container component that provides surface-level styling and context for child components',
  ),
  CatalogEntry(
    slug: 'toolbar',
    name: 'Toolbar',
    category: ComponentCategory.layout,
    description:
        'A container for interactive controls with arrow key navigation.',
  ),
  CatalogEntry(
    slug: 'avatar',
    name: 'Avatar',
    category: ComponentCategory.media,
    description:
        'Display user profile images with customizable fallback content',
  ),
  CatalogEntry(
    slug: 'avatar-group',
    name: 'AvatarGroup',
    category: ComponentCategory.media,
    description:
        'Display a stacked or grid group of avatars with overflow counting',
  ),
  CatalogEntry(
    slug: 'accordion',
    name: 'Accordion',
    category: ComponentCategory.navigation,
    description:
        'A collapsible content panel for organizing information in a compact space',
  ),
  CatalogEntry(
    slug: 'breadcrumbs',
    name: 'Breadcrumbs',
    category: ComponentCategory.navigation,
    description:
        'Navigation breadcrumbs showing the current page\'s location within a hierarchy',
  ),
  CatalogEntry(
    slug: 'disclosure',
    name: 'Disclosure',
    category: ComponentCategory.navigation,
    description:
        'A disclosure is a collapsible section with a header containing a heading and a trigger button, and a panel that wraps the content.',
  ),
  CatalogEntry(
    slug: 'disclosure-group',
    name: 'DisclosureGroup',
    category: ComponentCategory.navigation,
    description:
        'Container that manages multiple Disclosure items with coordinated expanded states',
  ),
  CatalogEntry(
    slug: 'link',
    name: 'Link',
    category: ComponentCategory.navigation,
    description:
        'A styled anchor component for navigation with built-in icon support',
  ),
  CatalogEntry(
    slug: 'pagination',
    name: 'Pagination',
    category: ComponentCategory.navigation,
    description:
        'Page navigation with composable page links, previous/next buttons, and ellipsis indicators',
  ),
  CatalogEntry(
    slug: 'tabs',
    name: 'Tabs',
    category: ComponentCategory.navigation,
    description:
        'Tabs organize content into multiple sections and allow users to navigate between them.',
  ),
  CatalogEntry(
    slug: 'alert-dialog',
    name: 'AlertDialog',
    category: ComponentCategory.overlays,
    description:
        'Modal dialog for critical confirmations requiring user attention and explicit action',
  ),
  CatalogEntry(
    slug: 'drawer',
    name: 'Drawer',
    category: ComponentCategory.overlays,
    description: 'Slide-out panel for supplementary content and actions',
  ),
  CatalogEntry(
    slug: 'modal',
    name: 'Modal',
    category: ComponentCategory.overlays,
    description:
        'Dialog overlay for focused user interactions and important content',
  ),
  CatalogEntry(
    slug: 'popover',
    name: 'Popover',
    category: ComponentCategory.overlays,
    description:
        'Displays rich content in a portal triggered by a button or any custom element',
  ),
  CatalogEntry(
    slug: 'toast',
    name: 'Toast',
    category: ComponentCategory.overlays,
    description:
        'Display temporary notifications and messages to users with automatic dismissal and customizable placement',
  ),
  CatalogEntry(
    slug: 'tooltip',
    name: 'Tooltip',
    category: ComponentCategory.overlays,
    description:
        'Displays informative text when users hover over or focus on an element',
  ),
  CatalogEntry(
    slug: 'autocomplete',
    name: 'Autocomplete',
    category: ComponentCategory.pickers,
    description:
        'An autocomplete combines a select with filtering, allowing users to search and select from a list of options',
  ),
  CatalogEntry(
    slug: 'combo-box',
    name: 'ComboBox',
    category: ComponentCategory.pickers,
    description:
        'A combo box combines a text input with a listbox, allowing users to filter a list of options to items matching a query',
  ),
  CatalogEntry(
    slug: 'select',
    name: 'Select',
    category: ComponentCategory.pickers,
    description:
        'A select displays a collapsible list of options and allows a user to select one of them',
  ),
  CatalogEntry(
    slug: 'kbd',
    name: 'Kbd',
    category: ComponentCategory.typography,
    description: 'Display keyboard shortcuts and key combinations',
  ),
  CatalogEntry(
    slug: 'typography',
    name: 'Typography',
    category: ComponentCategory.typography,
    description:
        'A semantic typography primitive for headings, body copy, and inline code built on React Aria Components Text.',
  ),
  CatalogEntry(
    slug: 'scroll-shadow',
    name: 'ScrollShadow',
    category: ComponentCategory.utilities,
    description:
        'Apply visual shadows to indicate scrollable content overflow with automatic detection of scroll position.',
  ),
];
