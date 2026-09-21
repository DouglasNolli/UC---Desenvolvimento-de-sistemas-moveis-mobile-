// =============================================================================
// WIDGET RAIZ — PortalCidadaoApp
// -----------------------------------------------------------------------------
// Configura o MaterialApp e gerencia o estado do TEMA (claro/escuro),
// persistindo cada alternância no SharedPreferences via ThemePreferences.
// =============================================================================
import 'package:flutter/material.dart';

import 'data/theme_preferences.dart';
import 'ui/home_page.dart';

class PortalCidadaoApp extends StatefulWidget {
  final bool temaInicialEscuro;
  const PortalCidadaoApp({super.key, required this.temaInicialEscuro});

  @override
  State<PortalCidadaoApp> createState() => _PortalCidadaoAppState();
}

class _PortalCidadaoAppState extends State<PortalCidadaoApp> {
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
    const Color seed = Color(0xFF1565C0);

    return MaterialApp(
      title: 'Portal Cidadão',
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
      ),
    );
  }
}
