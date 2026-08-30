import 'package:flutter/material.dart';

import '../models/deputado.dart';
import '../themes/app_theme.dart';
import 'status_badge.dart';

/// Card reutilizável de político (DRY).
///
/// Usado tanto na listagem principal quanto na tela de favoritos,
/// sempre dentro de um `ListView.builder` (lazy loading).
class DeputadoCard extends StatelessWidget {
  final Deputado deputado;
  final bool favorito;
  final VoidCallback onTap;
  final VoidCallback onFavoritar;

  const DeputadoCard({
    super.key,
    required this.deputado,
    required this.favorito,
    required this.onTap,
    required this.onFavoritar,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusPadrao),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.espacamentoPequeno + 4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: cores.primary.withValues(alpha: 0.12),
                foregroundImage:
                    deputado.urlFoto != null ? NetworkImage(deputado.urlFoto!) : null,
                child: Icon(Icons.person, color: cores.primary),
              ),
              const SizedBox(width: AppTheme.espacamentoPadrao),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deputado.nome,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StatusBadge(
                          texto: deputado.siglaPartido,
                          cor: cores.primary,
                          icone: Icons.flag_outlined,
                        ),
                        const SizedBox(width: 6),
                        StatusBadge(
                          texto: deputado.siglaUf,
                          cor: AppTheme.corSecundaria,
                          icone: Icons.place_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: favorito ? 'Remover dos favoritos' : 'Salvar offline',
                onPressed: onFavoritar,
                icon: Icon(
                  favorito ? Icons.star : Icons.star_border,
                  color: favorito ? AppTheme.corSecundaria : cores.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
