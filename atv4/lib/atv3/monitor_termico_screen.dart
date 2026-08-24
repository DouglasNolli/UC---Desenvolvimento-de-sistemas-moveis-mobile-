import 'dart:async';
import 'package:flutter/material.dart';

/// ATV3 - O Guardião de Memória
///
/// O Timer.periodic criado em initState() é cancelado em dispose(),
/// evitando que o "polling" simulado continue rodando após a tela fechar.
class MonitorTermicoScreen extends StatefulWidget {
  const MonitorTermicoScreen({super.key});

  @override
  State<MonitorTermicoScreen> createState() => _MonitorTermicoScreenState();
}

class _MonitorTermicoScreenState extends State<MonitorTermicoScreen> {
  Timer? _timerTelemetria;
  double _temperaturaWEG = 45.0;

  @override
  void initState() {
    super.initState();
    _timerTelemetria = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _temperaturaWEG = 45.0 + (timer.tick % 5) * 0.4;
      });
      debugPrint(
          "[SISTEMA ATIVO] Monitorando temperatura em tempo real: $_temperaturaWEG°C");
    });
  }

  @override
  void dispose() {
    _timerTelemetria?.cancel();
    debugPrint("[HIGIENE DE MEMÓRIA] Timer de telemetria destruído com sucesso. Recursos liberados!");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitor Térmico"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.thermostat, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              "Sensor Motor Principal (WEG)",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              "${_temperaturaWEG.toStringAsFixed(1)} °C",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Instrução técnica: Abra o console do terminal enquanto navega. "
                "Volte para a tela anterior e veja que os prints cessaram "
                "instantaneamente. Isso prova que o método dispose() limpou a memória.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}
