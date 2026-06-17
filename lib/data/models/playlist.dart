
class Playlist {
  final String _id;
  final String _name;
  final int _trackCount;
  final String _imageUrl;

  Playlist(this._id, this._name, this._trackCount, this._imageUrl);

  String get playlistId => _id;

  String get imageUrl => _imageUrl;

  int get trackCount => _trackCount;

  String get name => _name;
}