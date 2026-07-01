
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  bool autoConnect = false;
  List<String> vinylImages = ["vinyl-default","vinyl-blue", "vinyl-yellow", "vinyl-red"];
  List<String> availableLanguages = ['en','de'];
  int selectedVinylImageIndex = 0;
  String selectedLanguageLocale = 'en';

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    autoConnect = prefs.getBool("spotify_auto_connect") ?? false;
    selectedVinylImageIndex = prefs.getInt("selected_vinyl_image_index") ?? 0;
    notifyListeners();
  }

  Future<void> toggleAutoConnect(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("spotify_auto_connect", value);
    autoConnect = value;
    notifyListeners();
  }

  Future<void> setSelectedVinylIndex(int index) async {
    selectedVinylImageIndex = index;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("selected_vinyl_image_index", index);
    notifyListeners();
  }

  Future<void> setSelectedLanguage(String loc) async {
    selectedLanguageLocale = loc;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("selected_language_locale", loc);
    notifyListeners();
  }
}