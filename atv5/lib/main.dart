import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const SupervisaoApp());
}

/// Widget raiz do aplicativo de Supervisão de Máquinas.
class SupervisaoApp extends StatelessWidget {
  const SupervisaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supervisão de Máquinas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
