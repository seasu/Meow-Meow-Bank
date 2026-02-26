import 'package:flutter/material.dart';

class AppColors {
  static const gold = Color(0xFFF5A623);
  static const warmYellow = Color(0xFFFFD93D);
  static const pinkOrange = Color(0xFFFF8A80);
  static const softPink = Color(0xFFFFB3B3);
  static const cream = Color(0xFFFFF8E7);
  static const darkText = Color(0xFF4A3728);
  static const catBody = Color(0xFFFCD34D);
  static const catLight = Color(0xFFFDE68A);
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.gold,
    scaffoldBackgroundColor: AppColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.darkText,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
    ),
  );
}
