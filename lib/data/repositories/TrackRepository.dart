import '../models/Track.dart';

abstract class TrackRepository {
  Future<Track?> getTrackById(String id);

  Future<List<Track>> getRandomTracks(int amount);
}