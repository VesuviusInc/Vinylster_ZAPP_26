import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/models/player.dart';
import '../../data/repositories/local_track_repository.dart';
import '../../data/services/spotify_service.dart';
import '../../l10n/app_localizations.dart';
import '../../logic/game_session.dart';
import '../widgets/spotify_playlist_selector.dart';

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
        title: Text(localizations?.createGame ?? ''),
        leading: IconButton(
            onPressed: () {
              context.read<GameSession>().quit();
              context.goNamed('Home');
            },
            icon: const Icon(Icons.keyboard_arrow_left)
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 25),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                child:SizedBox(
                  width: 500,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    controller: myController
                  ),
                ),
              ),
              Consumer<GameSession>(
                builder: (context, provider, child) {
                  return OutlinedButton(
                    onPressed: context.read<GameSession>().getPlayers().length<8?() {
                      context.read<GameSession>().addPlayer(Player(myController.text));
                    }:null,
                    style: ButtonStyle(
                      foregroundColor: context.read<GameSession>().getPlayers().length<8?null:WidgetStateProperty.all<Color>(Colors.red),
                    ),
                    child: Text(localizations?.addPlayers ?? ''),
                  );
                }
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
                            child: Text(localizations?.close ?? ''),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: Text(localizations?.selectPlaylist ?? ''),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text(localizations?.startGame ?? ''),
                onPressed: () async {
                  FocusScope.of(context).unfocus();

                  final gameSession = context.read<GameSession>();
                  gameSession.activeTrackRepository ??= context.read<LocalTrackRepository>();
                  if(!context.read<SpotifyService>().isConnected) {
                    showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                      title: const Text("Hoppla!"),
                      content: Text("Not connected to spotify. Please connect to spotify in the settings!"),
                      actions: [
                        TextButton(onPressed: () => {
                          Navigator.pop(context, "Ok")
                        },
                            child: Text("Ok")
                        )
                      ],
                    ));
                    return;
                  }

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
      ),
    );
  }
}
