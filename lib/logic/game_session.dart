import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../data/models/player.dart';
import '../data/models/playlist.dart';
import '../data/models/track.dart';
import '../data/repositories/custom_track_repository.dart';
import '../data/repositories/track_repository.dart';

class GameSession extends ChangeNotifier {
  TrackRepository? _activeTrackRepository;

  final List<Player> _players = [];
  int _activePlayerIndex = 0;
  int requiredCardsToWin = 10;
  static final int cardPrice = 3;

  Track? _currentTrack;
  List<Track> _unplayedTracks = [];
  List<Track> _playedTracks = [];
  List<Track> _skippedTracks = [];
  GuessStatus _guessStatus = GuessStatus.none;

  GameSession();

  TrackRepository? get activeTrackRepository => _activeTrackRepository;

  set activeTrackRepository(TrackRepository value) {
    _activeTrackRepository = value;
  }

  Track? get currentTrack => _currentTrack;

  List<Player> get players => _players;

  Player get currentPlayer => _players[_activePlayerIndex];

  List<Track> get playedTracks => _playedTracks;

  List<Track> get skippedTracks => _skippedTracks;

  set playedTracks(List<Track> value) {
    _playedTracks = value;
  }

  GuessStatus get guessStatus => _guessStatus;

  set guessStatus(GuessStatus value) {
    _guessStatus = value;
    notifyListeners();
  }

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
    if (_activeTrackRepository == null) {
      throw Exception("No TrackRepository set");
    }

    if (players.isEmpty) {
      throw Exception("No players added");
    }

    _unplayedTracks = await _activeTrackRepository!.getRandomTracks(
      _players.length * 10,
    );
    _activePlayerIndex = Random().nextInt(_players.length);
    _playedTracks = [];

    for (var player in players) {
      Track track = _unplayedTracks.last;
      player.addTrack(track);
      _playedTracks.add(track);
      _unplayedTracks.remove(track);
    }
    _currentTrack = _unplayedTracks[_unplayedTracks.length - 1];
    currentPlayer.tracks.insert(
      (currentPlayer.tracks.length / 2).floor(),
      currentTrack!,
    );

    notifyListeners();
  }

  Playlist? get playlist {
    final repo = _activeTrackRepository;

    if (repo is CustomTrackRepository) {
      return repo.currentPlaylist;
    }
    return null;
  }

  Future<void> next() async {
    if (_activeTrackRepository == null) {
      throw Exception("No TrackRepository set");
    }

    if (_currentTrack == null) {
      return;
    }

    // get more tracks when unplayed tracks are almost empty
    if (_unplayedTracks.length == 1) {
      _unplayedTracks.addAll(
        await _activeTrackRepository!.getRandomTracks(_players.length * 10),
      );
    }

    _playedTracks.add(_currentTrack!);
    _unplayedTracks.remove(_currentTrack);
    _currentTrack = _unplayedTracks[_unplayedTracks.length - 1];

    if (_players.isEmpty) {
      return;
    }

    // so playerIndex will automatically start over at 0
    _activePlayerIndex = ((_activePlayerIndex + 1) % (_players.length));
    guessStatus = GuessStatus.none;

    currentPlayer.tracks.insert(
      (currentPlayer.tracks.length / 2).floor(),
      currentTrack!,
    );
    notifyListeners();
  }

  Future<void> skipTrack() async {
    if (_activeTrackRepository == null) {
      throw Exception("No TrackRepository set");
    }

    if (_currentTrack == null) {
      return;
    }

    // get more tracks when unplayed tracks are almost empty
    if (_unplayedTracks.length == 1) {
      _unplayedTracks.addAll(
        await _activeTrackRepository!.getRandomTracks(_players.length * 10),
      );
    }

    guessStatus = GuessStatus.none;
    currentPlayer.tracks.remove(_currentTrack);

    _skippedTracks.add(_currentTrack!);
    _unplayedTracks.remove(_currentTrack);
    _currentTrack = _unplayedTracks[_unplayedTracks.length - 1];
    currentPlayer.tracks.insert(
      (currentPlayer.tracks.length / 2).floor(),
      currentTrack!,
    );
    notifyListeners();
  }

  bool takeGuess() {
    int index = currentPlayer.tracks.indexOf(currentTrack!);
    if (currentPlayer.tracks.length == 1) {
      return true;
    }
    bool isCorrect = false;

    if (index == 0) {
      isCorrect = currentTrack!.releaseYear <= currentPlayer.tracks[1].releaseYear;
    }
    else if (index == currentPlayer.tracks.length - 1) {
      isCorrect = currentTrack!.releaseYear >= currentPlayer.tracks[index - 1].releaseYear;
    }
    else {
      isCorrect = (currentTrack!.releaseYear >= currentPlayer.tracks[index - 1].releaseYear) &&
          (currentTrack!.releaseYear <= currentPlayer.tracks[index + 1].releaseYear);
    }

    if (isCorrect) {
      return true;
    }

    currentPlayer.tracks.remove(currentTrack!);
    return false;
  }

  void buyCard() {
    if (currentPlayer.amountToken < cardPrice) {
      throw Exception("Not enough tokens");
    }
    currentPlayer.removeTokens(3);
    Random r = Random();
    int randomIndex = r.nextInt(_unplayedTracks.length);
    currentPlayer.tracks.add(_unplayedTracks[randomIndex]);
    _playedTracks.add(_unplayedTracks[randomIndex]);
    _unplayedTracks.remove(_unplayedTracks[randomIndex]);
    notifyListeners();
  }

  void addTokenToCurrentPlayer() {
    currentPlayer.addToken();
    notifyListeners();
  }

  bool isGameOver() {
    for (var player in players) {
      if (player.tracks.length == requiredCardsToWin) {
        return true;
      }
    }
    return false;
  }

  void quit() {
    _activeTrackRepository = null;

    _players.clear();
    _activePlayerIndex = 0;
    requiredCardsToWin = 10;

    _currentTrack = null;
    _unplayedTracks.clear();
    _playedTracks.clear();
    _skippedTracks.clear();
    guessStatus = GuessStatus.none;

    notifyListeners();
  }
}

// artist and title guess
enum GuessStatus { none, correct, wrong }