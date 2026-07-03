import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/data/models/player.dart';
import 'package:vinylster_zapp_26/data/repositories/local_track_repository.dart';
import 'package:vinylster_zapp_26/logic/game_session.dart';
import 'package:vinylster_zapp_26/ui/widgets/spotify_playlist_selector.dart';
import 'package:vinylster_zapp_26/l10n/app_localizations.dart';

class LocalGame extends StatefulWidget {
  const LocalGame({super.key});

  @override
  State<LocalGame> createState() => _LocalGameState();
}

class _LocalGameState extends State<LocalGame> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Local Game'),
        leading: IconButton(
            onPressed: () {
              context.goNamed('Home');
            },
            icon: const Icon(Icons.keyboard_arrow_left)
        ),
      ),
      body: Center(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 70,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        controller: myController
                      ),
                    ),
                    Expanded(flex: 10, child: const Text(''),),
                    Expanded(
                      flex: 20,
                      child: Consumer<GameSession>(
                          builder: (context, provider, child) {
                            return OutlinedButton(
                              onPressed: context.read<GameSession>().getPlayers().length<8?() {
                                context.read<GameSession>().addPlayer(Player(myController.text));
                              }:null,
                              style: ButtonStyle(
                                foregroundColor: context.read<GameSession>().getPlayers().length<8?null:WidgetStateProperty.all<Color>(Colors.red),
                              ),
                              child: const Text("Add Players"),
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Consumer<GameSession>(
                  builder: (context, provider, child) {
                    return Title(
                      color: Colors.black,
                      child: Text(localizations?.players(context.read<GameSession>().getPlayers().length) ?? ''),
                    );
                  }
              ),
              Consumer<GameSession>(
                builder: (context, provider, child) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: context.read<GameSession>().getPlayers().length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(context.read<GameSession>().getPlayerByIndex(index).name),
                        );
                      }
                    ),
                  );
                }
              ),
              ElevatedButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    child: Padding(
                      padding: const .all(8.0),
                      child: Column(
                        mainAxisSize: .min,
                        mainAxisAlignment: .center,
                        children: <Widget>[
                          const SpotifyPlaylistSelector(),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: const Text('Select Playlist'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Start Game'),
                onPressed: () async {
                  FocusScope.of(context).unfocus();

                  final gameSession = context.read<GameSession>();
                  gameSession.activeTrackRepository ??= context.read<LocalTrackRepository>();
                  try {
                    await gameSession.start();
                    if(!context.mounted) return;

                    context.goNamed('GameScreen');
                  } catch (e) {
                    showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                      title: const Text("Hoppla!"),
                      content: Text("No players added! Please add players before starting the game!"),
                      actions: [
                        TextButton(onPressed: () => {
                          Navigator.pop(context, "Ok")
                        },
                        child: Text("Ok")
                        )
                      ],
                    ));
                  }
                },
              ),
            ],
          )
        ),
      );
  }
}
