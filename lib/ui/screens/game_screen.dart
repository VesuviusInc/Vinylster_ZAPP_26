import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/logic/game_session.dart';
import 'package:vinylster_zapp_26/ui/screens/choose_artist_and_title.dart';
import 'package:vinylster_zapp_26/ui/widgets/audio_player_control.dart';

import '../widgets/custom_game_button.dart';

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
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text("Quit game?"),
                content: Text("Do you really want to quit the game?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, "Yes");
                      gameSession.quit();
                      context.goNamed("Home");
                    },
                    child: Text("Yes"),
                  ),
                  TextButton(
                    onPressed: () => {Navigator.pop(context, "No")},
                    child: Text("No"),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.keyboard_arrow_left),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text("Player: "),
                    Text(
                      currentPlayer.name.length > 20
                          ? "${currentPlayer.name.substring(0, 20)}..."
                          : currentPlayer.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text("Tokens: "),
                    Text(
                      "${currentPlayer.amountToken}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AudioPlayerControl(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomGameButton(
                margin: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                text: "Buy card",
                icon: Icons.monetization_on_outlined,
                buttonColor: Theme.of(context).colorScheme.primaryContainer,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onPressed: () {
                  try {
                    gameSession.buyCard();
                  } catch (e) {
                    String snackBarText = e.toString().replaceAll(
                      "Exception: ",
                      "",
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(snackBarText),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              CustomGameButton(
                margin: EdgeInsets.all(16),
                text: "Appeal",
                icon: Icons.block_sharp,
                buttonColor: Theme.of(context).colorScheme.primaryContainer,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onPressed: () {},
              ),
              CustomGameButton(
                margin: EdgeInsets.all(16),
                text: "Skip song",
                icon: Icons.next_plan_outlined,
                buttonColor: Theme.of(context).colorScheme.primaryContainer,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                onPressed: () async {
                  try {
                    await gameSession.skipTrack();
                  } catch (e) {
                    String snackBarText = e.toString().replaceAll(
                      "Exception: ",
                      "",
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(snackBarText),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomGameButton(
                margin: EdgeInsets.all(16),
                text: "Take guess",
                icon: Icons.pan_tool,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                buttonColor: Theme.of(context).colorScheme.primary,
                onPressed: () {},
              ),
              CustomGameButton(
                margin: EdgeInsets.all(16),
                text: "Artist & Title",
                icon: Icons.draw,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                buttonColor:
                    getColorForGuessStatus(gameSession.guessStatus) ??
                    Theme.of(context).colorScheme.primary,
                onPressed: () {
                  if(gameSession.guessStatus == GuessStatus.none) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: false,
                      enableDrag: false,
                      builder: (context) {
                        return FractionallySizedBox(
                          heightFactor: 0.75,
                          child: const ChooseArtistAndTitle(),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text("Cards (${gameSession.currentPlayer.tracks.length})"),
          ),
        ],
      ),
    );
  }

  Color? getColorForGuessStatus(GuessStatus guessStatus) {
    switch (guessStatus) {
      case GuessStatus.none:
        return null;
      case GuessStatus.correct:
        return Colors.green.shade300;
      case GuessStatus.wrong:
        return Colors.red.shade300;
    }
  }
}
