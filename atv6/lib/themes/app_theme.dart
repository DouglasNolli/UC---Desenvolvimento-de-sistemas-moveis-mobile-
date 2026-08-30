import 'package:flutter/material.dart';

/// Design System centralizado do Portal Cidadão.
///
/// Concentra paleta, espaçamentos e estilos em um único ponto, com
/// suporte obrigatório a **Light Mode** e **Dark Mode**. Nenhuma tela
/// deve declarar cores "mágicas" fora desta classe.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------
  // PALETA (neutra e institucional, focada em legibilidade)
  // ---------------------------------------------------------------------
  static const Color corPrimaria = Color(0xFF14532D); // Verde institucional
  static const Color corSecundaria = Color(0xFFB08D2E); // Dourado cívico

  static const Color corAlto = Color(0xFFC62828); // Despesa alta
  static const Color corMedio = Color(0xFFEF6C00); // Despesa média
  static const Color corBaixo = Color(0xFF2E7D32); // Despesa baixa

  // ---------------------------------------------------------------------
  // ESPAÇAMENTOS E RAIOS
  // ---------------------------------------------------------------------
  static const double espacamentoPadrao = 16.0;
  static const double espacamentoPequeno = 8.0;
  static const double radiusPadrao = 16.0;
  static const double radiusPequeno = 8.0;

  /// Cor associada ao nível de uma despesa (usada pelo badge reutilizável).
  static Color corPorNivel(String nivel) {
    switch (nivel) {
      case 'Alto':
        return corAlto;
      case 'Médio':
        return corMedio;
      default:
        return corBaixo;
    }
  }

  static ThemeData get lightTheme => _construir(Brightness.light);
  static ThemeData get darkTheme => _construir(Brightness.dark);

  /// Constrói o [ThemeData] para o brilho informado (DRY entre claro/escuro).
  static ThemeData _construir(Brightness brilho) {
    final bool escuro = brilho == Brightness.dark;
    final ColorScheme esquema = ColorScheme.fromSeed(
      seedColor: corPrimaria,
      brightness: brilho,
      secondary: corSecundaria,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: escuro ? const Color(0xFF121417) : const Color(0xFFF4F6F5),
      appBarTheme: AppBarTheme(
        backgroundColor: escuro ? const Color(0xFF1B1F23) : corPrimaria,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: escuro ? 0 : 2,
        color: escuro ? const Color(0xFF1E2227) : Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPadrao)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: esquema.primary,
          foregroundColor: esquema.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: espacamentoPadrao, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPequeno)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: escuro ? const Color(0xFF1E2227) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: espacamentoPadrao, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPequeno),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPequeno)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPequeno)),
      ),
    );
  }
}
