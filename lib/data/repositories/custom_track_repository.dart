import 'package:vinylster/data/repositories/track_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../models/playlist.dart';
import '../models/track.dart';
import '../services/spotify_service.dart';

class CustomTrackRepository extends ChangeNotifier implements TrackRepository {
  final SpotifyService _spotifyService;
  List<Track> _cachedTracks = [];
  Playlist? currentPlaylist;

  CustomTrackRepository(this._spotifyService);

  @override
  Future<List<Track>> getRandomTracks(int amount) async {
    if (!_spotifyService.isConnected) {
      throw Exception("Spotify Service is not connected");
    }

    if(currentPlaylist == null) {
        throw Exception("No playlist set");
    }

    if(_cachedTracks.length < amount) {
      int diff = amount - _cachedTracks.length;
      for (int i = 0; i < (diff / SpotifyService.maxItemLimit).ceil(); i++) {
        List<Track> newlyCachedTracks = await _spotifyService.getTracks(
          playListId: currentPlaylist!.playlistId,
          offset: _cachedTracks.length
        );
        _cachedTracks.addAll(newlyCachedTracks);
      }
    }

    _cachedTracks.shuffle();
    return _cachedTracks.take(amount).toList();
  }

  @override
  Future<Track?> getTrackById(String id) async {
    return _cachedTracks.where((track) => track.trackId == id).firstOrNull;
  }

  // should be called, when choosing custom playlist
  Future<Playlist?> setCustomPlaylist(String customPlaylistId) async {

      final prefs = await SharedPreferences.getInstance();

      if (customPlaylistId.isEmpty) {
        prefs.remove("custom_playlist_id");
        currentPlaylist = null;
        notifyListeners();
        return null;
      }
      Playlist? fetchedPlaylist;
      try {
      fetchedPlaylist = await _spotifyService.getPlaylistInfo(customPlaylistId);
    } catch (e) {
      currentPlaylist = null;
      rethrow;
    }
      if(fetchedPlaylist.trackCount < 10) {
        throw Exception("Too few songs to use this playlist. Please choose another one!");
      }

    prefs.setString("custom_playlist_id", customPlaylistId);
    currentPlaylist = fetchedPlaylist;

    notifyListeners();

    return currentPlaylist;
  }

  void reset() {
    _cachedTracks = [];
    currentPlaylist = null;
    notifyListeners();
  }
}