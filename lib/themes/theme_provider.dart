import 'package:duantotnghiep_app_thue_xe/themes/dark_mode.dart';
import 'package:duantotnghiep_app_thue_xe/themes/light_mode.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;
  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toogleTheme(bool isDarkMode) {
    if (isDarkMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }

    notifyListeners();
  }
}
