import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/data/models/player.dart';
import 'package:vinylster_zapp_26/data/repositories/local_track_repository.dart';
import 'package:vinylster_zapp_26/logic/game_session.dart';

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
              Padding(
                padding: EdgeInsets.all(25),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  controller: myController
                ),
              ),
              Consumer<GameSession>(
                  builder: (context, provider, child) {
                    return OutlinedButton(
                      onPressed: context.read<GameSession>().getPlayers().length<8?() {
                        context.read<GameSession>().addPlayer(new Player(myController.text));
                      }:null,
                      child: const Text("Add Players"),
                      style: ButtonStyle(
                        foregroundColor: context.read<GameSession>().getPlayers().length<8?null:MaterialStateProperty.all<Color>(Colors.red),
                      ),
                    );
                  }
              ),
              const SizedBox(height: 20),
              Consumer<GameSession>(
                  builder: (context, provider, child) {
                    return Title(
                      child: Text('Players (${context.read<GameSession>().getPlayers().length}/8)'),
                      color: Colors.black,
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
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Start Game'),
                onPressed: () {
                  final gameSession = context.read<GameSession>();
                  gameSession.activeTrackRepository ??= context.read<LocalTrackRepository>();
                  gameSession.start();
                  context.goNamed('GameScreen');
                },
              ),
              const SizedBox(height: 50),
            ],
          )
        ),
      );
  }
}
