import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _column(List<Widget> children, {double width = 280}) => SizedBox(
  width: width,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: children,
  ),
);

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  heroGoldenTest(
    'icon and text addons',
    name: 'addons',
    size: const Size(320, 420),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroTextField(
        children: <Widget>[
          HeroLabel.text('Email address'),
          HeroInputGroup(
            children: <Widget>[
              HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
              HeroInputGroupInput(placeholder: 'name@email.com'),
            ],
          ),
          HeroDescription.text("We'll never share this with anyone else"),
        ],
      ),
      HeroTextField(
        defaultValue: 'heroui.com',
        children: <Widget>[
          HeroLabel.text('Website'),
          HeroInputGroup(
            startContent: Text('https://'),
            child: HeroInputGroupInput(),
          ),
        ],
      ),
      HeroTextField(
        defaultValue: 'heroui',
        children: <Widget>[
          HeroLabel.text('Website'),
          HeroInputGroup(
            startContent: HeroIcon(HeroIcons.globe),
            endContent: Text('.com'),
          ),
        ],
      ),
      HeroTextField(
        defaultValue: '10',
        type: HeroInputType.number,
        children: <Widget>[
          HeroLabel.text('Set a price'),
          HeroInputGroup(startContent: Text(r'$'), endContent: Text('USD')),
          HeroDescription.text('What customers would pay'),
        ],
      ),
    ]),
  );

  heroGoldenTest(
    'variants on the background and a surface',
    name: 'variants',
    size: const Size(360, 300),
    builder: (HeroThemeData theme) => HeroSurface(
      padding: EdgeInsets.all(theme.spacing(6)),
      borderRadius: BorderRadius.circular(theme.radii.xl2),
      child: _column(const <Widget>[
        HeroTextField(
          children: <Widget>[
            HeroLabel.text('Primary variant'),
            HeroInputGroup(
              startContent: HeroIcon(HeroIcons.envelope),
              child: HeroInputGroupInput(placeholder: 'name@email.com'),
            ),
          ],
        ),
        HeroTextField(
          variant: HeroFieldVariant.secondary,
          children: <Widget>[
            HeroLabel.text('Secondary variant'),
            HeroInputGroup(
              startContent: HeroIcon(HeroIcons.envelope),
              child: HeroInputGroupInput(placeholder: 'name@email.com'),
            ),
          ],
        ),
      ]),
    ),
  );

  heroGoldenTest(
    'required, disabled, invalid and focused',
    name: 'states',
    size: const Size(320, 420),
    whilePerforming: (WidgetTester tester) async {
      await tester.tap(find.text('Focused'));
    },
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroTextField(
        isRequired: true,
        children: <Widget>[
          HeroLabel.text('Email address'),
          HeroInputGroup(
            startContent: HeroIcon(HeroIcons.envelope),
            child: HeroInputGroupInput(placeholder: 'name@email.com'),
          ),
        ],
      ),
      HeroTextField(
        isDisabled: true,
        defaultValue: '10',
        children: <Widget>[
          HeroLabel.text('Set a price'),
          HeroInputGroup(startContent: Text(r'$'), endContent: Text('USD')),
        ],
      ),
      HeroTextField(
        isInvalid: true,
        isRequired: true,
        children: <Widget>[
          HeroLabel.text('Email address'),
          HeroInputGroup(
            startContent: HeroIcon(HeroIcons.envelope),
            child: HeroInputGroupInput(placeholder: 'name@email.com'),
          ),
          HeroFieldError.text('Please enter a valid email address'),
        ],
      ),
      HeroTextField(
        children: <Widget>[
          HeroInputGroup(
            endContent: HeroIcon(HeroIcons.envelope),
            child: HeroInputGroupInput(placeholder: 'Focused'),
          ),
        ],
      ),
    ]),
  );

  heroGoldenTest(
    'control suffixes',
    name: 'controls',
    size: const Size(320, 320),
    // Reduced motion keeps the spinner still.
    builder: (HeroThemeData theme) => HeroTheme(
      data: theme.copyWith(motion: const HeroMotion(reduceMotion: true)),
      child: _column(<Widget>[
        const HeroTextField(
          defaultValue: 'Sending...',
          children: <Widget>[
            HeroInputGroup(endContent: HeroSpinner(size: HeroSpinnerSize.sm)),
          ],
        ),
        HeroTextField(
          defaultValue: 'heroui.com',
          children: <Widget>[
            HeroInputGroup(
              children: <Widget>[
                const HeroInputGroupPrefix(child: HeroIcon(HeroIcons.globe)),
                const HeroInputGroupInput(),
                HeroInputGroupSuffix(
                  padding: EdgeInsets.zero,
                  child: HeroButton(
                    isIconOnly: true,
                    size: HeroSize.sm,
                    variant: HeroButtonVariant.ghost,
                    semanticLabel: 'Copy',
                    onPressed: () {},
                    child: const HeroIcon(HeroIcons.copy),
                  ),
                ),
              ],
            ),
          ],
        ),
        HeroTextField(
          children: <Widget>[
            HeroInputGroup(
              children: <Widget>[
                const HeroInputGroupInput(placeholder: 'Command'),
                HeroInputGroupSuffix(
                  padding: EdgeInsetsDirectional.only(
                    start: theme.spacing(3),
                    end: theme.spacing(2),
                  ),
                  child: const HeroKbd(
                    keys: <HeroKbdKey>[HeroKbdKey.command],
                    text: 'K',
                  ),
                ),
              ],
            ),
          ],
        ),
        HeroTextField(
          children: <Widget>[
            HeroInputGroup(
              children: <Widget>[
                const HeroInputGroupInput(placeholder: 'Email address'),
                HeroInputGroupSuffix(
                  padding: EdgeInsetsDirectional.only(
                    start: theme.spacing(3),
                    end: theme.spacing(2),
                  ),
                  child: const HeroChip(
                    label: 'Pro',
                    color: HeroColor.accent,
                    variant: HeroChipVariant.soft,
                  ),
                ),
              ],
            ),
          ],
        ),
      ]),
    ),
  );

  heroGoldenTest(
    'text areas',
    name: 'textarea',
    size: const Size(400, 460),
    builder: (HeroThemeData theme) => _column(width: 360, <Widget>[
      const HeroTextField(
        fullWidth: true,
        children: <Widget>[
          HeroLabel.text('Your Feedback'),
          HeroInputGroup(
            children: <Widget>[
              HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
              HeroInputGroupTextArea(
                placeholder: 'Share your thoughts, suggestions, or issues...',
                rows: 3,
              ),
            ],
          ),
          HeroDescription.text('Maximum 500 characters.'),
        ],
      ),
      HeroTextField(
        fullWidth: true,
        semanticLabel: 'Prompt input',
        children: <Widget>[
          HeroInputGroup(
            direction: Axis.vertical,
            spacing: theme.spacing(2),
            padding: EdgeInsets.symmetric(vertical: theme.spacing(2)),
            style: HeroFieldStyle(
              borderRadius: BorderRadius.circular(theme.radii.xl3),
            ),
            children: <Widget>[
              HeroInputGroupPrefix(
                padding: EdgeInsets.symmetric(horizontal: theme.spacing(3)),
                child: HeroButton(
                  size: HeroSize.sm,
                  variant: HeroButtonVariant.outline,
                  startContent: const HeroIcon(HeroIcons.at),
                  onPressed: () {},
                  child: const Text('Add Context'),
                ),
              ),
              HeroInputGroupTextArea(
                placeholder: 'Assign tasks or ask anything...',
                rows: 3,
                style: HeroFieldStyle(
                  padding: EdgeInsets.symmetric(horizontal: theme.spacing(3.5)),
                ),
              ),
              HeroInputGroupSuffix(
                padding: EdgeInsets.symmetric(horizontal: theme.spacing(3)),
                child: Row(
                  spacing: theme.spacing(1.5),
                  children: <Widget>[
                    HeroButton(
                      isIconOnly: true,
                      size: HeroSize.sm,
                      variant: HeroButtonVariant.tertiary,
                      semanticLabel: 'Attach file',
                      onPressed: () {},
                      child: const HeroIcon(HeroIcons.plus),
                    ),
                    const Spacer(),
                    HeroButton(
                      isIconOnly: true,
                      size: HeroSize.sm,
                      semanticLabel: 'Send prompt',
                      isDisabled: true,
                      onPressed: () {},
                      child: const HeroIcon(HeroIcons.arrowUp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ]),
  );

  heroGoldenTest(
    'custom style and right to left',
    name: 'custom',
    size: const Size(360, 220),
    builder: (HeroThemeData theme) => _column(width: 320, <Widget>[
      HeroTextField(
        children: <Widget>[
          const HeroLabel.text('Work email'),
          HeroInputGroup(
            style: HeroFieldStyle(
              borderRadius: BorderRadius.circular(theme.radii.xl),
              borderWidth: theme.borderWidth,
              borderColor: theme.colors.border.withValues(alpha: 0.8),
              backgroundColor: theme.colors.defaultColor,
              shadow: theme.shadows.surface,
            ),
            startContent: const HeroIcon(HeroIcons.envelope),
            child: const HeroInputGroupInput(placeholder: 'you@company.com'),
          ),
        ],
      ),
      const Directionality(
        textDirection: TextDirection.rtl,
        child: HeroTextField(
          defaultValue: 'heroui',
          children: <Widget>[
            HeroLabel.text('Website'),
            HeroInputGroup(
              startContent: Text('https://'),
              endContent: Text('.com'),
            ),
          ],
        ),
      ),
    ]),
  );
}
