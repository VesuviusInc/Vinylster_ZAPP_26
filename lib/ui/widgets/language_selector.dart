import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/logic/settings_controller.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.center,
      children: List.generate(settingsController.availableLanguages.length, (index) {

        final isSelected = settingsController.selectedLanguageLocale == settingsController.availableLanguages[index];

        return GestureDetector(
          onTap: () {
              settingsController.setSelectedLanguage(settingsController.availableLanguages[index]);
          },
            child: Padding(padding: EdgeInsets.only(bottom: 10), child:
            Container(
              height: 30,
              padding: EdgeInsets.all(3),
              color: isSelected?Theme.of(context).primaryColor.withValues(alpha: .5):Theme.of(context).secondaryHeaderColor.withValues(alpha: .5),
              child: Text(settingsController.availableLanguages[index]=='en'?'English':'Deutsch'),
            ),
            ),
        );
      }),
    );
  }

}