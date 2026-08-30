import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

/// Componente reutilizável de estados de tela (DRY).
///
/// Padroniza o feedback de carregamento, erro e lista vazia em todas
/// as telas do app, evitando repetição de `CircularProgressIndicator`.
class EstadoView extends StatelessWidget {
  final IconData icone;
  final String mensagem;
  final VoidCallback? aoTentarNovamente;

  const EstadoView({
    super.key,
    required this.icone,
    required this.mensagem,
    this.aoTentarNovamente,
  });

  /// Loader padrão exibido enquanto a API é consultada.
  static Widget carregando([String mensagem = 'Carregando dados públicos...']) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppTheme.espacamentoPadrao),
          Text(mensagem, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.espacamentoPadrao * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 46, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: AppTheme.espacamentoPadrao),
            Text(mensagem, textAlign: TextAlign.center),
            if (aoTentarNovamente != null) ...[
              const SizedBox(height: AppTheme.espacamentoPadrao),
              ElevatedButton.icon(
                onPressed: aoTentarNovamente,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
