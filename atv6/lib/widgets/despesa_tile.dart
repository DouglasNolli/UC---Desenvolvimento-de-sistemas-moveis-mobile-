import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/despesa.dart';
import '../themes/app_theme.dart';
import 'status_badge.dart';

/// Item reutilizável de despesa, renderizado pelo `ListView.builder`.
class DespesaTile extends StatelessWidget {
  final Despesa despesa;

  const DespesaTile({super.key, required this.despesa});

  static final NumberFormat _moeda =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final DateFormat _data = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    // Registros históricos podem não ter data de documento (null safety).
    final String dataFormatada = despesa.dataDocumento != null
        ? _data.format(despesa.dataDocumento!)
        : '${despesa.mes.toString().padLeft(2, '0')}/${despesa.ano}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.espacamentoPadrao),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    despesa.tipoDespesa,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppTheme.espacamentoPequeno),
                StatusBadge.nivelDespesa(despesa.nivel),
              ],
            ),
            const SizedBox(height: 6),
            Text(despesa.fornecedor, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppTheme.espacamentoPequeno),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dataFormatada, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  _moeda.format(despesa.valorLiquido),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.corPorNivel(despesa.nivel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
