import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  heroGoldenTest(
    'in a tag group, custom style, wrapping and RTL',
    name: 'error_message',
    size: const Size(360, 300),
    builder: (HeroThemeData theme) => const SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroTagGroup(
            label: 'Required Categories',
            description: 'Select at least one category',
            errorMessage: 'Please select at least one category',
            selectionMode: HeroSelectionMode.multiple,
            children: <Widget>[
              HeroTagGroupList(
                children: <Widget>[
                  HeroTag(id: 'news', label: 'News'),
                  HeroTag(id: 'travel', label: 'Travel'),
                  HeroTag(id: 'gaming', label: 'Gaming'),
                ],
              ),
            ],
          ),
          HeroErrorMessage.text(
            'Choose at least one topic',
            style: TextStyle(fontWeight: HeroTypography.medium),
          ),
          HeroErrorMessage.text(
            'Averyveryverylongwordthatdoesnotfitonasinglelineatallandwraps',
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 300,
              child: HeroErrorMessage.text('Right to left error'),
            ),
          ),
        ],
      ),
    ),
  );
}
