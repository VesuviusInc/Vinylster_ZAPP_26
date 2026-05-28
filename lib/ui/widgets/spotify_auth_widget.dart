import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/SpotifyService.dart';

class SpotifyAuthWidget extends StatelessWidget {
  const SpotifyAuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final spotifyService = context.watch<SpotifyService>();

    return Padding(
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          spotifyService.isConnected
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_done, color: Colors.green),
                    SizedBox(width: 5),
                    Text("Connected to Spotify!"),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, color: Colors.red),
                    SizedBox(width: 5),
                    Text("Not connected to Spotify!"),
                  ],
                ),

          const SizedBox(height: 20),

          if (!spotifyService.isConnected)
            ElevatedButton(
              onPressed: () async {
                final errorMessage = await context
                    .read<SpotifyService>()
                    .connectToSpotify();

                if (!context.mounted) return;

                if (errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $errorMessage"))
                  );
                }
              },
              child: const Text('Connect to Spotify'),
            )
          else
            ElevatedButton(
              onPressed: () => context.read<SpotifyService>().disconnect(),
              child: const Text('Disconnect Spotify'),
            ),
        ],
      ),
    );
  }
}
