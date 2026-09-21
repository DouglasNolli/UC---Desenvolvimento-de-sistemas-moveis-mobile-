// =============================================================================
// PORTAL CIDADÃO: POLÍTICOS FAVORITOS (OFFLINE)
// -----------------------------------------------------------------------------
// Ponto de entrada do app. Responsabilidade ÚNICA: inicializar o binding,
// carregar o TEMA salvo (SharedPreferences) e subir o app.
//
// Arquitetura em camadas (cada arquivo tem uma responsabilidade):
//   lib/
//   ├── main.dart                     -> bootstrap (este arquivo)
//   ├── app.dart                      -> MaterialApp + gestão de tema
//   ├── models/politico_model.dart    -> entidade imutável (toMap/fromMap)
//   ├── data/
//   │   ├── database_helper.dart      -> Singleton SQLite (abertura + schema)
//   │   ├── politico_repository.dart  -> CRUD (isola o sqflite da UI)
//   │   └── theme_preferences.dart    -> SharedPreferences (tema)
//   └── ui/
//       ├── home_page.dart            -> FutureBuilder + lista + busca
//       └── widgets/                  -> Card, formulário, estado vazio
// =============================================================================
import 'package:flutter/material.dart';

import 'app.dart';
import 'data/theme_preferences.dart';

Future<void> main() async {
  // Obrigatório: usamos código assíncrono (SharedPreferences) antes do runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega a preferência de tema persistida (default = Modo Claro).
  final bool isDark = await ThemePreferences().loadIsDarkMode();

  runApp(PortalCidadaoApp(temaInicialEscuro: isDark));
}
