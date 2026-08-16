import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const OrquestradorDadosApp());
}

class OrquestradorDadosApp extends StatelessWidget {
  const OrquestradorDadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orquestrador de Dados',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}