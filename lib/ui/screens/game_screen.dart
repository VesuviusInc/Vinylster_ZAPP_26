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
                      currentPlayer.name,
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
              Column(
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
                          )
                        );
                      }
                    },
                  ),
                ],
              ),
              Column(
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
                    margin: EdgeInsets.only(
                      top: 8,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    text: "Appeal",
                    icon: Icons.block_sharp,
                    buttonColor: Theme.of(context).colorScheme.primaryContainer,
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              Column(
                children: [
                  CustomGameButton(
                    margin: EdgeInsets.all(16),
                    text: "Skip song",
                    icon: Icons.next_plan_outlined,
                    buttonColor: Theme.of(context).colorScheme.primaryContainer,
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () {
                      gameSession.currentPlayer.addToken();
                      gameSession.currentPlayer.addToken();
                      gameSession.currentPlayer.addToken();
                      gameSession.currentPlayer.addToken();
                      gameSession.currentPlayer.addToken();
                      gameSession.currentPlayer.addToken();
                      // no listener will be notified
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomGameButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final EdgeInsets margin;
  final TextStyle? textStyle;
  final Color? buttonColor;

  const CustomGameButton({
    super.key,
    required this.margin,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.textStyle,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: buttonColor ?? Colors.grey.shade400.withAlpha(150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textStyle?.color ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(text, style: textStyle),
          ],
        ),
      ),
    );
  }
}
