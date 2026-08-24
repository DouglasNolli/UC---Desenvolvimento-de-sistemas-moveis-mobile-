import 'package:flutter/material.dart';
import 'atv1/lista_otimizada_screen.dart';
import 'atv2/dashboard_grid_screen.dart';
import 'atv3/monitor_termico_screen.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercícios Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercícios Flutter'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CardExercicio(
            titulo: 'ATV 1 - Otimizador de Listas',
            subtitulo: 'ListView.builder e gerenciamento de memória',
            icone: Icons.list_alt,
            cor: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ListaOtimizadaScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _CardExercicio(
            titulo: 'ATV 2 - Dashboard em Grade',
            subtitulo: 'GridView.builder e responsividade',
            icone: Icons.grid_view,
            cor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DashboardGridScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _CardExercicio(
            titulo: 'ATV 3 - Guardião de Memória',
            subtitulo: 'dispose() e prevenção de memory leaks',
            icone: Icons.thermostat,
            cor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonitorTermicoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CardExercicio extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Color cor;
  final VoidCallback onTap;

  const _CardExercicio({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: cor,
          child: Icon(icone, color: Colors.white),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
