import 'package:flutter/material.dart';

/// ATV1 - O Otimizador de Listas (Refatoração)
///
/// PROBLEMA ORIGINAL: SingleChildScrollView + Column construíam os 100
/// itens de uma só vez, mesmo os que ficavam fora da tela (viewport).
///
/// SOLUÇÃO: ListView.builder constrói (via itemBuilder) somente os itens
/// visíveis, reciclando widgets conforme o usuário rola a lista.
class ListaOtimizadaScreen extends StatelessWidget {
  final List<String> itens =
      List.generate(100, (index) => "Registro de Máquina #${index + 1}");

  ListaOtimizadaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logs Industriais - Otimizado"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: itens.length,
        itemBuilder: (context, index) {
          final item = itens[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.history_toggle_off, color: Colors.red),
              title: Text(item),
              subtitle: const Text("Status: Renderizado sob demanda"),
            ),
          );
        },
      ),
    );
  }
}
