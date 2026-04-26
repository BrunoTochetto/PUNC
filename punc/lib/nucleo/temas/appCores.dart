import 'package:flutter/material.dart';

class PUNCCores {
  // Paleta clara
  static Color claroPrimaria = const Color(0xFF4F46E5);
  static Color claroOnPrimaria = Colors.white;
  static Color claroSecundaria = const Color(0xFF06B6D4);
  static Color claroOnSecundaria = Colors.white;
  static Color claroErro = const Color(0xFFB00020);
  static Color claroOnErro = Colors.white;
  static Color claroSuperficie = const Color(0xFFF7F7FB);
  static Color claroOnSuperficie = const Color(0xFF111827);
  static Color claroFundo = const Color(0xFFFFFFFF);
  static Color claroOnFundo = const Color(0xFF111827);
  static Color claroAppBar = const Color(0xFF4338CA);
  static Color claroOnAppBar = Colors.white;
  static Color claroOutline = const Color(0xFF94A3B8);

  // Paleta escura
  static Color escuroPrimaria = const Color(0xFF818CF8);
  static Color escuroOnPrimaria = const Color(0xFF111827);
  static Color escuroSecundaria = const Color(0xFF22D3EE);
  static Color escuroOnSecundaria = const Color(0xFF111827);
  static Color escuroErro = const Color(0xFFCF6679);
  static Color escuroOnErro = const Color(0xFF111827);
  static Color escuroSuperficie = const Color(0xFF111827);
  static Color escuroOnSuperficie = const Color(0xFFF3F4F6);
  static Color escuroFundo = const Color(0xFF0B1120);
  static Color escuroOnFundo = const Color(0xFFE5E7EB);
  static Color escuroAppBar = const Color(0xFF1E1B4B);
  static Color escuroOnAppBar = const Color(0xFFF9FAFB);
  static Color escuroOutline = const Color(0xFF475569);
}

ColorScheme PUNCCoresClaro() {
  return ColorScheme(
    brightness: Brightness.light,
    primary: PUNCCores.claroPrimaria,
    onPrimary: PUNCCores.claroOnPrimaria,
    secondary: PUNCCores.claroSecundaria,
    onSecondary: PUNCCores.claroOnSecundaria,
    error: PUNCCores.claroErro,
    onError: PUNCCores.claroOnErro,
    surface: PUNCCores.claroSuperficie,
    onSurface: PUNCCores.claroOnSuperficie,
  );
}

ColorScheme PUNCCoresEscuro() {
  return ColorScheme(
    brightness: Brightness.dark,
    primary: PUNCCores.escuroPrimaria,
    onPrimary: PUNCCores.escuroOnPrimaria,
    secondary: PUNCCores.escuroSecundaria,
    onSecondary: PUNCCores.escuroOnSecundaria,
    error: PUNCCores.escuroErro,
    onError: PUNCCores.escuroOnErro,
    surface: PUNCCores.escuroSuperficie,
    onSurface: PUNCCores.escuroOnSuperficie,
  );
}