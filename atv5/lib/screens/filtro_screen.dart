import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

/// Tela 4 — Filtro Avançado por Gravidade.
///
/// Permite ao usuário selecionar uma gravidade (ou "Todos") e retorna
/// o valor escolhido para a tela anterior utilizando
/// `Navigator.pop(context, filtroSelecionado)`.
class FiltroScreen extends StatelessWidget {
  const FiltroScreen({super.key});

  static const List<Map<String, dynamic>> _opcoes = [
    {'label': 'Todos', 'icone': Icons.filter_alt_off, 'cor': AppTheme.corPrimaria},
    {'label': 'Crítico', 'icone': Icons.error, 'cor': AppTheme.corCritico},
    {'label': 'Alerta', 'icone': Icons.warning_amber, 'cor': AppTheme.corAlerta},
    {'label': 'Info', 'icone': Icons.info, 'cor': AppTheme.corInfo},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filtrar por Gravidade')),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.espacamentoPadrao),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecione a gravidade desejada',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'A lista de ocorrências será atualizada de acordo com a opção escolhida.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.espacamentoPadrao),
            Expanded(
              child: ListView.separated(
                itemCount: _opcoes.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppTheme.espacamentoPequeno),
                itemBuilder: (context, index) {
                  final opcao = _opcoes[index];
                  final Color cor = opcao['cor'] as Color;
                  final String label = opcao['label'] as String;

                  return Card(
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusPadrao),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: cor.withOpacity(0.15),
                        child: Icon(opcao['icone'] as IconData, color: cor),
                      ),
                      title: Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Retorna o valor selecionado para a LogsScreen.
                        Navigator.pop(context, label);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
