import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

Widget _wrap(List<Widget> children) =>
    Wrap(spacing: 12, runSpacing: 12, children: children);

/// Gallery page of `HeroButton`.
final ComponentDemo buttonDemo = ComponentDemo(
  slug: 'button',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>[
        'primary',
        'secondary',
        'tertiary',
        'outline',
        'ghost',
        'danger',
        'dangerSoft',
      ]),
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      ToggleControl('isIconOnly'),
      ToggleControl('fullWidth'),
      ToggleControl('isDisabled'),
      ToggleControl('isPending'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final bool iconOnly = values.toggle('isIconOnly');
      return HeroButton(
        variant: values.pick('variant', HeroButtonVariant.values),
        size: values.pick('size', HeroSize.values),
        isIconOnly: iconOnly,
        fullWidth: values.toggle('fullWidth'),
        isDisabled: values.toggle('isDisabled'),
        isPending: values.toggle('isPending'),
        semanticLabel: iconOnly ? 'Settings' : null,
        onPressed: () {},
        child: iconOnly ? const HeroIcon(HeroIcons.gear) : const Text('Button'),
      );
    },
    code: (PlaygroundValues values) {
      final bool iconOnly = values.toggle('isIconOnly');
      return '''
HeroButton(
  variant: HeroButtonVariant.${values.option('variant')},
  size: HeroSize.${values.option('size')},${iconOnly ? "\n  isIconOnly: true,\n  semanticLabel: 'Settings'," : ''}${values.toggle('fullWidth') ? '\n  fullWidth: true,' : ''}${values.toggle('isDisabled') ? '\n  isDisabled: true,' : ''}${values.toggle('isPending') ? '\n  isPending: true,' : ''}
  onPressed: () {},
  child: ${iconOnly ? 'const HeroIcon(HeroIcons.gear)' : "const Text('Button')"},
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => HeroButton(
        onPressed: () => debugPrint('Button pressed'),
        child: const Text('Click me'),
      ),
      code: '''
HeroButton(
  onPressed: () => debugPrint('Button pressed'),
  child: const Text('Click me'),
)''',
    ),
    DemoExample(
      title: 'Variants',
      builder: (BuildContext context) => _wrap(<Widget>[
        HeroButton(onPressed: () {}, child: const Text('Primary')),
        HeroButton(
          variant: HeroButtonVariant.secondary,
          onPressed: () {},
          child: const Text('Secondary'),
        ),
        HeroButton(
          variant: HeroButtonVariant.tertiary,
          onPressed: () {},
          child: const Text('Tertiary'),
        ),
        HeroButton(
          variant: HeroButtonVariant.outline,
          onPressed: () {},
          child: const Text('Outline'),
        ),
        HeroButton(
          variant: HeroButtonVariant.ghost,
          onPressed: () {},
          child: const Text('Ghost'),
        ),
        HeroButton(
          variant: HeroButtonVariant.danger,
          onPressed: () {},
          child: const Text('Danger'),
        ),
        HeroButton(
          variant: HeroButtonVariant.dangerSoft,
          onPressed: () {},
          child: const Text('Danger Soft'),
        ),
      ]),
      code: '''
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    HeroButton(onPressed: () {}, child: const Text('Primary')),
    HeroButton(
      variant: HeroButtonVariant.secondary,
      onPressed: () {},
      child: const Text('Secondary'),
    ),
    HeroButton(
      variant: HeroButtonVariant.tertiary,
      onPressed: () {},
      child: const Text('Tertiary'),
    ),
    HeroButton(
      variant: HeroButtonVariant.outline,
      onPressed: () {},
      child: const Text('Outline'),
    ),
    HeroButton(
      variant: HeroButtonVariant.ghost,
      onPressed: () {},
      child: const Text('Ghost'),
    ),
    HeroButton(
      variant: HeroButtonVariant.danger,
      onPressed: () {},
      child: const Text('Danger'),
    ),
    HeroButton(
      variant: HeroButtonVariant.dangerSoft,
      onPressed: () {},
      child: const Text('Danger Soft'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          HeroButton(
            size: HeroSize.sm,
            onPressed: () {},
            child: const Text('Small'),
          ),
          HeroButton(
            size: HeroSize.md,
            onPressed: () {},
            child: const Text('Medium'),
          ),
          HeroButton(
            size: HeroSize.lg,
            onPressed: () {},
            child: const Text('Large'),
          ),
        ],
      ),
      code: '''
Wrap(
  spacing: 12,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: [
    HeroButton(size: HeroSize.sm, onPressed: () {}, child: const Text('Small')),
    HeroButton(size: HeroSize.md, onPressed: () {}, child: const Text('Medium')),
    HeroButton(size: HeroSize.lg, onPressed: () {}, child: const Text('Large')),
  ],
)''',
    ),
    DemoExample(
      title: 'With Icons',
      builder: (BuildContext context) => _wrap(<Widget>[
        HeroButton(
          startContent: const HeroIcon(HeroIcons.globe),
          onPressed: () {},
          child: const Text('Search'),
        ),
        HeroButton(
          variant: HeroButtonVariant.secondary,
          startContent: const HeroIcon(HeroIcons.plus),
          onPressed: () {},
          child: const Text('Add Member'),
        ),
        HeroButton(
          variant: HeroButtonVariant.tertiary,
          startContent: const HeroIcon(HeroIcons.envelope),
          onPressed: () {},
          child: const Text('Email'),
        ),
        HeroButton(
          variant: HeroButtonVariant.danger,
          startContent: const HeroIcon(HeroIcons.trashBin),
          onPressed: () {},
          child: const Text('Delete'),
        ),
      ]),
      code: '''
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    HeroButton(
      startContent: const HeroIcon(HeroIcons.globe),
      onPressed: () {},
      child: const Text('Search'),
    ),
    HeroButton(
      variant: HeroButtonVariant.secondary,
      startContent: const HeroIcon(HeroIcons.plus),
      onPressed: () {},
      child: const Text('Add Member'),
    ),
    HeroButton(
      variant: HeroButtonVariant.tertiary,
      startContent: const HeroIcon(HeroIcons.envelope),
      onPressed: () {},
      child: const Text('Email'),
    ),
    HeroButton(
      variant: HeroButtonVariant.danger,
      startContent: const HeroIcon(HeroIcons.trashBin),
      onPressed: () {},
      child: const Text('Delete'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Icon Only',
      builder: (BuildContext context) => _wrap(<Widget>[
        HeroButton(
          isIconOnly: true,
          semanticLabel: 'More options',
          variant: HeroButtonVariant.tertiary,
          onPressed: () {},
          child: const HeroIcon(HeroIcons.ellipsis),
        ),
        HeroButton(
          isIconOnly: true,
          semanticLabel: 'Settings',
          variant: HeroButtonVariant.secondary,
          onPressed: () {},
          child: const HeroIcon(HeroIcons.gear),
        ),
        HeroButton(
          isIconOnly: true,
          semanticLabel: 'Delete',
          variant: HeroButtonVariant.danger,
          onPressed: () {},
          child: const HeroIcon(HeroIcons.trashBin),
        ),
      ]),
      code: '''
Wrap(
  spacing: 12,
  children: [
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'More options',
      variant: HeroButtonVariant.tertiary,
      onPressed: () {},
      child: const HeroIcon(HeroIcons.ellipsis),
    ),
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Settings',
      variant: HeroButtonVariant.secondary,
      onPressed: () {},
      child: const HeroIcon(HeroIcons.gear),
    ),
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Delete',
      variant: HeroButtonVariant.danger,
      onPressed: () {},
      child: const HeroIcon(HeroIcons.trashBin),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Loading',
      description:
          'A pending button ignores presses, stays focusable and shows a '
          'small spinner in the start slot.',
      builder: (BuildContext context) => HeroButton(
        isPending: true,
        onPressed: () {},
        child: const Text('Uploading...'),
      ),
      code: '''
HeroButton(
  isPending: true,
  onPressed: () {},
  child: const Text('Uploading...'),
)

// Or render the pending state yourself:
HeroButton(
  isPending: true,
  onPressed: () {},
  builder: (context, state) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 8,
    children: [
      if (state.isPending)
        const HeroSpinner(
          color: HeroSpinnerColor.current,
          size: HeroSpinnerSize.sm,
        ),
      const Text('Uploading...'),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Loading State',
      builder: (BuildContext context) => const _LoadingStateExample(),
      code: '''
class LoadingState extends StatefulWidget {
  const LoadingState({super.key});

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState> {
  bool _loading = false;

  void _handlePress() {
    setState(() => _loading = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // While pending, the spinner replaces the paperclip icon.
    return HeroButton(
      isPending: _loading,
      onPressed: _handlePress,
      startContent: const HeroIcon(HeroIcons.paperclip),
      child: Text(_loading ? 'Uploading...' : 'Upload File'),
    );
  }
}''',
    ),
    DemoExample(
      title: 'Full Width',
      builder: (BuildContext context) => SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            HeroButton(
              fullWidth: true,
              onPressed: () {},
              child: const Text('Primary Button'),
            ),
            HeroButton(
              fullWidth: true,
              startContent: const HeroIcon(HeroIcons.plus),
              onPressed: () {},
              child: const Text('With Icon'),
            ),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 400,
  child: Column(
    spacing: 12,
    children: [
      HeroButton(
        fullWidth: true,
        onPressed: () {},
        child: const Text('Primary Button'),
      ),
      HeroButton(
        fullWidth: true,
        startContent: const HeroIcon(HeroIcons.plus),
        onPressed: () {},
        child: const Text('With Icon'),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Disabled State',
      builder: (BuildContext context) => _wrap(<Widget>[
        HeroButton(
          isDisabled: true,
          onPressed: () {},
          child: const Text('Primary'),
        ),
        HeroButton(
          isDisabled: true,
          variant: HeroButtonVariant.secondary,
          onPressed: () {},
          child: const Text('Secondary'),
        ),
        HeroButton(
          isDisabled: true,
          variant: HeroButtonVariant.tertiary,
          onPressed: () {},
          child: const Text('Tertiary'),
        ),
        HeroButton(
          isDisabled: true,
          variant: HeroButtonVariant.outline,
          onPressed: () {},
          child: const Text('Outline'),
        ),
        HeroButton(
          isDisabled: true,
          variant: HeroButtonVariant.ghost,
          onPressed: () {},
          child: const Text('Ghost'),
        ),
        HeroButton(
          isDisabled: true,
          variant: HeroButtonVariant.danger,
          onPressed: () {},
          child: const Text('Danger'),
        ),
      ]),
      code: '''
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    HeroButton(isDisabled: true, onPressed: () {}, child: const Text('Primary')),
    HeroButton(
      isDisabled: true,
      variant: HeroButtonVariant.secondary,
      onPressed: () {},
      child: const Text('Secondary'),
    ),
    HeroButton(
      isDisabled: true,
      variant: HeroButtonVariant.tertiary,
      onPressed: () {},
      child: const Text('Tertiary'),
    ),
    HeroButton(
      isDisabled: true,
      variant: HeroButtonVariant.outline,
      onPressed: () {},
      child: const Text('Outline'),
    ),
    HeroButton(
      isDisabled: true,
      variant: HeroButtonVariant.ghost,
      onPressed: () {},
      child: const Text('Ghost'),
    ),
    HeroButton(
      isDisabled: true,
      variant: HeroButtonVariant.danger,
      onPressed: () {},
      child: const Text('Danger'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Social Buttons',
      builder: (BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: <Widget>[
            HeroButton(
              fullWidth: true,
              variant: HeroButtonVariant.tertiary,
              startContent: const _GoogleLogo(),
              onPressed: () {},
              child: const Text('Sign in with Google'),
            ),
            HeroButton(
              fullWidth: true,
              variant: HeroButtonVariant.tertiary,
              startContent: const HeroIcon(_githubLogo),
              onPressed: () {},
              child: const Text('Sign in with GitHub'),
            ),
            HeroButton(
              fullWidth: true,
              variant: HeroButtonVariant.tertiary,
              startContent: const HeroIcon(_appleLogo),
              onPressed: () {},
              child: const Text('Sign in with Apple'),
            ),
          ],
        ),
      ),
      code: '''
// Brand logos are HeroIconData built from their SVG paths.
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 320),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: [
      HeroButton(
        fullWidth: true,
        variant: HeroButtonVariant.tertiary,
        startContent: const GoogleLogo(),
        onPressed: () {},
        child: const Text('Sign in with Google'),
      ),
      HeroButton(
        fullWidth: true,
        variant: HeroButtonVariant.tertiary,
        startContent: const HeroIcon(githubLogo),
        onPressed: () {},
        child: const Text('Sign in with GitHub'),
      ),
      HeroButton(
        fullWidth: true,
        variant: HeroButtonVariant.tertiary,
        startContent: const HeroIcon(appleLogo),
        onPressed: () {},
        child: const Text('Sign in with Apple'),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'builder receives the button state (isPressed, isHovered, '
          'isFocusVisible, isPending, ...).',
      builder: (BuildContext context) => HeroButton(
        onPressed: () {},
        builder: (BuildContext context, HeroButtonState state) =>
            Text(state.isPressed ? 'Pressed' : 'Press me'),
      ),
      code: '''
HeroButton(
  onPressed: () {},
  builder: (context, state) =>
      Text(state.isPressed ? 'Pressed' : 'Press me'),
)''',
    ),
    DemoExample(
      title: 'Adding custom variants',
      description:
          'Wrap HeroButton and add your own variants through '
          'HeroButtonStyle.',
      builder: (BuildContext context) =>
          const _CustomButton(child: Text('Custom Button')),
      code: '''
enum CustomRadius { full, lg, md, sm }

enum CustomSize { sm, md, lg, xl }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.child,
    this.onPressed,
    this.radius = CustomRadius.full,
    this.size = CustomSize.md,
    this.isPending = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final CustomRadius radius;
  final CustomSize size;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final theme = HeroTheme.of(context);
    final (height, padding) = switch (size) {
      CustomSize.sm => (40.0, 16.0),
      CustomSize.md => (44.0, 24.0),
      CustomSize.lg => (48.0, 32.0),
      CustomSize.xl => (52.0, 40.0),
    };
    final r = switch (radius) {
      CustomRadius.full => theme.radii.full,
      CustomRadius.lg => theme.radii.lg,
      CustomRadius.md => theme.radii.md,
      CustomRadius.sm => theme.radii.sm,
    };
    return Opacity(
      opacity: isPending ? 0.4 : 1,
      child: HeroButton(
        isPending: isPending,
        onPressed: onPressed,
        style: HeroButtonStyle(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: padding),
          borderRadius: BorderRadius.circular(r),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            shadows: textShadowLg,
          ),
          shadows: shadowMd,
          foregroundColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
          backgroundColor: theme.isDark
              ? WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.hovered)
                      ? const Color(0x26FFFFFF)
                      : const Color(0x1AFFFFFF))
              : null,
        ),
        child: child,
      ),
    );
  }
}''',
    ),
    DemoExample(
      title: 'Adding Ripple Effect',
      description:
          'The ripple is composed around the button: a clipped layer that '
          'grows from the touch point, like m3-ripple in the HeroUI docs.',
      builder: (BuildContext context) => const _RippleButton(),
      code: '''
// A ripple layer is stacked over the button and clipped to its shape; the
// whole stack scales on press.
RippleButton(
  child: HeroButton(
    variant: HeroButtonVariant.secondary,
    style: const HeroButtonStyle(pressedScale: 1),
    onPressed: () {},
    child: const Text('Click me'),
  ),
)''',
    ),
    DemoExample(
      title: 'Custom Styles',
      description:
          'Customization: an "Upgrade" pill built from HeroInteractable, '
          'HeroFocusRing and a gradient surface.',
      builder: (BuildContext context) => const _UpgradeButton(),
      code: '''
HeroInteractable(
  onPressed: () {},
  builder: (context, state, _) {
    final dark = HeroTheme.of(context).isDark;
    const shape = StadiumBorder();
    return HeroFocusRing(
      visible: state.isFocusVisible,
      shape: shape,
      child: AnimatedScale(
        scale: state.isPressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(0.34, 1.56, 0.64, 1),
        child: CustomPaint(
          // 1.5 px 315deg gradient border.
          foregroundPainter: GradientBorderPainter(dark: dark),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: shape,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: state.isHovered
                    ? [Color(0xFFFFFFFF), Color(0xFFFAFAFA)]
                    : [Color(0xFFF5F5F5), Color(0xFFFFFFFF)],
              ),
              shadows: layeredSoftShadows,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              child: Text('Upgrade'),
            ),
          ),
        ),
      ),
    );
  },
)''',
    ),
  ],
);

class _LoadingStateExample extends StatefulWidget {
  const _LoadingStateExample();

  @override
  State<_LoadingStateExample> createState() => _LoadingStateExampleState();
}

class _LoadingStateExampleState extends State<_LoadingStateExample> {
  bool _loading = false;

  void _handlePress() {
    setState(() => _loading = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeroButton(
      isPending: _loading,
      onPressed: _handlePress,
      startContent: const HeroIcon(HeroIcons.paperclip),
      child: Text(_loading ? 'Uploading...' : 'Upload File'),
    );
  }
}

// Brand logos for the social buttons (mdi:github, ion:logo-apple and the
// four-color Google "G").
const HeroIconData _githubLogo = HeroIconData(
  <HeroIconPath>[
    HeroIconPath(
      'M12 2A10 10 0 0 0 2 12c0 4.42 2.87 8.17 6.84 9.5c.5.08.66-.23.66-.5v-1.69'
      'c-2.77.6-3.36-1.34-3.36-1.34c-.46-1.16-1.11-1.47-1.11-1.47c-.91-.62.07-.6'
      '.07-.6c1 .07 1.53 1.03 1.53 1.03c.87 1.52 2.34 1.07 2.91.83c.09-.65.35-1.09'
      '.63-1.34c-2.22-.25-4.55-1.11-4.55-4.92c0-1.11.38-2 1.03-2.71c-.1-.25-.45'
      '-1.29.1-2.64c0 0 .84-.27 2.75 1.02c.79-.22 1.65-.33 2.5-.33s1.71.11 2.5.33'
      'c1.91-1.29 2.75-1.02 2.75-1.02c.55 1.35.2 2.39.1 2.64c.65.71 1.03 1.6 1.03'
      ' 2.71c0 3.82-2.34 4.66-4.57 4.91c.36.31.69.92.69 1.85V21c0 .27.16.59.67.5'
      'C19.14 20.16 22 16.42 22 12A10 10 0 0 0 12 2',
    ),
  ],
  viewBoxWidth: 24,
  viewBoxHeight: 24,
);

const HeroIconData _appleLogo = HeroIconData(
  <HeroIconPath>[
    HeroIconPath(
      'M349.13 136.86c-40.32 0-57.36 19.24-85.44 19.24c-28.79 0-50.75-19.1'
      '-85.69-19.1c-34.2 0-70.67 20.88-93.83 56.45c-32.52 50.16-27 144.63 25.67'
      ' 225.11c18.84 28.81 44 61.12 77 61.47h.6c28.68 0 37.2-18.78 76.67-19h.6'
      'c38.88 0 46.68 18.89 75.24 18.89h.6c33-.35 59.51-36.15 78.35-64.85c13.56'
      '-20.64 18.6-31 29-54.35c-76.19-28.92-88.43-136.93-13.08-178.34c-23-28.8'
      '-55.32-45.48-85.79-45.48Z',
    ),
    HeroIconPath(
      'M340.25 32c-24 1.63-52 16.91-68.4 36.86c-14.88 18.08-27.12 44.9-22.32'
      ' 70.91h1.92c25.56 0 51.72-15.39 67-35.11c14.72-19.01 25.88-45.95 21.8'
      '-72.66Z',
    ),
  ],
  viewBoxWidth: 512,
  viewBoxHeight: 512,
);

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  static const List<(String, Color)> _parts = <(String, Color)>[
    (
      'M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844c-.209 1.125-.843'
          ' 2.078-1.796 2.717v2.258h2.908c1.702-1.567 2.684-3.874 2.684-6.615z',
      Color(0xFF4285F4),
    ),
    (
      'M9 18c2.43 0 4.467-.806 5.956-2.18l-2.908-2.259c-.806.54-1.837.86-3.048'
          '.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332A8.997 8.997 0 0 0 9 18z',
      Color(0xFF34A853),
    ),
    (
      'M3.964 10.71A5.41 5.41 0 0 1 3.682 9c0-.593.102-1.17.282-1.71V4.958H.957'
          'A8.996 8.996 0 0 0 0 9c0 1.452.348 2.827.957 4.042l3.007-2.332z',
      Color(0xFFFBBC05),
    ),
    (
      'M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0'
          'A8.997 8.997 0 0 0 .957 4.958L3.964 7.29C4.672 5.163 6.656 3.58 9 3.58z',
      Color(0xFFEA4335),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double size = IconTheme.of(context).size ?? 16;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: <Widget>[
          for (final (String path, Color color) in _parts)
            HeroIcon(
              HeroIconData(
                <HeroIconPath>[HeroIconPath(path)],
                viewBoxWidth: 18,
                viewBoxHeight: 18,
              ),
              size: size,
              color: color,
            ),
        ],
      ),
    );
  }
}

enum _CustomRadius { full, lg, md, sm }

enum _CustomSize { sm, md, lg, xl }

/// The docs' `CustomButton`: extra radius and size variants, semibold text
/// and a medium shadow on top of HeroButton.
class _CustomButton extends StatelessWidget {
  const _CustomButton({
    required this.child,
    // ignore: unused_element_parameter
    this.radius = _CustomRadius.full,
    // ignore: unused_element_parameter
    this.size = _CustomSize.md,
    // ignore: unused_element_parameter
    this.isPending = false,
  });

  final Widget child;
  final _CustomRadius radius;
  final _CustomSize size;
  final bool isPending;

  // Tailwind's shadow-md and text-shadow-lg.
  static const List<BoxShadow> _shadowMd = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];
  static const List<Shadow> _textShadowLg = <Shadow>[
    Shadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 2),
    Shadow(color: Color(0x1A000000), offset: Offset(0, 3), blurRadius: 2),
    Shadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 8),
  ];

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final (double height, double padding) = switch (size) {
      _CustomSize.sm => (theme.spacing(10), theme.spacing(4)),
      _CustomSize.md => (theme.spacing(11), theme.spacing(6)),
      _CustomSize.lg => (theme.spacing(12), theme.spacing(8)),
      _CustomSize.xl => (theme.spacing(13), theme.spacing(10)),
    };
    final double r = switch (radius) {
      _CustomRadius.full => theme.radii.full,
      _CustomRadius.lg => theme.radii.lg,
      _CustomRadius.md => theme.radii.md,
      _CustomRadius.sm => theme.radii.sm,
    };
    return Opacity(
      opacity: isPending ? 0.4 : 1,
      child: HeroButton(
        isPending: isPending,
        onPressed: () {},
        style: HeroButtonStyle(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: padding),
          borderRadius: BorderRadius.circular(r),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            shadows: _textShadowLg,
          ),
          shadows: _shadowMd,
          foregroundColor: const WidgetStatePropertyAll<Color>(
            Color(0xFFFFFFFF),
          ),
          backgroundColor: theme.isDark
              ? WidgetStateProperty.resolveWith(
                  (Set<WidgetState> states) =>
                      states.contains(WidgetState.hovered)
                      ? const Color(0x26FFFFFF)
                      : const Color(0x1AFFFFFF),
                )
              : null,
        ),
        child: child,
      ),
    );
  }
}

/// A secondary button with a Material-3-style ripple layer composed on top.
class _RippleButton extends StatefulWidget {
  const _RippleButton();

  @override
  State<_RippleButton> createState() => _RippleButtonState();
}

class _Ripple {
  _Ripple(this.center, this.grow, this.fade);

  final Offset center;
  final AnimationController grow;
  final AnimationController fade;

  void dispose() {
    grow.dispose();
    fade.dispose();
  }
}

class _RippleButtonState extends State<_RippleButton>
    with TickerProviderStateMixin {
  final List<_Ripple> _ripples = <_Ripple>[];
  bool _pressed = false;

  void _down(PointerDownEvent event) {
    final _Ripple ripple = _Ripple(
      event.localPosition,
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      ),
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 375),
      ),
    );
    setState(() {
      _pressed = true;
      _ripples.add(ripple);
    });
    ripple.grow.forward();
  }

  void _up(PointerEvent event) {
    setState(() => _pressed = false);
    for (final _Ripple ripple in List<_Ripple>.of(_ripples)) {
      if (ripple.fade.isAnimating || ripple.fade.isCompleted) continue;
      ripple.grow.forward().whenComplete(() {
        if (!mounted) return;
        ripple.fade.forward().whenComplete(() {
          if (!mounted) return;
          setState(() => _ripples.remove(ripple));
          ripple.dispose();
        });
      });
    }
  }

  @override
  void dispose() {
    for (final _Ripple ripple in _ripples) {
      ripple.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Listener(
      onPointerDown: _down,
      onPointerUp: _up,
      onPointerCancel: _up,
      child: HeroPressScale(
        pressed: _pressed,
        child: Stack(
          children: <Widget>[
            HeroButton(
              variant: HeroButtonVariant.secondary,
              style: const HeroButtonStyle(pressedScale: 1),
              onPressed: () {},
              child: const Text('Click me'),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: ClipPath(
                  clipper: ShapeBorderClipper(
                    shape: theme.shapeAll(theme.radii.xl3),
                  ),
                  child: CustomPaint(
                    painter: _RipplePainter(
                      ripples: List<_Ripple>.of(_ripples),
                      color: theme.colors.accentSoftForeground,
                      repaint: Listenable.merge(<Listenable>[
                        for (final _Ripple r in _ripples) ...<Listenable>[
                          r.grow,
                          r.fade,
                        ],
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({
    required this.ripples,
    required this.color,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<_Ripple> ripples;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double maxRadius = size.longestSide;
    for (final _Ripple ripple in ripples) {
      final double t = HeroMotion.easeOut.transform(ripple.grow.value);
      final double opacity = 0.12 * (1 - ripple.fade.value);
      canvas.drawCircle(
        ripple.center,
        maxRadius * (0.2 + 0.8 * t),
        Paint()..color = color.withValues(alpha: color.a * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => true;
}

/// The docs' "Upgrade" button: a neutral gradient pill with a 1.5 px
/// gradient border, soft layered shadows and a springy press.
class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton();

  static const List<BoxShadow> _shadows = <BoxShadow>[
    BoxShadow(color: Color(0x05000000), offset: Offset(0, 1), blurRadius: 6),
    BoxShadow(color: Color(0x05000000), offset: Offset(0, 3), blurRadius: 12),
    BoxShadow(color: Color(0x03000000), offset: Offset(0, 8), blurRadius: 24),
    BoxShadow(color: Color(0x05000000), offset: Offset(0, 18), blurRadius: 40),
    BoxShadow(color: Color(0x05000000), offset: Offset(0, 40), blurRadius: 80),
  ];

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool dark = theme.isDark;
    const ShapeBorder shape = StadiumBorder();
    return HeroInteractable(
      onPressed: () {},
      builder: (BuildContext context, HeroInteractionState state, _) {
        final List<Color> fill = switch ((dark, state.isHovered)) {
          (false, false) => const <Color>[Color(0xFFF5F5F5), Color(0xFFFFFFFF)],
          (false, true) => const <Color>[Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
          (true, false) => const <Color>[
            Color(0xFF171717),
            Color(0xFF262626),
            Color(0xCC262626),
          ],
          (true, true) => const <Color>[
            Color(0xFF262626),
            Color(0xFF262626),
            Color(0xE6171717),
          ],
        };
        return HeroFocusRing(
          visible: state.isFocusVisible,
          shape: shape,
          child: AnimatedScale(
            scale: state.isPressed ? 0.95 : 1,
            duration: theme.motion.resolve(context, HeroMotion.slower),
            curve: const Cubic(0.34, 1.56, 0.64, 1),
            child: CustomPaint(
              foregroundPainter: _GradientBorderPainter(
                colors: dark
                    ? const <Color>[
                        Color(0xFF404040),
                        Color(0xFF262626),
                        Color(0xFF525252),
                      ]
                    : const <Color>[
                        Color(0xFFE5E5E5),
                        Color(0xFFFAFAFA),
                        Color(0xFFC4C4C4),
                      ],
              ),
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: shape,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: fill,
                  ),
                  shadows: _shadows,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing(10),
                    vertical: theme.spacing(3),
                  ),
                  child: Text(
                    'Upgrade',
                    style: theme.typography.sm.copyWith(
                      color: dark
                          ? const Color(0xFFF5F5F5)
                          : const Color(0xFF262626),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  const _GradientBorderPainter({required this.colors});

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    const StadiumBorder shape = StadiumBorder();
    final Path band = Path.combine(
      PathOperation.difference,
      shape.getOuterPath(rect),
      shape.getOuterPath(rect.deflate(1.5)),
    );
    canvas.drawPath(
      band,
      Paint()
        ..shader = LinearGradient(
          // CSS 315deg runs from the bottom-right to the top-left corner.
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: colors,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
