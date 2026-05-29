import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyService extends ChangeNotifier {
  bool _isConnected = false;
  String? _accessToken;

  bool get isConnected => _isConnected;

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
      return null;
    } on PlatformException catch (e) {
      // mostly exceptions related to the spotify-sdk
      final String specificErrorCode = e.details?.toString() ?? e.code;

      String userFriendlyMessage;

      switch (specificErrorCode) {
        case 'NO_INTERNET_CONNECTION':
          userFriendlyMessage = "Please check your internet connection. You seem to be offline.";
          break;

        case 'COULD_NOT_FIND_SPOTIFY_APP':
          userFriendlyMessage = "Spotify-App is not installed. Please install!";
          break;

        case 'AUTHENTICATION_SERVICE_UNKNOWN_ERROR':
          userFriendlyMessage = "Login was cancelled. Please try again!";
          break;

        case 'USER_LOGGED_OUT':
          userFriendlyMessage = "You're not logged into the Spotify-App. Please log into the app!";
          break;

        case 'OFFLINE_MODE':
          userFriendlyMessage = "The Spotify-App is in the offline-mode please change this setting.";
          break;

        default:
          userFriendlyMessage = "Unexpected Spotify error: $specificErrorCode";
      }

      return userFriendlyMessage;
    } on MissingPluginException {
      return "Error: Spotify SDK Plugin not found.";
    } catch (e) {
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
      return null;
    } catch (e) {
      return "Error while disconnecting: $e";
    }
  }

  Future<void> checkAutoConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final shouldAutoConnect = prefs.getBool("spotify_auto_connect") ?? false;

    if (shouldAutoConnect) {
      await connectToSpotify();
    }
  }
}