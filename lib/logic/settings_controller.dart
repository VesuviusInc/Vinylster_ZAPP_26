
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  bool autoConnect = false;

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    autoConnect = prefs.getBool("spotify_auto_connect") ?? false;
    notifyListeners();
  }

  Future<void> toggleAutoConnect(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("spotify_auto_connect", value);
    autoConnect = value;
    notifyListeners();
  }
}