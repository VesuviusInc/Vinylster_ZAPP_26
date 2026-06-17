import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinylster_zapp_26/data/repositories/custom_track_repository.dart';
import 'package:vinylster_zapp_26/data/services/spotify_service.dart';
import 'package:vinylster_zapp_26/logic/game_session.dart';
import '../../data/models/playlist.dart';

class SpotifyPlaylistSelector extends StatefulWidget {
  const SpotifyPlaylistSelector({super.key});

  @override
  State<StatefulWidget> createState() => _SpotifyPlaylistSelectorState();
}

class _SpotifyPlaylistSelectorState extends State<SpotifyPlaylistSelector> {
  final _formKey = GlobalKey<FormState>();
  final linkTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    linkTextController.dispose();
    super.dispose();
  }

  void setPlaylistLink(String link) {}

  @override
  Widget build(BuildContext context) {
    // TODO: Add Checkbox for custom playlist
    // checked => use custom playlist
    // not checked => no custom playlist
    final width = MediaQuery.of(context).size.width;
    final gameSession = context.watch<GameSession>();
    final playlist = context.watch<GameSession>().playlist;

    return Padding(
      padding: EdgeInsets.all(width * 0.15),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: linkTextController,
                  decoration: const InputDecoration(
                    labelText: "Spotify Playlist Link",
                    hintText: "https://open.spotify.com/playlist/...",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a link";
                    }

                    if (!value.contains("spotify.com/playlist/")) {
                      return "Please enter valid spotify-playlist link";
                    }

                    if(Uri.parse(value).pathSegments.last.length != 22) {
                      return "Please enter a spotify playlist link with a valid id";
                    }

                    return null;
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      if (_formKey.currentState!.validate()) {
                        final spotifyService = context.read<SpotifyService>();
                        final gameSession = context.read<GameSession>();
                        gameSession.activeTrackRepository = CustomTrackRepository(spotifyService);

                        String customPlaylistId = spotifyService.getPlaylistIdByUrl(linkTextController.text);
                        final customRepo = context.read<CustomTrackRepository>();
                        Playlist? playlist = await customRepo.setCustomPlaylist(
                          customPlaylistId
                        );

                        if(!context.mounted) return;

                        String snackBarText = "";
                        if(playlist == null){
                          snackBarText = "No playlist with provided spotify playlist link. Please check again!";
                        } else {
                          snackBarText ="Successfully saved spotify playlist!";
                          gameSession.activeTrackRepository = customRepo;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                            Text(
                              snackBarText
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
          ),
          if (playlist != null) ...[
            Image.network(playlist.imageUrl, width: 100, height: 100),
            Text(playlist.name),
            Text("${playlist.trackCount} Songs"),
          ],
        ],
      ),
    );
  }
}
