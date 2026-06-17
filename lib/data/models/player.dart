import 'track.dart';

class Player {
  // name is unique for every round
  String _name;
  List<Track> _tracks;
  int _amountToken;

  Player(this._name):
      _tracks = [],
      _amountToken = 0;

  int get amountToken => _amountToken;

  void addToken() {
    _amountToken++;
  }

  void removeToken() {
    _amountToken--;
  }

  List<Track> get tracks => _tracks;

  void addTrack(Track t) {
    _tracks.add(t);
  }

  void removeTrack(Track t) {
    _tracks.remove(t);
  }

  String get name => _name;
}