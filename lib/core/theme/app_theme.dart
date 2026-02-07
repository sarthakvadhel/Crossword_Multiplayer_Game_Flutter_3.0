import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF1B5E20);  // Deep green
  static const Color accentColor = Color(0xFF4CAF50);   // Green
  static const Color boardBackground = Color(0xFFF5F5DC); // Beige
  static const Color tileColor = Color(0xFFFFD54F);      // Yellow/gold tiles
  static const Color tileTextColor = Color(0xFF3E2723);  // Dark brown
  static const Color lockedTileColor = Color(0xFFE8E8E8);
  static const Color highlightColor = Color(0xFF81C784); // Light green highlight
  static const Color blockedColor = Color(0xFF212121);   // Black for blocked cells
  static const Color clueColor = Color(0xFFBBDEFB);     // Light blue for clue cells
  static const Color scoreColor = Color(0xFFFF6F00);     // Orange for scores
  static const Color bannerColor = Color(0xFFFFD600);    // Gold for banners

  static ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.green,
    scaffoldBackgroundColor: boardBackground,
    appBarTheme: AppBarTheme(backgroundColor: primaryColor, foregroundColor: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: tileTextColor),
      bodyLarge: TextStyle(fontSize: 16, color: tileTextColor),
    ),
  );

  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Color(0xFF121212),
  );
}
