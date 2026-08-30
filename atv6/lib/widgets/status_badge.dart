import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

/// Badge reutilizável de status (DRY).
///
/// Usado para o nível das despesas e para rótulos de partido/UF,
/// evitando repetir a mesma decoração em várias telas.
class StatusBadge extends StatelessWidget {
  final String texto;
  final Color cor;
  final IconData? icone;

  const StatusBadge({super.key, required this.texto, required this.cor, this.icone});

  /// Atalho para o nível de uma despesa (Alto / Médio / Baixo).
  factory StatusBadge.nivelDespesa(String nivel) => StatusBadge(
        texto: nivel,
        cor: AppTheme.corPorNivel(nivel),
        icone: Icons.paid_outlined,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusPequeno),
        border: Border.all(color: cor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 13, color: cor),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cor),
          ),
        ],
      ),
    );
  }
}
