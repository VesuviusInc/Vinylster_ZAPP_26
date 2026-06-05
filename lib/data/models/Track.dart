class Track {
  final String _trackId;
  final String _name;
  final List<String> _artists;

  Track(this._trackId, this._name, this._artists);

  List<String> get artists => _artists;

  String get title => _name;

  String get trackId => _trackId;

  @override
  String toString() {
    return 'Track{TrackId: $_trackId, Title: $_name, Artists: $_artists}';
  }
}