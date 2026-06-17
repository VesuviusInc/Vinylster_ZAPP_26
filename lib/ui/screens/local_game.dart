import 'package:flutter/material.dart';
import './game_screen.dart';

class localGame extends StatefulWidget {
  const localGame({super.key});

  @override
  State<localGame> createState() => _localGameState();
}

class _localGameState extends State<localGame> {
  final myController = TextEditingController();
  List<String> players = ["Test"];
  bool addPlayerEnabled = true;

  void addPlayer(String name) {
    setState(() {
      if(players.length < 8) {
        players.add(name);
      }
      if(players.length == 8){
        addPlayerEnabled = false;
      }
    });
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lokales Spiel')),
      body: Column(
          children: [
            TextField(controller: myController),
            OutlinedButton(
              onPressed: addPlayerEnabled?() {
                addPlayer(myController.text);
              }:null,
              child: const Text("Spieler Hinzufügen"),
              style: ButtonStyle(
                foregroundColor: addPlayerEnabled?null:MaterialStateProperty.all<Color>(Colors.red),
              ),
            ),
            Title(
              child: Text('Spieler (${players.length}/8)'),
              color: Colors.black,
            ),
            Expanded(child: ListView.builder(
              itemCount: players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(players[index]),
                  );
                }
              ),
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.start),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const gameScreen(),
            ),
          );
        },
      ),
    );
  }
}