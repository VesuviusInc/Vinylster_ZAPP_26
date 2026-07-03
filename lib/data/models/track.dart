class Track {
  final String _trackId;
  final String _name;
  final List<String> _artists;
  final int _releaseYear;

  Track({
    required String trackId,
    required String name,
    required List<String> artists,
    required int releaseYear,
  }) : _trackId = trackId,
       _name = name,
       _artists = artists,
       _releaseYear = releaseYear {
    if (_releaseYear < 1000 || _releaseYear > 9999) {
      throw ArgumentError("The release year must be between 1000 - 9999");
    }
  }

  String get trackId => _trackId;

  String get name => _name;

  List<String> get artists => _artists;

  int get releaseYear => _releaseYear;

  @override
  String toString() {
    return 'Track{TrackId: $_trackId, Title: $_name, Artists: $_artists, ReleaseYear: $_releaseYear}';
  }

  String getArtistsWithFormat() {
    String formattedString = "";
    artists.asMap().forEach((index, value) => index != artists.length-1 ? formattedString+="$value, " : formattedString+=value);
    return formattedString;
  }
}