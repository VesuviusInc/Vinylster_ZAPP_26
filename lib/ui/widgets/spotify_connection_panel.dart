import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/spotify_service.dart';
import '../../logic/settings_controller.dart';

class SpotifyConnectionPanel extends StatelessWidget {
  const SpotifyConnectionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final spotifyService = context.watch<SpotifyService>();
    SettingsController settings = context.watch<SettingsController>();

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                spotifyService.isConnected ? Icons.cloud_done : Icons.cloud_off,
                color: spotifyService.isConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                spotifyService.isConnected ? "Connected to Spotify!" : "Not connected to Spotify!",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: spotifyService.isConnected ? Colors.red.shade100 : const Color(0xFF1DB954),
              foregroundColor: spotifyService.isConnected ? Colors.red.shade900 : Colors.white,
            ),
            onPressed: () async {
              final spotifyService = context.read<SpotifyService>();
              String? errorMessage;
              if(spotifyService.isConnected) {
                errorMessage = await context.read<SpotifyService>().disconnect();
              } else {
                errorMessage =  await context.read<SpotifyService>().connectToSpotify();
              }

              if (!context.mounted) return;

              if (errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $errorMessage")),
                );
              }
            },
            child: Text(spotifyService.isConnected ? 'Disconnect Spotify' : 'Connect to Spotify'),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Auto connect",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: settings.autoConnect,
                  onChanged: settings.toggleAutoConnect,
                  activeThumbColor: const Color(0xFF1DB954),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
