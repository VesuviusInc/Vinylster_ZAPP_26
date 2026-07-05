// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String players(Object players_length) {
    return 'Spieler $players_length/8';
  }

  @override
  String get startGame => 'Spiel starten';

  @override
  String get settings => 'Einstellungen';

  @override
  String get vinylRecordSelection => 'Vinyl Schallplatten Auswahl';

  @override
  String get languageSelection => 'Sprachauswahl';

  @override
  String get spotifyConnected => 'Verbunden mit Spotify!';

  @override
  String get spotifyNotConnected => 'Nicht Verbunden mit Spotify!';

  @override
  String get spotifyDisconnect => 'Trennen von Spotify';

  @override
  String get spotifyConnect => 'Verbinden mit Spotify';

  @override
  String get spotifyAutoConnect => 'Automatisch verbinden';

  @override
  String get history => 'Geschichte';

  @override
  String game(Object index) {
    return 'Spiel $index';
  }

  @override
  String playersHistory(Object players_length) {
    return 'Spieler: $players_length';
  }

  @override
  String playerHistory(Object player_name) {
    return 'Spieler $player_name';
  }

  @override
  String track(Object track_length) {
    return 'Songs: $track_length';
  }

  @override
  String get createGame => 'Spiel erstellen';

  @override
  String get addPlayers => 'Spieler hinzufügen';

  @override
  String get selectPlaylist => 'Playlist auswählen';

  @override
  String get save => 'Speichern';

  @override
  String get close => 'Schließen';
}
