// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String players(Object players_length) {
    return 'Players $players_length/8';
  }

  @override
  String get startGame => 'Start Game';

  @override
  String get settings => 'Settings';

  @override
  String get vinylRecordSelection => 'Vinyl Record Selection';

  @override
  String get languageSelection => 'Language Selection';

  @override
  String get spotifyConnected => 'Connected to Spotify!';

  @override
  String get spotifyNotConnected => 'Not connected to Spotify!';

  @override
  String get spotifyDisconnect => 'Disconnect Spotify';

  @override
  String get spotifyConnect => 'Connect to Spotify';

  @override
  String get spotifyAutoConnect => 'Auto connect';

  @override
  String get history => 'History';

  @override
  String game(Object index) {
    return 'Game $index';
  }

  @override
  String playersHistory(Object players_length) {
    return 'Players: $players_length';
  }

  @override
  String playerHistory(Object player_name) {
    return 'Player $player_name';
  }

  @override
  String track(Object track_length) {
    return 'Tracks: $track_length';
  }

  @override
  String get createGame => 'Create Game';

  @override
  String get addPlayers => 'Add Players';

  @override
  String get selectPlaylist => 'Select Playlist';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';
}
