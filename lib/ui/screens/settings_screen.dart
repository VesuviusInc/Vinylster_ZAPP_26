import 'package:flutter/material.dart';
import 'package:vinylster_zapp_26/ui/widgets/spotify_auth_widget.dart';
import 'package:vinylster_zapp_26/ui/widgets/vinyl_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Settings"),
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: Text("Spotify Settings"),
            children: [SpotifyAuthWidget()],
          ),
          ExpansionTile(
            title: Text("Vinyl Record Selection"),
            children: [VinylSelector()],
          ),
        ],
      ),
    );
  }
}
