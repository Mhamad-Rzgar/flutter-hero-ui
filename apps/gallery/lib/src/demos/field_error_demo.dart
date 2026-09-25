import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroFieldError`, reproducing
/// heroui.com/docs/components/field-error.
final ComponentDemo fieldErrorDemo = ComponentDemo(
  slug: 'field-error',
  playground: Playground(
    controls: const <PlaygroundControl>[
      ToggleControl('isInvalid', initial: true),
      TextControl('text', initial: 'Username must be at least 3 characters'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => SizedBox(
      width: 256,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: <Widget>[
          HeroLabel.text('Username', isInvalid: values.toggle('isInvalid')),
          HeroInput(
            fullWidth: true,
            defaultValue: 'jr',
            semanticLabel: 'Username',
            isInvalid: values.toggle('isInvalid'),
          ),
          HeroFieldError.text(
            values.text('text'),
            isInvalid: values.toggle('isInvalid'),
          ),
        ],
      ),
    ),
    code: (PlaygroundValues values) =>
        "HeroFieldError.text(\n  '${values.text('text')}',\n"
        '  isInvalid: ${values.toggle('isInvalid')},\n)',
  ),
  examples: const <DemoExample>[],
);
