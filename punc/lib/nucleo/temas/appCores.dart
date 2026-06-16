import 'package:flutter/material.dart';

class PUNCCores {
  // ==========================
  // TEMA CLARO (Wireframe Figma)
  // ==========================

  // Verde acinzentado do topo e rodapé
  static const Color claroPrimaria = Color(0xFF5D7778);
  static const Color claroOnPrimaria = Colors.white;

  // Verde dos botões principais
  static const Color claroSecundaria = Color(0xFF6B9D6F);
  static const Color claroOnSecundaria = Colors.white;

  // Erro
  static const Color claroErro = Color(0xFFE57373);
  static const Color claroOnErro = Colors.white;

  // Fundo de elementos destacados
  static const Color claroSuperficie = Color(0xFFDCECDD);
  static const Color claroOnSuperficie = Color(0xFF333333);

  // Fundo geral da aplicação
  static const Color claroFundo = Color(0xFFF5F5F5);
  static const Color claroOnFundo = Color(0xFF333333);

  // AppBar
  static const Color claroAppBar = Color(0xFF5D7778);
  static const Color claroOnAppBar = Colors.white;

  // Bordas
  static const Color claroOutline = Color(0xFFE5E5E5);

  // Texto secundário
  static const Color claroTextoSecundario = Color(0xFF7A7A7A);

  // Cards
  static const Color claroCard = Colors.white;

  // ==========================
  // TEMA ESCURO
  // ==========================

  static const Color escuroPrimaria = Color(0xFF6B9D6F);
  static const Color escuroOnPrimaria = Colors.white;

  static const Color escuroSecundaria = Color(0xFF5D7778);
  static const Color escuroOnSecundaria = Colors.white;

  static const Color escuroErro = Color(0xFFCF6679);
  static const Color escuroOnErro = Colors.white;

  static const Color escuroSuperficie = Color(0xFF2F3A3A);
  static const Color escuroOnSuperficie = Color(0xFFF5F5F5);

  static const Color escuroFundo = Color(0xFF1F2727);
  static const Color escuroOnFundo = Color(0xFFF5F5F5);

  static const Color escuroAppBar = Color(0xFF2F3A3A);
  static const Color escuroOnAppBar = Colors.white;

  static const Color escuroOutline = Color(0xFF4A5656);

  static const Color escuroTextoSecundario = Color(0xFFB0B0B0);

  static const Color escuroCard = Color(0xFF374242);
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
    surface: PUNCCores.claroCard,
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
    surface: PUNCCores.escuroCard,
    onSurface: PUNCCores.escuroOnSuperficie,
  );
}