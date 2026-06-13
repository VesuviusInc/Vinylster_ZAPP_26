import 'package:flutter/material.dart';
import './game_screen.dart';


class localGame extends StatelessWidget {
  const localGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Lokales Spiel erstellen')
      ),
      body: Center(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term',
                ),
              ),
              FloatingActionButton(
                onPressed: null,
                tooltip: 'Spieler hinzufügen',
                child: const Icon(Icons.add),
              ),
              ElevatedButton(
                child: const Text('Spiel starten'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const gameScreen(),
                    ),
                  );
                },
              ),
            ],
          )
        ),
      );
  }
}