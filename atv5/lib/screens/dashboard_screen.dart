import 'package:flutter/material.dart';

import '../models/sensor_model.dart';
import '../themes/app_theme.dart';
import '../widgets/action_button.dart';
import '../widgets/sensor_card.dart';
import 'logs_screen.dart';

/// Tela 2 — Dashboard de Sensores.
///
/// Exibe os sensores monitorados dinamicamente através de um
/// [GridView.builder], demonstrando renderização eficiente de listas.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// Gera a lista simulada de sensores da máquina.
  List<SensorModel> _gerarSensores() {
    return const [
      SensorModel(
        id: 1,
        nome: 'Temperatura',
        valor: 78.4,
        unidade: '°C',
        status: 'Crítico',
        icone: Icons.thermostat,
      ),
      SensorModel(
        id: 2,
        nome: 'Pressão',
        valor: 4.2,
        unidade: 'bar',
        status: 'Normal',
        icone: Icons.speed,
      ),
      SensorModel(
        id: 3,
        nome: 'Vibração',
        valor: 3.8,
        unidade: 'mm/s',
        status: 'Alerta',
        icone: Icons.vibration,
      ),
      SensorModel(
        id: 4,
        nome: 'Velocidade',
        valor: 1450,
        unidade: 'RPM',
        status: 'Normal',
        icone: Icons.autorenew,
      ),
      SensorModel(
        id: 5,
        nome: 'Corrente',
        valor: 12.6,
        unidade: 'A',
        status: 'Normal',
        icone: Icons.electrical_services,
      ),
      SensorModel(
        id: 6,
        nome: 'Tensão',
        valor: 219.8,
        unidade: 'V',
        status: 'Alerta',
        icone: Icons.bolt,
      ),
      SensorModel(
        id: 7,
        nome: 'Nível de Óleo',
        valor: 62.0,
        unidade: '%',
        status: 'Normal',
        icone: Icons.oil_barrel,
      ),
      SensorModel(
        id: 8,
        nome: 'Umidade',
        valor: 45.3,
        unidade: '%',
        status: 'Info',
        icone: Icons.water_drop_outlined,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sensores = _gerarSensores();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard de Sensores')),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.espacamentoPadrao),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitoramento em Tempo Real',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${sensores.length} sensores ativos',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.espacamentoPadrao),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsividade: ajusta o número de colunas conforme
                  // a largura disponível da tela.
                  final int colunas = constraints.maxWidth >= 900
                      ? 4
                      : constraints.maxWidth >= 600
                          ? 3
                          : 2;

                  return GridView.builder(
                    itemCount: sensores.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: colunas,
                      crossAxisSpacing: AppTheme.espacamentoPadrao,
                      mainAxisSpacing: AppTheme.espacamentoPadrao,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      return SensorCard(sensor: sensores[index]);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.espacamentoPadrao),
            ActionButton(
              label: 'Ver Histórico de Ocorrências',
              icon: Icons.list_alt,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LogsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
