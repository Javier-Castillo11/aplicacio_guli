import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  
  String _currentLanguage = 'es'; // 'es' para español, 'en' para inglés

  String get currentLanguage => _currentLanguage;

  void changeLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }
}