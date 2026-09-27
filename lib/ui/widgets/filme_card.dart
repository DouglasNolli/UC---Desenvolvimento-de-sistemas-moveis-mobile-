// =============================================================================
// WIDGET — FilmeCard
// -----------------------------------------------------------------------------
// Representa UM filme na lista: Card + ListTile + avatar com a sigla do título
// + botões de editar e remover. Recebe callbacks para não acoplar à HomePage.
// =============================================================================
import 'package:flutter/material.dart';
import '../../models/filme_model.dart';

class FilmeCard extends StatelessWidget {
  final FilmeModel filme;
  final VoidCallback onRemover;
  final VoidCallback onEditar;

  const FilmeCard({
    super.key,
    required this.filme,
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
            siglaTitulo(filme.titulo),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        title: Text(
          filme.titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${filme.diretor} • ${filme.genero} • ${filme.ano}'),
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

  /// Gera uma sigla curta a partir do título para exibir no avatar.
  /// Ex.: "Cidade de Deus" -> "CD" (artigos e preposições são ignorados);
  ///      "Matrix"         -> "MA" (título de uma palavra usa 2 letras).
  static String siglaTitulo(String titulo) {
    const conectores = {'de', 'da', 'do', 'das', 'dos', 'e', 'a', 'o', 'os',
                        'as', 'em', 'no', 'na', 'um', 'uma', 'the', 'of'};

    final palavras = titulo
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (palavras.isEmpty) return '?';

    // Uma só palavra: usa as duas primeiras letras dela.
    if (palavras.length == 1) {
      final unica = palavras.first;
      return unica.substring(0, unica.length >= 2 ? 2 : 1).toUpperCase();
    }

    // Várias palavras: iniciais das palavras "fortes" (sem artigos/preposições).
    final fortes =
        palavras.where((w) => !conectores.contains(w.toLowerCase())).toList();
    final base = fortes.isEmpty ? palavras : fortes;
    return base.map((w) => w[0].toUpperCase()).take(3).join();
  }
}
