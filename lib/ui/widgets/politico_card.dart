// =============================================================================
// WIDGET — PoliticoCard
// -----------------------------------------------------------------------------
// Representa UM político na lista: Card + ListTile + avatar com a sigla do
// partido + botão de lixeira. Recebe callbacks para não acoplar à HomePage.
// =============================================================================
import 'package:flutter/material.dart';
import '../../models/politico_model.dart';

class PoliticoCard extends StatelessWidget {
  final PoliticoModel politico;
  final VoidCallback onRemover;
  final VoidCallback onEditar;

  const PoliticoCard({
    super.key,
    required this.politico,
    required this.onRemover,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        // Tocar no card também abre a edição (atalho comum em apps).
        onTap: onEditar,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: Text(
            _siglaPartido(politico.partido),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        title: Text(
          politico.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${politico.partido} • ${politico.uf}'),
        // Dois botões: editar (lápis) e remover (lixeira).
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
              onPressed: onEditar,
            ),
            IconButton(
              tooltip: 'Remover',
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onRemover,
            ),
          ],
        ),
      ),
    );
  }

  /// Gera sigla curta a partir do nome do partido para o avatar.
  /// Ex.: "Partido Verde" -> "PV"; "PT" -> "PT".
  static String _siglaPartido(String partido) {
    final limpo = partido.trim();
    if (limpo.isEmpty) return '?';
    final palavras =
        limpo.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (palavras.length == 1) {
      final unica = palavras.first;
      return unica.substring(0, unica.length >= 2 ? 2 : 1).toUpperCase();
    }
    return palavras.map((w) => w[0].toUpperCase()).take(3).join();
  }
}
