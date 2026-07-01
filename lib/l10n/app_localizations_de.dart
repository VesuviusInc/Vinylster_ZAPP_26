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
}
