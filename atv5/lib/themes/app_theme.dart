import 'package:flutter/material.dart';

/// Design System centralizado do aplicativo.
///
/// Todas as cores, espaçamentos, arredondamentos e estilos visuais
/// utilizados pelo app devem ser definidos aqui, evitando valores
/// "mágicos" espalhados pelas telas.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------
  // PALETA DE CORES
  // ---------------------------------------------------------------------
  static const Color corPrimaria = Color(0xFF0D47A1); // Azul industrial
  static const Color corPrimariaClara = Color(0xFF5472D3);
  static const Color corSecundaria = Color(0xFFFF6F00); // Laranja alerta
  static const Color corFundo = Color(0xFFF3F5F7);
  static const Color corSuperficie = Color(0xFFFFFFFF);
  static const Color corTextoPrincipal = Color(0xFF1B1F23);
  static const Color corTextoSecundario = Color(0xFF5F6B7A);

  // Cores de status, usadas em sensores e ocorrências
  static const Color corCritico = Color(0xFFD32F2F);
  static const Color corAlerta = Color(0xFFF9A825);
  static const Color corInfo = Color(0xFF1976D2);
  static const Color corNormal = Color(0xFF2E7D32);

  // ---------------------------------------------------------------------
  // ARREDONDAMENTOS E ESPAÇAMENTOS
  // ---------------------------------------------------------------------
  static const double radiusPadrao = 16.0;
  static const double radiusPequeno = 8.0;
  static const double espacamentoPadrao = 16.0;
  static const double espacamentoPequeno = 8.0;

  /// Retorna a cor associada a uma gravidade/status textual.
  static Color corPorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'crítico':
      case 'critico':
        return corCritico;
      case 'alerta':
        return corAlerta;
      case 'info':
        return corInfo;
      default:
        return corNormal;
    }
  }

  // ---------------------------------------------------------------------
  // TEXT THEME
  // ---------------------------------------------------------------------
  static const TextTheme _textTheme = TextTheme(
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: corTextoPrincipal,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: corTextoPrincipal,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: corTextoSecundario,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  // ---------------------------------------------------------------------
  // THEME DATA GLOBAL
  // ---------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: corFundo,
      primaryColor: corPrimaria,
      colorScheme: ColorScheme.fromSeed(
        seedColor: corPrimaria,
        primary: corPrimaria,
        secondary: corSecundaria,
        surface: corSuperficie,
      ),
      textTheme: _textTheme,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: corPrimaria,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: corSuperficie,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPadrao),
        ),
      ),

      // Botões elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: corPrimaria,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: espacamentoPadrao,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPequeno),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Inputs (campos de texto)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: corSuperficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: espacamentoPadrao,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPequeno),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPequeno),
          borderSide: const BorderSide(color: Color(0xFFDDE2E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPequeno),
          borderSide: const BorderSide(color: corPrimaria, width: 1.5),
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: corTextoPrincipal,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPequeno),
        ),
      ),

      // Divisores
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE1E5EA),
        thickness: 1,
      ),
    );
  }
}
