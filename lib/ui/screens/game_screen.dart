import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/logic/game_session.dart';
import 'package:vinylster_zapp_26/ui/widgets/audio_player_control.dart';


class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameSession = context.watch<GameSession>();
    final currentPlayer = gameSession.currentPlayer;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Vinylster"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Text("Active player: ${currentPlayer.name}"),
              Text("Tokens: ${currentPlayer.amountToken}")
            ],
          ),
          AudioPlayerControl(),
        ],
      ),
    );
  }
}