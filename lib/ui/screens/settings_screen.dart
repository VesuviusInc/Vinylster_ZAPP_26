import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/language_selector.dart';
import '../widgets/spotify_connection_panel.dart';
import '../widgets/vinyl_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(localizations?.settings??''),
        leading: IconButton(
            onPressed: () {
              context.goNamed('Home');
            },
            icon: const Icon(Icons.keyboard_arrow_left)
        ),
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: Text("Spotify ${localizations?.settings??''}"),
            children: [SpotifyConnectionPanel()],
          ),
          ExpansionTile(
            title: Text(localizations?.vinylRecordSelection??''),
            children: [VinylSelector()],
          ),
          ExpansionTile(
            title: Text("Language Selection"),
            children: [LanguageSelector()],
          ),
        ],
      ),
    );
  }
}
