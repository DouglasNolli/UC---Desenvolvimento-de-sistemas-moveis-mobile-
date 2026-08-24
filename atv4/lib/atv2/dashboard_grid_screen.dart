import 'package:flutter/material.dart';

/// ATV2 - O Dashboard em Grade
///
/// GridView.builder + SliverGridDelegateWithFixedCrossAxisCount exibindo
/// nome, valor e status (ativo/inativo) de cada sensor industrial.

class SensorModel {
  final String nome;
  final String valor;
  final bool statusAtivo;

  SensorModel({
    required this.nome,
    required this.valor,
    required this.statusAtivo,
  });
}

class DashboardGridScreen extends StatelessWidget {
  final List<SensorModel> sensores = [
    SensorModel(nome: "Temperatura Motor A (WEG)", valor: "74.5°C", statusAtivo: true),
    SensorModel(nome: "Pressão Caldeira 02", valor: "12.4 Bar", statusAtivo: true),
    SensorModel(nome: "Vibração Tear Malwee", valor: "0.2 mm/s", statusAtivo: false),
    SensorModel(nome: "Consumo KWh Painel 3", valor: "450 KWh", statusAtivo: true),
    SensorModel(nome: "Fluxo Entrada Hidráulica", valor: "15 L/min", statusAtivo: true),
    SensorModel(nome: "Nível Solução Química", valor: "15%", statusAtivo: false),
  ];

  DashboardGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Telemetria Industrial - Sensores"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 1.1,
          ),
          itemCount: sensores.length,
          itemBuilder: (context, index) {
            final sensor = sensores[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.sensors, color: Colors.blue),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: sensor.statusAtivo ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        )
                      ],
                    ),
                    const Spacer(),
                    Text(
                      sensor.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sensor.valor,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
