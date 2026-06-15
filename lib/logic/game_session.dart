import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinylster_zapp_26/data/models/player.dart';
import 'package:vinylster_zapp_26/data/models/playlist.dart';
import 'package:vinylster_zapp_26/data/models/track.dart';
import 'package:vinylster_zapp_26/data/models/track_repository_mode.dart';
import 'package:vinylster_zapp_26/data/repositories/custom_track_repository.dart';
import 'package:vinylster_zapp_26/data/repositories/local_track_repository.dart';
import 'package:vinylster_zapp_26/data/repositories/track_repository.dart';
import 'package:vinylster_zapp_26/data/services/spotify_service.dart';

class GameSession extends ChangeNotifier {
  final LocalTrackRepository _localTrackRepository;
  final CustomTrackRepository _customTrackRepository;
  TrackRepositoryMode repoMode = TrackRepositoryMode.local;
  final SpotifyService _spotifyService;
  String? _playListId;
  Track? _currentTrack;

  final List<Player> _players = [];
  int _activePlayerIndex = 0;

  List<Track> _unplayedTracks = [];
  List<Track> _playedTracks = [];

  GameSession({
    required LocalTrackRepository localTrackRepository,
    required CustomTrackRepository customTrackRepository,
    required SpotifyService spotifyService,
  }) : _spotifyService = spotifyService,
       _localTrackRepository = localTrackRepository,
       _customTrackRepository = customTrackRepository;

  TrackRepository get _activeRepository => repoMode == TrackRepositoryMode.local ? _localTrackRepository : _customTrackRepository;


  Track? get currentTrack => _currentTrack;

  /// Adds the given [player] to the GameSession players
  ///
  /// Returns false if user with name already exists, otherwise 0
  bool addPlayer(Player player) {
    for (var p in _players) {
      if (p.name == player.name) {
        notifyListeners();
        return false;
      }
    }
    _players.add(player);
    notifyListeners();
    return true;
  }

  /// Removes the player with the given [playerName] from the GameSession players
  ///
  /// Returns on success true, otherwise false
  bool removePlayer(String playerName) {
    for (var p in _players) {
      if (p.name == playerName) {
        _players.remove(p);
        notifyListeners();
        return true;
      }
    }
    notifyListeners();
    return false;
  }

  // should be called, when choosing custom playlist
  Future<Playlist?> setCustomPlayList(String customPlayListId) async {
    final prefs = await SharedPreferences.getInstance();

    if(customPlayListId.isEmpty) {
      prefs.remove("custom_playlist_id");
      return null;
    }

    prefs.setString("custom_playlist_id", customPlayListId);

    // TODO: check if playlist has enough tracks!!
    _customTrackRepository.currentPlaylist = await _spotifyService.getPlaylistInfo(customPlayListId);

    _playListId = customPlayListId;
    repoMode = TrackRepositoryMode.custom;
    notifyListeners();
    return _customTrackRepository.currentPlaylist;
  }

  Future<void> start() async {
    _players.add(Player("Herbert"));
    _unplayedTracks = await _activeRepository.getRandomTracks(
      _players.length * 10,
    );
    _activePlayerIndex = Random().nextInt(_players.length) -1;
    _playedTracks = [];
    _currentTrack = _unplayedTracks[_unplayedTracks.length - 1];
    notifyListeners();
  }

  Playlist? get playlist  {
    if(repoMode == TrackRepositoryMode.custom) {
      return _customTrackRepository.currentPlaylist;
    }
    return null;
  }

  Future<void> next() async {
    if (_currentTrack != null) {
      _playedTracks.add(_currentTrack!);
      _unplayedTracks.remove(_currentTrack);
      _currentTrack = _unplayedTracks[_unplayedTracks.length - 1];
    }

    if(_players.isEmpty) {
      return;
    }

    if(_unplayedTracks.isEmpty) {
      _unplayedTracks = await _activeRepository.getRandomTracks(_players.length * 10);
    }
    // so playerIndex will automatically start over at 0
    _activePlayerIndex = ((_activePlayerIndex+1) % (_players.length));
    notifyListeners();
  }

  void takeGuess() {}
}
