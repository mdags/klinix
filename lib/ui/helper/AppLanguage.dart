import 'package:flutter/material.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('tr');

  Locale get appLocal => _appLocale ?? Locale("tr");

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('tr');
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code'));
    return Null;
  }


  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == Locale("tr")) {
      _appLocale = Locale("tr");
      await prefs.setString('language_code', 'tr');
      await prefs.setString('countryCode', 'TR');
      Variables.lang = 'tr';
    }
    else if (type == Locale("en")) {
      _appLocale = Locale("en");
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
      Variables.lang = 'en';
    }
    else if (type == Locale("de")) {
      _appLocale = Locale("de");
      await prefs.setString('language_code', 'de');
      await prefs.setString('countryCode', 'DE');
      Variables.lang = 'de';
    }
    else if (type == Locale("ar")) {
      _appLocale = Locale("ar");
      await prefs.setString('language_code', 'ar');
      await prefs.setString('countryCode', 'AR');
      Variables.lang = 'ar';
    }
    notifyListeners();
  }
}