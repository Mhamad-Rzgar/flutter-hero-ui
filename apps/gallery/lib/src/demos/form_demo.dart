import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroForm`, reproducing heroui.com/docs/components/form.
final ComponentDemo formDemo = ComponentDemo(
  slug: 'form',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('validationBehavior', <String>['native', 'aria']),
    ],
    builder: (BuildContext context, PlaygroundValues values) => _PlaygroundForm(
      behavior: values.pick(
        'validationBehavior',
        HeroValidationBehavior.values,
      ),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroForm(
  validationBehavior: HeroValidationBehavior.${values.option('validationBehavior')},
  onSubmit: (Map<String, Object?> data) => debugPrint('\$data'),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: <Widget>[
      const HeroInput(
        name: 'email',
        semanticLabel: 'Email',
        type: HeroInputType.email,
        isRequired: true,
        placeholder: 'john@example.com',
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: <Widget>[
          HeroButton(
            type: HeroButtonType.submit,
            child: const Text('Submit'),
          ),
          const HeroButton(
            type: HeroButtonType.reset,
            variant: HeroButtonVariant.secondary,
            child: Text('Reset'),
          ),
        ],
      ),
    ],
  ),
)''',
  ),
  examples: const <DemoExample>[],
);

/// A form that shows the data it submits.
class _PlaygroundForm extends StatefulWidget {
  const _PlaygroundForm({required this.behavior});

  final HeroValidationBehavior behavior;

  @override
  State<_PlaygroundForm> createState() => _PlaygroundFormState();
}

class _PlaygroundFormState extends State<_PlaygroundForm> {
  String? _result;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return SizedBox(
      width: 288,
      child: HeroForm(
        validationBehavior: widget.behavior,
        onSubmit: (Map<String, Object?> data) =>
            setState(() => _result = 'Submitted: $data'),
        onReset: () => setState(() => _result = null),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            const HeroInput(
              name: 'email',
              semanticLabel: 'Email',
              type: HeroInputType.email,
              isRequired: true,
              fullWidth: true,
              placeholder: 'john@example.com',
            ),
            const Row(
              mainAxisSize: MainAxisSize.min,
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
            if (_result case final String result)
              Text(
                result,
                style: theme.typography.sm.copyWith(color: theme.colors.muted),
              ),
          ],
        ),
      ),
    );
  }
}
