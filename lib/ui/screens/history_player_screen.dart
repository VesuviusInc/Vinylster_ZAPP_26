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
    HistoryDatabaseHelper his = HistoryDatabaseHelper();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(localizations?.game(GoRouterState.of(context).extra!.toString().split(' ')[1]) ?? ''),
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
                                  Text(localizations?.playerHistory(snapshot.data![index].name) ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text('Tokens: ${snapshot.data![index].tokenAmount.toString()}'),
                                      SizedBox(width: 10),
                                      Text(localizations?.track(snapshot.data![index].trackAmount.toString()) ?? '' )
                                    ],
                                  )
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
