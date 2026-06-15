import 'package:vinylster_zapp_26/data/models/playlist.dart';
import 'package:vinylster_zapp_26/data/models/track.dart';
import 'package:vinylster_zapp_26/data/repositories/track_repository.dart';
import 'package:vinylster_zapp_26/data/services/spotify_service.dart';

class CustomTrackRepository extends TrackRepository {
  final SpotifyService _spotifyService;
  final List<Track> _cachedTracks = [];
  Playlist? _currentPlaylist;

  CustomTrackRepository(this._spotifyService);

  set currentPlaylist(Playlist? value) {
    _currentPlaylist = value;
  }

  Playlist? get currentPlaylist => _currentPlaylist;

  @override
  Future<List<Track>> getRandomTracks(int amount) async {
    if (!_spotifyService.isConnected) {
      throw Exception("Spotify Service is not connected");
    }

    if(_currentPlaylist == null) {
        throw Exception("No playlist set");
    }

    if(_cachedTracks.length < amount) {
      int diff = amount - _cachedTracks.length;
      for (int i = 0; i < diff % SpotifyService.maxItemLimit; i++) {
        List<Track> newlyCachedTracks = await _spotifyService.getTracks(
          playListId: _currentPlaylist!.playlistId,
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
}