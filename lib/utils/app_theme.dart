import 'package:flutter/material.dart';

class AppTheme {
  // Devuelve el tema visual principal de la app
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
      ),
    );
  }
}
