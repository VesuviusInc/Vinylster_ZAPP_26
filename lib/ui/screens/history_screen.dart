import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vinylster/l10n/app_localizations.dart';
import 'package:vinylster/logic/history_database_helper.dart';
import 'package:vinylster/data/models/game_history.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    HistoryDatabaseHelper his = HistoryDatabaseHelper();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('History'),
        leading: IconButton(
            onPressed: () {
              context.goNamed('Home');
            },
            icon: const Icon(Icons.keyboard_arrow_left)
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            FutureBuilder<List<GameHistory>>(
              future: his.getGames(),
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
                        return GestureDetector(
                          child: Card(
                           child: Padding(
                             padding: EdgeInsets.all(8),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('Game ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                                 SizedBox(height: 5),
                                 Row(
                                   children: [
                                     Text('${snapshot.data![index].time.split(' ')[0]} ${snapshot.data![index].time.split(' ')[1].split('.')[0]}'),
                                     SizedBox(width: 10),
                                     Text('Players: ${snapshot.data![index].playerAmount.toString()}')
                                   ],
                                 )
                               ],
                             ),
                           ),
                          ),
                          onTap: () {
                            context.goNamed('HistoryPlayerScreen', extra: '${snapshot.data![index].gameID} ${index+1}');
                          },
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
