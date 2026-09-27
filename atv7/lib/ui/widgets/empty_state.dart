// =============================================================================
// WIDGET — EmptyState
// -----------------------------------------------------------------------------
// Estado visual amigável para quando não há registros (ou nenhum resultado de
// busca). Extraído em widget próprio para manter a HomePage enxuta.
// =============================================================================
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? subtitulo;

  const EmptyState({
    super.key,
    required this.icone,
    required this.titulo,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 72, color: theme.colorScheme.primary.withAlpha(153)),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitulo!,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
