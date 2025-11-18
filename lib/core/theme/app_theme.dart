import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark().copyWith(
    primary: AppColors.primary,
    // PERBAIKAN: Mengganti 'background' yang deprecated dengan 'surface'
    surface: AppColors.background,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.text),
    bodyMedium: TextStyle(color: AppColors.text),
    // ... Tambahkan gaya teks lain sesuai kebutuhan
  ),
);
