import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app language (Bangla or English), remembered between launches.
class LocaleStore extends ChangeNotifier {
  static const _key = 'app_language';
  late SharedPreferences _prefs;
  Locale _locale = const Locale('bn');

  Locale get locale => _locale;
  bool get isEnglish => _locale.languageCode == 'en';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _locale = Locale(_prefs.getString(_key) ?? 'bn');
  }

  Future<void> set(String languageCode) async {
    if (languageCode == _locale.languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    await _prefs.setString(_key, languageCode);
  }
}
