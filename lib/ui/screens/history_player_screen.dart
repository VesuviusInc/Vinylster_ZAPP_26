import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vinylster/l10n/app_localizations.dart';
import 'package:vinylster/logic/history_database_helper.dart';
import 'package:vinylster/data/models/game_history_player.dart';

class HistoryPlayerScreen extends StatelessWidget {
  const HistoryPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    HistoryDatabaseHelper his = new HistoryDatabaseHelper();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Game ${GoRouterState.of(context).extra!.toString().split(' ')[1]}'),
        leading: IconButton(
            onPressed: () {
              context.goNamed('HistoryScreen');
            },
            icon: const Icon(Icons.keyboard_arrow_left)
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            children: [
              FutureBuilder<List<GameHistoryPlayer>>(
                future: his.getPlayersByGame(GoRouterState.of(context).extra!.toString().split(' ')[0]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Player ${snapshot.data![index].name}', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        }
                      ),
                    );
                  }
                },
              )
            ]
        ),
      ),
    );
  }
}
