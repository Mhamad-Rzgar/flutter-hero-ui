import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _profile({
  HeroFieldVariant variant = HeroFieldVariant.primary,
  HeroButtonVariant cancel = HeroButtonVariant.secondary,
  bool isDisabled = false,
  Decoration? decoration,
  EdgeInsetsGeometry? padding,
}) {
  return HeroFieldset(
    isDisabled: isDisabled,
    decoration: decoration,
    padding: padding,
    children: <Widget>[
      const HeroFieldsetLegend.text('Profile Settings'),
      const HeroDescription.text('Update your profile information.'),
      HeroFieldsetGroup(
        children: <Widget>[
          HeroTextField(
            name: 'name',
            isRequired: true,
            variant: variant,
            children: const <Widget>[
              HeroLabel.text('Name'),
              HeroInput(placeholder: 'John Doe'),
              HeroFieldError(),
            ],
          ),
          HeroTextField(
            name: 'bio',
            isRequired: true,
            variant: variant,
            children: const <Widget>[
              HeroLabel.text('Bio'),
              HeroTextArea(placeholder: 'Tell us about yourself...'),
              HeroDescription.text('Minimum 10 characters'),
            ],
          ),
        ],
      ),
      HeroFieldsetActions(
        children: <Widget>[
          const HeroButton(
            type: HeroButtonType.submit,
            startContent: HeroIcon(HeroIcons.floppyDisk),
            child: Text('Save changes'),
          ),
          HeroButton(
            type: HeroButtonType.reset,
            variant: cancel,
            child: const Text('Cancel'),
          ),
        ],
      ),
    ],
  );
}

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  heroGoldenTest(
    'legend, description, fields and actions',
    name: 'basic',
    size: const Size(360, 420),
    builder: (HeroThemeData theme) => SizedBox(width: 320, child: _profile()),
  );

  heroGoldenTest(
    'disabled',
    name: 'disabled',
    size: const Size(360, 420),
    builder: (HeroThemeData theme) =>
        SizedBox(width: 320, child: _profile(isDisabled: true)),
  );

  heroGoldenTest(
    'secondary fields on a surface',
    name: 'on_surface',
    size: const Size(420, 480),
    builder: (HeroThemeData theme) => HeroSurface(
      padding: EdgeInsets.all(theme.spacing(6)),
      borderRadius: BorderRadius.circular(theme.radii.xl3),
      child: SizedBox(
        width: 340,
        child: _profile(
          variant: HeroFieldVariant.secondary,
          cancel: HeroButtonVariant.tertiary,
        ),
      ),
    ),
  );

  heroGoldenTest(
    'custom decoration',
    name: 'custom',
    size: const Size(380, 480),
    builder: (HeroThemeData theme) => SizedBox(
      width: 340,
      child: _profile(
        padding: EdgeInsets.all(theme.spacing(4)),
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              theme.colors.surfaceSecondary,
              theme.colors.surface,
            ],
          ),
          shape: theme.shapeAll(
            theme.radii.xl,
            side: BorderSide(color: theme.colors.border.withValues(alpha: 0.7)),
          ),
        ),
      ),
    ),
  );
}
