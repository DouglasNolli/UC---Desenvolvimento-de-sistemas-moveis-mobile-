// =============================================================================
// MINHA CINEMATECA — FILMES FAVORITOS (OFFLINE)
// -----------------------------------------------------------------------------
// Ponto de entrada do app. Responsabilidade ÚNICA: inicializar o binding,
// carregar as PREFERÊNCIAS salvas (SharedPreferences) e subir o app.
//
// Duas preferências são restauradas aqui, ANTES do runApp:
//   1. tema claro/escuro            -> ThemePreferences
//   2. último termo de busca  ⭐NOVA -> BuscaPreferences
//
// Arquitetura em camadas (cada arquivo tem uma responsabilidade):
//   lib/
//   ├── main.dart                     -> bootstrap (este arquivo)
//   ├── app.dart                      -> MaterialApp + gestão de tema
//   ├── models/filme_model.dart       -> entidade imutável (toMap/fromMap)
//   ├── data/
//   │   ├── database_helper.dart      -> Singleton SQLite (abertura + schema)
//   │   ├── filme_repository.dart     -> CRUD (isola o sqflite da UI)
//   │   ├── theme_preferences.dart    -> SharedPreferences (tema)
//   │   └── busca_preferences.dart    -> SharedPreferences (última busca) ⭐
//   └── ui/
//       ├── home_page.dart            -> FutureBuilder + lista + busca
//       └── widgets/                  -> Card, formulário, estado vazio
// =============================================================================
import 'package:flutter/material.dart';

import 'app.dart';
import 'data/busca_preferences.dart';
import 'data/theme_preferences.dart';

Future<void> main() async {
  // Obrigatório: usamos código assíncrono (SharedPreferences) antes do runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega a preferência de tema persistida (default = Modo Claro).
  final bool isDark = await ThemePreferences().loadIsDarkMode();

  // ⭐ Carrega a NOVA preferência: o último termo pesquisado (default = '').
  final String ultimaBusca = await BuscaPreferences().loadUltimoTermo();

  runApp(MinhaCinematecaApp(
    temaInicialEscuro: isDark,
    termoBuscaInicial: ultimaBusca,
  ));
}
