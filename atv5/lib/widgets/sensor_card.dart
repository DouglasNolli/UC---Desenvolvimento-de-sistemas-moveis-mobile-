import 'package:flutter/material.dart';

import '../models/sensor_model.dart';
import '../themes/app_theme.dart';

/// Widget reutilizável que exibe os dados de um [SensorModel].
///
/// Utilizado pelo [GridView.builder] do Dashboard para renderizar
/// dinamicamente cada sensor monitorado.
class SensorCard extends StatelessWidget {
  final SensorModel sensor;

  const SensorCard({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    final Color corStatus = AppTheme.corPorStatus(sensor.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.espacamentoPadrao),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.espacamentoPequeno),
                  decoration: BoxDecoration(
                    color: corStatus.withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusPequeno),
                  ),
                  child: Icon(sensor.icone, color: corStatus, size: 26),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: corStatus,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.espacamentoPequeno),
            Text(
              sensor.nome,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                text: sensor.valor.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.corTextoPrincipal,
                ),
                children: [
                  TextSpan(
                    text: ' ${sensor.unidade}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sensor.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: corStatus,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
