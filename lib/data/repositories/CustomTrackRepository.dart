import 'package:vinylster_zapp_26/data/models/Track.dart';
import 'package:vinylster_zapp_26/data/repositories/TrackRepository.dart';
import 'package:vinylster_zapp_26/data/services/SpotifyService.dart';

class CustomTrackRepository extends TrackRepository {
  final SpotifyService _spotifyService;
  int _cachedTimes = 0;
  final List<Track> _cachedTracks = [];

  CustomTrackRepository(this._spotifyService);

  @override
  Future<List<Track>> getRandomTracks(int amount) async {
    if (!_spotifyService.isConnected) {
      return [];
    }

    if(_cachedTracks.length < amount) {
      int diff = amount - _cachedTracks.length;
      for (int i = 0; i < diff % SpotifyService.maxItemLimit; i++) {
        List<Track> newlyCachedTracks = await _spotifyService.getTracks(
          _cachedTimes * SpotifyService.maxItemLimit,
        );
        _cachedTracks.addAll(newlyCachedTracks);
        _cachedTimes++;
      }
    }

    _cachedTracks.shuffle();
    return _cachedTracks.take(amount).toList();
  }

  @override
  Future<Track?> getTrackById(String id) {
    // TODO: implement getTrackById
    throw UnimplementedError();
  }

}