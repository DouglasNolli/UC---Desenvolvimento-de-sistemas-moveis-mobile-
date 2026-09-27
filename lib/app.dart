// =============================================================================
// WIDGET RAIZ — MinhaCinematecaApp
// -----------------------------------------------------------------------------
// Configura o MaterialApp e gerencia o estado do TEMA (claro/escuro),
// persistindo cada alternância no SharedPreferences via ThemePreferences.
//
// Recebe também o `termoBuscaInicial` lido do SharedPreferences no main() e
// o repassa para a HomePage, que já abre com o filtro da última sessão.
// =============================================================================
import 'package:flutter/material.dart';

import 'data/i_filme_repository.dart';
import 'ui/home_page.dart';
import 'data/theme_preferences.dart';

class MinhaCinematecaApp extends StatefulWidget {
  final bool temaInicialEscuro;

  /// ⭐ Último termo de busca restaurado do SharedPreferences.
  final String termoBuscaInicial;

  /// Repositório injetável (opcional). Usado nos testes de UI.
  final IFilmeRepository? repository;

  const MinhaCinematecaApp({
    super.key,
    required this.temaInicialEscuro,
    this.termoBuscaInicial = '',
    this.repository,
  });

  @override
  State<MinhaCinematecaApp> createState() => _MinhaCinematecaAppState();
}

class _MinhaCinematecaAppState extends State<MinhaCinematecaApp> {
  final ThemePreferences _themePrefs = ThemePreferences();
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.temaInicialEscuro; // valor lido no main()
  }

  /// Alterna o tema e PERSISTE a escolha no SharedPreferences.
  Future<void> _alternarTema() async {
    setState(() => _isDarkMode = !_isDarkMode);
    await _themePrefs.saveIsDarkMode(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    // Roxo "cortina de cinema" como cor semente do Material 3.
    const Color seed = Color(0xFF6A1B9A);

    return MaterialApp(
      title: 'Minha Cinemateca',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      home: HomePage(
        isDarkMode: _isDarkMode,
        onAlternarTema: _alternarTema,
        termoBuscaInicial: widget.termoBuscaInicial,
        repository: widget.repository,
      ),
    );
  }
}
