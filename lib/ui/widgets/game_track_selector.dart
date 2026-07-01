import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/logic/game_session.dart';

import '../../data/services/spotify_service.dart';

class GameTrackSelector extends StatefulWidget {
  const GameTrackSelector({super.key});

  @override
  State<GameTrackSelector> createState() => _GameTrackSelector();
}

class _GameTrackSelector extends State<GameTrackSelector> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 150,
            child: Consumer<GameSession>(
              builder: (context, provider, child) {
                return Expanded(child:
                ReorderableListView.builder(
                  padding: EdgeInsets.only(left: 20),
                  scrollDirection: Axis.horizontal,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  buildDefaultDragHandles: false,
                  itemCount: context.read<GameSession>().currentPlayer.tracks.length,
                  itemBuilder: (context, index) {
                    return ReorderableDragStartListener(
                      key: ValueKey(context.read<GameSession>().currentPlayer.tracks[index].name),
                      index: index,
                      child:
                      SizedBox(
                        width: 150,
                        child: Card(
                          color: context.read<GameSession>().currentPlayer.tracks[index] == context.read<GameSession>().currentTrack?Colors.green:Colors.red,
                          child:
                          Padding(
                            padding: EdgeInsets.all(3),
                            child: Column(
                              children: [
                                Text(style: TextStyle(fontSize: 20),context.read<GameSession>().currentPlayer.tracks[index].name),
                                Text(style: TextStyle(color: Colors.white,fontSize: 40), '${context.read<GameSession>().currentPlayer.tracks[index].releaseYear}'),
                                Text(style: TextStyle(fontSize: 20), context.read<GameSession>().currentPlayer.tracks[index].artists.join(' ')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    if(context.read<GameSession>().currentPlayer.tracks[oldIndex] !=context.read<GameSession>().currentTrack) return;
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = context.read<GameSession>().currentPlayer.tracks.removeAt(oldIndex);
                      context.read<GameSession>().currentPlayer.tracks.insert(newIndex, item);
                    });
                  },
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
