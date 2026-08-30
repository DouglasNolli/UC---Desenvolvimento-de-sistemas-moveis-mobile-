import 'package:flutter/material.dart';

import 'themes/app_theme.dart';
import 'views/home_view.dart';

void main() {
  runApp(const PortalCidadaoApp());
}

/// Widget raiz do Portal Cidadão.
///
/// Mantém o [ThemeMode] em um [ValueNotifier], permitindo a troca
/// entre Light e Dark Mode a partir da AppBar da tela principal.
class PortalCidadaoApp extends StatefulWidget {
  const PortalCidadaoApp({super.key});

  @override
  State<PortalCidadaoApp> createState() => _PortalCidadaoAppState();
}

class _PortalCidadaoAppState extends State<PortalCidadaoApp> {
  final ValueNotifier<ThemeMode> _temaNotifier = ValueNotifier(ThemeMode.light);

  @override
  void dispose() {
    _temaNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _temaNotifier,
      builder: (context, modo, _) {
        return MaterialApp(
          title: 'Portal Cidadão',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: modo,
          home: HomeView(temaNotifier: _temaNotifier),
        );
      },
    );
  }
}
