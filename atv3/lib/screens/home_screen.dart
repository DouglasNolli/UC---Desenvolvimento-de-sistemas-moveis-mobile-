import 'package:flutter/material.dart';
import '../models/filtro_model.dart';
import 'filtro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String mensagem = 'Nenhum filtro aplicado.';

  FiltroModel filtroAtual = FiltroModel(
    status: 'Todos',
    veiculo: 'Todos',
    prioridade: 'Todas',
  );

  final List<Map<String, String>> ordens = [
    {
      'os': 'OS #1024',
      'veiculo': 'VE-001',
      'status': 'Em andamento',
      'prioridade': 'Alta',
    },
    {
      'os': 'OS #1025',
      'veiculo': 'VE-002',
      'status': 'Concluída',
      'prioridade': 'Média',
    },
    {
      'os': 'OS #1026',
      'veiculo': 'VE-003',
      'status': 'Pendente',
      'prioridade': 'Baixa',
    },
  ];

  List<Map<String, String>> get ordensFiltradas {
    return ordens.where((ordem) {
      final bool statusOk =
          filtroAtual.status == 'Todos' ||
          ordem['status'] == filtroAtual.status;

      final bool veiculoOk =
          filtroAtual.veiculo == 'Todos' ||
          ordem['veiculo'] == filtroAtual.veiculo;

      final bool prioridadeOk =
          filtroAtual.prioridade == 'Todas' ||
          ordem['prioridade'] == filtroAtual.prioridade;

      return statusOk && veiculoOk && prioridadeOk;
    }).toList();
  }

  Future<void> abrirFiltros() async {
    final FiltroModel? novoFiltro = await Navigator.push<FiltroModel>(
      context,
      MaterialPageRoute(
        builder: (context) => FiltroScreen(filtro: filtroAtual),
      ),
    );

    if (!mounted) return;

    if (novoFiltro != null) {
      setState(() {
        filtroAtual = novoFiltro;
        mensagem = 'Filtros aplicados com sucesso.';
      });
    } else {
      setState(() {
        mensagem = 'Filtros não alterados.';
      });
    }
  }

  void limparFiltros() {
    setState(() {
      filtroAtual = FiltroModel(
        status: 'Todos',
        veiculo: 'Todos',
        prioridade: 'Todas',
      );

      mensagem = 'Filtros removidos.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final lista = ordensFiltradas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoramento de Frota'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orquestrador de Dados',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Ordens de serviço da frota elétrica',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(mensagem),
            ),

            const SizedBox(height: 15),

            if (filtroAtual.status != 'Todos' ||
                filtroAtual.veiculo != 'Todos' ||
                filtroAtual.prioridade != 'Todas')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtros atuais:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Status: ${filtroAtual.status}'),
                    Text('Veículo: ${filtroAtual.veiculo}'),
                    Text('Prioridade: ${filtroAtual.prioridade}'),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            Expanded(
              child: lista.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma ordem encontrada.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        final ordem = lista[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.electric_car,
                                  size: 40,
                                  color: Colors.blue,
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ordem['os']!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text('Veículo: ${ordem['veiculo']}'),
                                      Text('Status: ${ordem['status']}'),
                                      Text(
                                        'Prioridade: ${ordem['prioridade']}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: limparFiltros,
                    child: const Text('Limpar filtros'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: abrirFiltros,
                    icon: const Icon(Icons.filter_alt),
                    label: const Text('Filtrar'),
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
