import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static Color primary = const Color(0xFF1E88E5);
  static Color incomeColor = const Color(0xFF43A047);
  static Color expenseColor = const Color(0xFFE53935);
  static Color background = const Color(0xFFF9FAFB);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}
