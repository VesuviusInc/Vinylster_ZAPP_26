import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:vinylster_zapp_26/data/models/player.dart';
import 'package:vinylster_zapp_26/data/models/playlist.dart';
import 'package:vinylster_zapp_26/data/models/track.dart';
import 'package:vinylster_zapp_26/data/repositories/custom_track_repository.dart';
import 'package:vinylster_zapp_26/data/repositories/track_repository.dart';

class GameSession extends ChangeNotifier {
  TrackRepository? _activeTrackRepository;

  final List<Player> _players = [];
  int _activePlayerIndex = 0;
  int requiredCardsToWin = 10;

  Track? _currentTrack;
  List<Track> _unplayedTracks = [];
  List<Track> _playedTracks = [];

  GameSession();

  TrackRepository? get activeTrackRepository => _activeTrackRepository;

  set activeTrackRepository(TrackRepository value) {
    _activeTrackRepository = value;
  }

  Track? get currentTrack => _currentTrack;

  List<Player> get players => _players;

  Player get currentPlayer => _players[_activePlayerIndex];

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

  void clearPlayers() {
    _players.clear();
    notifyListeners();
  }

  List<Player> getPlayers() {
    return _players;
  }

  Player getPlayerByIndex(int index) {
    return _players[index];
  }

  Future<void> start() async {
    if(_activeTrackRepository == null) {
      throw Exception("No TrackRepository set");
    }

    if(players.isEmpty) {
      throw Exception("No players added");
    }

    _unplayedTracks = await _activeTrackRepository!.getRandomTracks(
      _players.length * 10,
    );
    _activePlayerIndex = Random().nextInt(_players.length);
    _playedTracks = [];
    _currentTrack = _unplayedTracks[_unplayedTracks.length - 1];
    notifyListeners();
  }

  Playlist? get playlist {
    final repo = _activeTrackRepository;

    if(repo is CustomTrackRepository) {
      return repo.currentPlaylist;
    }
    return null;
  }

  Future<void> next() async {
    if(_activeTrackRepository == null) {
      throw Exception("No TrackRepository set");
    }

    if (_currentTrack == null) {
      return;
    }

    if (_unplayedTracks.length == 1) {
      _unplayedTracks.addAll(await _activeTrackRepository!.getRandomTracks(
        _players.length * 10,
      ));
    }

    _playedTracks.add(_currentTrack!);
    _unplayedTracks.remove(_currentTrack);
    _currentTrack = _unplayedTracks[_unplayedTracks.length - 1];

    if (_players.isEmpty) {
      return;
    }

    // so playerIndex will automatically start over at 0
    _activePlayerIndex = ((_activePlayerIndex + 1) % (_players.length));
    notifyListeners();
  }

  void takeGuess() {}
}
