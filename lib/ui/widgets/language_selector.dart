import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/settings_controller.dart';

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
            child: Padding(padding: EdgeInsets.all(10), child:
            Container(
              height: 30,
              padding: EdgeInsets.fromLTRB(6,4,6,6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: isSelected?Theme.of(context).primaryColor.withValues(alpha: .5):Theme.of(context).secondaryHeaderColor.withValues(alpha: .5),
              ),
              child: Text(settingsController.availableLanguages[index]=='en'?'English':'Deutsch'),
            ),
            ),
        );
      }),
    );
  }

}