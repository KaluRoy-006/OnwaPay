import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = 'en'; // default English

  String get language => _language;

  void toggleLanguage() {
    _language = _language == 'en' ? 'fr' : 'en';
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }
}
