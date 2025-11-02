import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _keyLanguageCode = 'language_code';
  Locale _locale = const Locale('vi'); // Default Vietnamese

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_keyLanguageCode) ?? 'vi';
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguageCode, languageCode);
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  Future<void> toggleLanguage() async {
    final newLanguageCode = _locale.languageCode == 'vi' ? 'en' : 'vi';
    await setLanguage(newLanguageCode);
  }

  bool get isVietnamese => _locale.languageCode == 'vi';
  bool get isEnglish => _locale.languageCode == 'en';
}
