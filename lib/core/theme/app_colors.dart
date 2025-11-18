import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF121212); // Dark background
  static const Color primary = Color(0xFF00FF00); // Neon Green
  static const Color text = Colors.white;

  // BARU: Warna yang dibutuhkan TaskPage
  static const Color cardBackground = Color(
    0xFF1E1E1E,
  ); // Lebih terang dari background
  static const Color secondary = Color(
    0xFF00FF00,
  ); // Menggunakan primary sebagai secondary (FAB)

  // Custom swatch untuk ThemeData
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF00FF00,
    <int, Color>{
      50: Color(0xFFE5FFE5),
      100: Color(0xFFB3FFB3),
      200: Color(0xFF80FF80),
      300: Color(0xFF4DFF4D),
      400: Color(0xFF26FF26),
      500: Color(0xFF00FF00), // Primary color
      600: Color(0xFF00E600),
      700: Color(0xFF00CC00),
      800: Color(0xFF00B300),
      900: Color(0xFF008000),
    },
  );
}
