import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    final base = ThemeData.from(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      primaryColor: Colors.indigo,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E40AF),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1E40AF),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
    );
  }
}
