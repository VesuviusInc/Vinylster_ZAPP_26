import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/logic/game_session.dart';

class GameOver extends StatelessWidget {
  const GameOver({super.key});

  @override
  Widget build(BuildContext context) {
    final gameSession = context.watch<GameSession>();
    final sortedPlayers = gameSession.getPlayers().toList()
      ..sort((a, b) => b.tracks.length.compareTo(a.tracks.length));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Game Over"),
        leading: IconButton(
          onPressed: () {
            gameSession.quit();
            context.goNamed("Home");
          },
          icon: const Icon(Icons.home),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Leaderboard",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedPlayers.length,
                  itemBuilder: (context, index) {
                    final player = sortedPlayers[index];
                    final isWinner = index == 0;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isWinner
                            ? Colors.amber
                            : Theme.of(context).colorScheme.secondaryContainer,
                        child: isWinner
                            ? const Icon(
                                Icons.emoji_events,
                                color: Colors.white,
                              )
                            : Text('${index + 1}'),
                      ),
                      title: Text(
                        player.name,
                        style: TextStyle(
                          fontWeight: isWinner
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: Text(
                        "${player.tracks.length} Cards",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Game Stats",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    ExpansionTile(
                      leading: const Icon(
                        Icons.library_music,
                        color: Colors.green,
                      ),
                      title: Text(
                        "Played Songs (${gameSession.playedTracks.length})",
                      ),
                      children: gameSession.playedTracks.map((track) {
                        return ListTile(
                          dense: true,
                          title: Text(track.name),
                          subtitle: Text(track.getArtistsWithFormat()),
                        );
                      }).toList(),
                    ),
                    const Divider(height: 1),
                    ExpansionTile(
                      leading: const Icon(
                        Icons.skip_next,
                        color: Colors.orange,
                      ),
                      title: Text(
                        "Skipped Songs (${gameSession.skippedTracks.length})",
                      ),
                      children: gameSession.skippedTracks.map((track) {
                        return ListTile(
                          dense: true,
                          title: Text(track.name),
                          subtitle: Text(track.getArtistsWithFormat()),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
