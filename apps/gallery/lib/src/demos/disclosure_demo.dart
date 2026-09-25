import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const String _qrCodeUrl =
    'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/images/qr-code-native.png';

/// The "Preview HeroUI Native" heading of the docs examples.
Widget _previewHeading() => HeroDisclosureHeading(
  child: Center(
    child: HeroDisclosureTrigger.builder(
      builder: (BuildContext context, HeroDisclosureState state) => HeroButton(
        variant: HeroButtonVariant.secondary,
        onPressed: state.toggle,
        startContent: const HeroIcon(HeroIcons.qrCode),
        endContent: const HeroDisclosureIndicator(),
        child: const Text('Preview HeroUI Native'),
      ),
    ),
  ),
);

/// The QR code card of the docs examples.
class _QrCard extends StatelessWidget {
  const _QrCard();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle muted = theme.typography.sm.copyWith(
      color: theme.colors.muted,
    );
    return HeroDisclosureBody(
      child: HeroSurface(
        borderRadius: BorderRadius.circular(theme.radii.xl3),
        padding: EdgeInsets.all(theme.spacing(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Scan this QR code with your camera app to preview the HeroUI native components.',
              textAlign: TextAlign.center,
              style: muted,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: theme.spacing(54)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  _qrCodeUrl,
                  fit: BoxFit.cover,
                  semanticLabel: 'Expo Go QR Code',
                  errorBuilder:
                      (BuildContext context, Object error, StackTrace? stack) =>
                          Center(
                            child: HeroIcon(
                              HeroIcons.qrCode,
                              size: theme.spacing(24),
                              color: theme.colors.foreground,
                            ),
                          ),
                ),
              ),
            ),
            Text(
              'Expo must be installed on your device.',
              textAlign: TextAlign.center,
              style: muted,
            ),
            SizedBox(height: theme.spacing(4)),
            HeroButton(
              onPressed: () {},
              startContent: const HeroIcon(HeroIcons.smartphone),
              child: const Text('Download on App Store'),
            ),
          ],
        ),
      ),
    );
  }
}

const String _basicCode = '''
bool isExpanded = true;

HeroDisclosure(
  isExpanded: isExpanded,
  onExpandedChanged: (bool value) => setState(() => isExpanded = value),
  children: <Widget>[
    HeroDisclosureHeading(
      child: Center(
        child: HeroDisclosureTrigger.builder(
          builder: (BuildContext context, HeroDisclosureState state) =>
              HeroButton(
                variant: HeroButtonVariant.secondary,
                onPressed: state.toggle,
                startContent: const HeroIcon(HeroIcons.qrCode),
                endContent: const HeroDisclosureIndicator(),
                child: const Text('Preview HeroUI Native'),
              ),
        ),
      ),
    ),
    HeroDisclosureContent(
      child: HeroDisclosureBody(
        child: HeroSurface(
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              const Text('Scan this QR code with your camera app ...'),
              Image.network(qrCodeUrl, width: 216, height: 216),
              const Text('Expo must be installed on your device.'),
              const SizedBox(height: 16),
              HeroButton(
                onPressed: () {},
                child: const Text('Download on App Store'),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
)''';

final ComponentDemo disclosureDemo = ComponentDemo(
  slug: 'disclosure',
  playground: Playground(
    controls: const <PlaygroundControl>[
      ToggleControl('defaultExpanded'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => SizedBox(
      width: 320,
      child: HeroDisclosure(
        key: ValueKey<bool>(values.toggle('defaultExpanded')),
        defaultExpanded: values.toggle('defaultExpanded'),
        isDisabled: values.toggle('isDisabled'),
        children: const <Widget>[
          HeroDisclosureHeading(
            child: HeroDisclosureTrigger(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: <Widget>[
                  Text('Shipping details'),
                  HeroDisclosureIndicator(),
                ],
              ),
            ),
          ),
          HeroDisclosureContent(
            child: HeroDisclosureBody(
              child: Text('Orders ship within 2 business days.'),
            ),
          ),
        ],
      ),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroDisclosure(
  defaultExpanded: ${values.toggle('defaultExpanded')},
  isDisabled: ${values.toggle('isDisabled')},
  children: const <Widget>[
    HeroDisclosureHeading(
      child: HeroDisclosureTrigger(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            Text('Shipping details'),
            HeroDisclosureIndicator(),
          ],
        ),
      ),
    ),
    HeroDisclosureContent(
      child: HeroDisclosureBody(
        child: Text('Orders ship within 2 business days.'),
      ),
    ),
  ],
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _BasicDisclosure(),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Render Function',
      builder: (BuildContext context) => const _RenderFunctionDisclosure(),
      code: '''
HeroDisclosure(
  isExpanded: isExpanded,
  onExpandedChanged: (bool value) => setState(() => isExpanded = value),
  builder: (BuildContext context, HeroDisclosureState state) => Column(
    children: <Widget>[
      previewHeading,
      HeroDisclosureContent(
        builder: (BuildContext context, HeroDisclosureState state) =>
            qrCard,
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) => const _CustomDisclosure(),
      code: '''
HeroDisclosure(
  isExpanded: isExpanded,
  onExpandedChanged: (bool value) => setState(() => isExpanded = value),
  children: <Widget>[
    HeroDisclosureHeading(
      child: HeroDisclosureTrigger.builder(
        builder: (BuildContext context, HeroDisclosureState state) =>
            HeroButton(
              variant: HeroButtonVariant.ghost,
              fullWidth: true,
              onPressed: state.toggle,
              style: HeroButtonStyle(
                borderRadius: BorderRadius.circular(theme.radii.xl),
                side: BorderSide(color: colors.border.withValues(alpha: 0.7)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (Set<WidgetState> states) => states.contains(WidgetState.hovered)
                      ? colors.muted.withValues(alpha: 0.3)
                      : colors.surface,
                ),
                foregroundColor: WidgetStatePropertyAll<Color>(colors.foreground),
                shadows: theme.shadows.surface.boxShadows,
              ),
              child: Row(
                spacing: 8,
                children: <Widget>[
                  HeroIcon(HeroIcons.shoppingBag, color: colors.muted),
                  const Text('Shipping details'),
                  const Spacer(),
                  HeroDisclosureIndicator(color: colors.muted),
                ],
              ),
            ),
      ),
    ),
    HeroDisclosureContent(
      child: HeroDisclosureBody(
        padding: const EdgeInsets.only(top: 8),
        child: HeroSurface(
          color: colors.surface.withValues(alpha: 0.5),
          border: BorderSide(color: colors.border.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(theme.radii.xl),
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Orders ship within 2 business days. Standard delivery takes '
            '3–5 days; express is available at checkout.',
          ),
        ),
      ),
    ),
  ],
)''',
    ),
  ],
);

class _BasicDisclosure extends StatefulWidget {
  const _BasicDisclosure();

  @override
  State<_BasicDisclosure> createState() => _BasicDisclosureState();
}

class _BasicDisclosureState extends State<_BasicDisclosure> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: HeroDisclosure(
        isExpanded: _expanded,
        onExpandedChanged: (bool value) => setState(() => _expanded = value),
        children: <Widget>[
          _previewHeading(),
          const HeroDisclosureContent(child: _QrCard()),
        ],
      ),
    );
  }
}

class _RenderFunctionDisclosure extends StatefulWidget {
  const _RenderFunctionDisclosure();

  @override
  State<_RenderFunctionDisclosure> createState() =>
      _RenderFunctionDisclosureState();
}

class _RenderFunctionDisclosureState extends State<_RenderFunctionDisclosure> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: HeroDisclosure(
        isExpanded: _expanded,
        onExpandedChanged: (bool value) => setState(() => _expanded = value),
        builder: (BuildContext context, HeroDisclosureState state) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _previewHeading(),
            HeroDisclosureContent(
              builder: (BuildContext context, HeroDisclosureState state) =>
                  const _QrCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomDisclosure extends StatefulWidget {
  const _CustomDisclosure();

  @override
  State<_CustomDisclosure> createState() => _CustomDisclosureState();
}

class _CustomDisclosureState extends State<_CustomDisclosure> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final Color border = colors.border.withValues(alpha: colors.border.a * 0.7);
    final Color muted = colors.muted;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: HeroDisclosure(
        isExpanded: _expanded,
        onExpandedChanged: (bool value) => setState(() => _expanded = value),
        children: <Widget>[
          HeroDisclosureHeading(
            child: HeroDisclosureTrigger.builder(
              builder: (BuildContext context, HeroDisclosureState state) =>
                  HeroButton(
                    variant: HeroButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: state.toggle,
                    style: HeroButtonStyle(
                      borderRadius: BorderRadius.circular(theme.radii.xl),
                      side: BorderSide(color: border),
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacing(4),
                        vertical: theme.spacing(3),
                      ),
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (Set<WidgetState> states) =>
                            states.contains(WidgetState.hovered)
                            ? muted.withValues(alpha: muted.a * 0.3)
                            : colors.surface,
                      ),
                      foregroundColor: WidgetStatePropertyAll<Color>(
                        colors.foreground,
                      ),
                      shadows: theme.shadows.surface.boxShadows,
                    ),
                    child: Row(
                      spacing: theme.spacing(2),
                      children: <Widget>[
                        HeroIcon(HeroIcons.shoppingBag, color: muted),
                        const Text('Shipping details'),
                        const Spacer(),
                        HeroDisclosureIndicator(color: muted),
                      ],
                    ),
                  ),
            ),
          ),
          HeroDisclosureContent(
            child: HeroDisclosureBody(
              padding: EdgeInsets.only(top: theme.spacing(2)),
              child: HeroSurface(
                color: colors.surface.withValues(alpha: colors.surface.a * 0.5),
                border: BorderSide(color: border),
                borderRadius: BorderRadius.circular(theme.radii.xl),
                padding: EdgeInsets.all(theme.spacing(4)),
                child: Text(
                  'Orders ship within 2 business days. Standard delivery takes 3–5 days; express is available at checkout.',
                  style: theme.typography
                      .style(HeroFontSize.sm, lineHeight: 14 * 1.625)
                      .copyWith(color: muted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
