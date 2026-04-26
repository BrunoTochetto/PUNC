import 'package:flutter/material.dart';
import 'appCores.dart';

class PUNCAppTheme {
  static ThemeData get theme {
    final colorScheme = PUNCCoresClaro();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PUNCCores.claroFundo,
      appBarTheme: AppBarTheme(
        backgroundColor: PUNCCores.claroAppBar,
        foregroundColor: PUNCCores.claroOnAppBar,
        elevation: 0,
      ),
      dividerColor: PUNCCores.claroOutline,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: PUNCCores.claroOnFundo,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: PUNCCores.claroOnFundo,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: PUNCCores.claroOnFundo,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: PUNCCores.claroOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: PUNCCores.claroOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = PUNCCoresEscuro();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PUNCCores.escuroFundo,
      appBarTheme: AppBarTheme(
        backgroundColor: PUNCCores.escuroAppBar,
        foregroundColor: PUNCCores.escuroOnAppBar,
        elevation: 0,
      ),
      dividerColor: PUNCCores.escuroOutline,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: PUNCCores.escuroOnFundo,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: PUNCCores.escuroOnFundo,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: PUNCCores.escuroOnFundo,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: PUNCCores.escuroOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: PUNCCores.escuroOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
