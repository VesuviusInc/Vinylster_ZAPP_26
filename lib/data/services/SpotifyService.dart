import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:http/http.dart' as http;
import '../models/Track.dart';

class SpotifyService extends ChangeNotifier {
  // maximum number of items returned by playlist
  static const int songPreviewLengthSeconds = 30;
  static const maxItemLimit = 50;
  bool _isConnected = false;
  String? _accessToken;
  final List<Track> _playedTracks = [];

  // default playlistId, TODO: replace with locally stored list of songs, unless user chooses playlist
  late String _playlistId = "07qHJQ2ZwEU3KWsElhCIis";
  final List<Track> _cachedTracks = [];
  int _cachedTimes = 0;
  Track? _currentTrack;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  int _remainingMilliseconds = songPreviewLengthSeconds * 1000;
  late Logger _logger;

  bool get isConnected => _isConnected;

  String get currentTrackId =>
      _currentTrack == null ? "" : _currentTrack!.trackId;

  SpotifyService() {
    _initLogger();
  }

  Future<void> _initLogger() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final logFilePath = "${appDocDir.path}/vinylster_spotify_errors.log";
    final logFile = File(logFilePath);

    _logger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        colors: true,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(file: logFile, overrideExisting: false),
      ]),
    );

    _logger.i("Logger successfully initialized. Log-File: $logFilePath");
  }

  Future<String?> connectToSpotify() async {
    try {
      final String clientId = dotenv.get("CLIENT_ID");
      final String redirectUri = dotenv.get("REDIRECT_URI");

      _accessToken = await SpotifySdk.getAccessToken(
        clientId: clientId,
        redirectUrl: redirectUri,
        scope: 'user-read-currently-playing app-remote-control',
      );

      _isConnected = await SpotifySdk.connectToSpotifyRemote(
        clientId: clientId,
        redirectUrl: redirectUri,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("spotify_auto_connect", true);

      notifyListeners();
      _logger.i("Successfully connected to Spotify SDK");

      return null;
    } on PlatformException catch (e) {
      // mostly exceptions related to the spotify-sdk
      final String specificErrorCode = e.details?.toString() ?? e.code;

      String userFriendlyMessage;
      _logger.e("Error in SpotifyService.connectToSpotify(): $e");
      switch (specificErrorCode) {
        case 'NO_INTERNET_CONNECTION':
          userFriendlyMessage =
              "Please check your internet connection. You seem to be offline.";
          break;

        case 'COULD_NOT_FIND_SPOTIFY_APP':
          userFriendlyMessage = "Spotify-App is not installed. Please install!";
          break;

        case 'AUTHENTICATION_SERVICE_UNKNOWN_ERROR':
          userFriendlyMessage = "Login was cancelled. Please try again!";
          break;

        case 'USER_LOGGED_OUT':
          userFriendlyMessage =
              "You're not logged into the Spotify-App. Please log into the app!";
          break;

        case 'OFFLINE_MODE':
          userFriendlyMessage =
              "The Spotify-App is in the offline-mode please change this setting.";
          break;

        default:
          userFriendlyMessage = "Unexpected Spotify error: $specificErrorCode";
      }
      return userFriendlyMessage;
    } on MissingPluginException {
      _logger.e("Error in SpotifyService.connectToSpotify(): $e");
      return "Error: Spotify SDK Plugin not found.";
    } catch (e) {
      _logger.e("Error in SpotifyService.connectToSpotify(): $e");
      return "Unexpected error: $e";
    }
  }

  Future<String?> disconnect() async {
    try {
      await SpotifySdk.disconnect();
      _isConnected = false;
      _accessToken = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("spotify_auto_connect", false);

      notifyListeners();
      // resetting playback timer
      _resetTimer();

      _logger.i("Successfully disconnected from the Spotify SDK.");
      return null;
    } on MissingPluginException catch (e, stackTrace) {
      _logger.f(
        "Critical Error: Missing native channel for Spotify SDK. Unsupported platform?",
        error: e,
        stackTrace: stackTrace,
      );
      return "Missing native channel for Spotify SDK. Unsupported platform?";
    } on PlatformException catch (e, stackTrace) {
      _logger.e(
        "Native platform error from Spotify SDK! Code: ${e.code}. Message: ${e.message}",
        error: e,
        stackTrace: stackTrace,
      );
      return "Native platform error from Spotify SDK! Code: ${e.code}. Message: ${e.message}";
    } catch (e, stackTrace) {
      _logger.e(
        "Unexpected error while disconnecting.",
        error: e,
        stackTrace: stackTrace,
      );
      return "Unexpected error while disconnecting";
    }
  }

  Future<void> checkAutoConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final shouldAutoConnect = prefs.getBool("spotify_auto_connect") ?? false;
    _logger.i("AutoConnect is ${shouldAutoConnect ? "enabled" : "disabled"}");
    final customPlaylistId = prefs.getString("custom_playlist_id");
    if (customPlaylistId != null && customPlaylistId.isNotEmpty) {
      _playlistId = customPlaylistId;
    }

    if (shouldAutoConnect) {
      await connectToSpotify();
    }
    // TODO: remove, only called here for testing
    // await start();
    notifyListeners();
  }

  Future<void> setCustomPlaylistId(String playlistId) async {
    _playlistId = playlistId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("custom_playlist_id", playlistId);

    notifyListeners();
  }

  String _getPlaylistIdByUrl(String playlistUrl) {
    int startIndex = playlistUrl.indexOf("playlist") + 9;
    int endIndex = playlistUrl.indexOf("?");
    if (endIndex == -1) {
      endIndex = playlistUrl.length;
    }
    return playlistUrl.substring(startIndex, endIndex);
  }

  // should be called when game ist started
  Future<void> start() async {
    if (!_isConnected) {
      return;
    }
    // optional TODO: when starting the game, cache more than 50 songs, to not always get the same songs
    await cacheTracks();
    await nextRandomTrack();
  }

  Future<void> nextRandomTrack() async {
    if (!_isConnected) {
      return;
    }

    // caching next tracks if no more cached tracks are available
    if (_cachedTracks.isEmpty) {
      await cacheTracks();
    }

    _logger.i("_cachedTracks.length: ${_cachedTracks.length}");
    if (_currentTrack != null) {
      _playedTracks.add(_currentTrack!);
    }
    int maxIndex = _cachedTracks.length;
    int randomIndex = Random().nextInt(maxIndex);
    _currentTrack = _cachedTracks[randomIndex];
    _cachedTracks.remove(_currentTrack);

    _logger.i(
      "currentTrack: ${_currentTrack == null ? "null" : _currentTrack!.name}",
    );
    notifyListeners();
  }

  Future<void> cacheTracks() async {
    if (!_isConnected) {
      return;
    }

    List<Track> newlyCachedTracks = await getTracks(
      _cachedTimes * maxItemLimit,
    );
    _cachedTracks.addAll(newlyCachedTracks);
    _cachedTimes++;
  }

  Future<List<Track>> getTracks(
    int offset, {
    int limit = SpotifyService.maxItemLimit,
  }) async {
    List<Track> tracks = [];
    if (_accessToken == null || !_isConnected) {
      return tracks;
    }
    try {
      final url = Uri.parse(
        "https://api.spotify.com/v1/playlists/$_playlistId/items?offset=$offset&limit=$limit",
      );
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $_accessToken"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List tracksJson = data["items"];
        for (final track in tracksJson) {
          String trackName = track["item"]["name"];
          String trackId = track["item"]["id"];
          List<String> artists = [];
          int releaseYear = _getReleaseYearFromString(track["item"]["album"]["release_date"]);
          for (final artist in track["item"]["artists"]) {
            artists.add(artist["name"]);
          }
          Track newTrack = Track(trackId: trackId, name: trackName, artists: artists, releaseYear: releaseYear);
          tracks.add(newTrack);
        }
      }
    } catch (e) {
      _logger.e("Error in SpotifyService.getTracks(): $e");
    }
    return tracks;
  }

  // plays only a 30 seconds preview
  Future<void> playSong() async {
    if (!_isConnected) {
      return;
    }
    try {
      if (_currentTrack == null) {
        return;
      }

      await SpotifySdk.play(
        spotifyUri: "spotify:track:${_currentTrack!.trackId}",
      );
      _startTimer();
    } on MissingPluginException catch (e, stackTrace) {
      _logger.f(
        "Critical Error: Missing native channel for Spotify SDK. Unsupported platform?",
        error: e,
        stackTrace: stackTrace,
      );
    } on PlatformException catch (e, stackTrace) {
      _logger.e(
        "Native platform error from Spotify SDK! Code: ${e.code}. Message: ${e.message}",
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.e(
        "Unexpected error while attempting to play song.",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> pauseSong() async {
    if (!_isConnected) {
      return;
    }
    try {
      await SpotifySdk.pause();
      _pauseTimer();
    } on MissingPluginException catch (e, stackTrace) {
      _logger.f(
        "Critical Error: Missing native channel for Spotify SDK. Unsupported platform?",
        error: e,
        stackTrace: stackTrace,
      );
    } on PlatformException catch (e, stackTrace) {
      _logger.e(
        "Native platform error from Spotify SDK! Code: ${e.code}. Message: ${e.message}",
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.e(
        "Unexpected error while attempting to pause song.",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> resumeSong() async {
    if (!_isConnected) {
      return;
    }
    try {
      await SpotifySdk.resume();
      _startTimer();
    } on MissingPluginException catch (e, stackTrace) {
      _logger.f(
        "Critical Error: Missing native channel for Spotify SDK. Unsupported platform?",
        error: e,
        stackTrace: stackTrace,
      );
    } on PlatformException catch (e, stackTrace) {
      _logger.e(
        "Native platform error from Spotify SDK! Code: ${e.code}. Message: ${e.message}",
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.e(
        "Unexpected error while attempting to resume song.",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> stopSong() async {
    if (!_isConnected) {
      return;
    }
    try {
      await SpotifySdk.pause();
      _resetTimer();
    } on MissingPluginException catch (e, stackTrace) {
      _logger.f(
        "Critical Error: Missing native channel for Spotify SDK. Unsupported platform?",
        error: e,
        stackTrace: stackTrace,
      );
    } on PlatformException catch (e, stackTrace) {
      _logger.e(
        "Native platform error from Spotify SDK! Code: ${e.code}. Message: ${e.message}",
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.e(
        "Unexpected error while attempting to stop song.",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _startTimer() {
    // cancel when already running
    _timer?.cancel();

    _stopwatch.reset();
    _stopwatch.start();

    _timer = Timer(Duration(milliseconds: _remainingMilliseconds), () async {
      await SpotifySdk.pause();
      _stopwatch.stop();
      _remainingMilliseconds = 0;
      _resetTimer();
      notifyListeners();
    });
  }

  void _pauseTimer() {
    // cancel when already running
    _timer?.cancel();

    _stopwatch.stop();
    _remainingMilliseconds -= _stopwatch.elapsedMilliseconds;

    if (_remainingMilliseconds < 0) {
      _remainingMilliseconds = 0;
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _stopwatch.stop();
    _remainingMilliseconds = SpotifyService.songPreviewLengthSeconds * 1000;
  }

  int _getReleaseYearFromString(String releaseYear) {
    return int.parse(releaseYear.substring(0, 4));
  }
}
