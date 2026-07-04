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
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer<GameSession>(
              builder: (context, provider, child) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 100),
                  child: ReorderableListView.builder(
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
                        width: 100,
                        child: Card(
                          color: context.read<GameSession>().currentPlayer.tracks[index] == context.read<GameSession>().currentTrack?Theme.of(context).colorScheme.primaryContainer:Theme.of(context).colorScheme.tertiaryContainer,
                          child:
                          Padding(
                            padding: EdgeInsets.all(3),
                            child: Column(
                              children: [
                                if (context.read<GameSession>().currentPlayer.tracks[index] != context.read<GameSession>().currentTrack) ...[
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 20,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        context.read<GameSession>().currentPlayer.tracks[index].name.length>35?'${context.read<GameSession>().currentPlayer.tracks[index].name.substring(0,context.read<GameSession>().currentPlayer.tracks[index].name.length ~/ 2)}\n${context.read<GameSession>().currentPlayer.tracks[index].name.substring(context.read<GameSession>().currentPlayer.tracks[index].name.length ~/ 2)}':context.read<GameSession>().currentPlayer.tracks[index].name,
                                        textAlign: TextAlign.justify,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(style: TextStyle(color: Colors.white,fontSize: 30,fontWeight: FontWeight.bold), '${context.read<GameSession>().currentPlayer.tracks[index].releaseYear}'),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 20,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                          context.read<GameSession>().currentPlayer.tracks[index].artists.join(' ').length>35?'${context.read<GameSession>().currentPlayer.tracks[index].artists.join(' ').substring(0,context.read<GameSession>().currentPlayer.tracks[index].artists.join(' ').length ~/ 2)}\n${context.read<GameSession>().currentPlayer.tracks[index].artists.join(' ').substring(context.read<GameSession>().currentPlayer.tracks[index].artists.join(' ').length ~/ 2)}':context.read<GameSession>().currentPlayer.tracks[index].artists.join(' '),
                                        textAlign: TextAlign.justify,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                                else ...[
                                  SizedBox(height: 10,),
                                  Text(style: TextStyle(color: Colors.white,fontSize: 50,fontWeight: FontWeight.bold), '?'),
                                ]
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
        ],
      ),
    );
  }
}
