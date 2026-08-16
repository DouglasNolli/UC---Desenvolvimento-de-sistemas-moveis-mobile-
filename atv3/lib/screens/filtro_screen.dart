import 'package:flutter/material.dart';
import '../models/filtro_model.dart';

class FiltroScreen extends StatefulWidget {
  final FiltroModel filtro;

  const FiltroScreen({
    super.key,
    required this.filtro,
  });

  @override
  State<FiltroScreen> createState() => _FiltroScreenState();
}

class _FiltroScreenState extends State<FiltroScreen> {
  late String statusSelecionado;
  late String veiculoSelecionado;
  late String prioridadeSelecionada;

  final List<String> status = [
    'Todos',
    'Pendente',
    'Em andamento',
    'Concluída',
  ];

  final List<String> veiculos = [
    'Todos',
    'VE-001',
    'VE-002',
    'VE-003',
  ];

  final List<String> prioridades = [
    'Todas',
    'Baixa',
    'Média',
    'Alta',
  ];

  @override
  void initState() {
    super.initState();

    statusSelecionado = widget.filtro.status;
    veiculoSelecionado = widget.filtro.veiculo;
    prioridadeSelecionada = widget.filtro.prioridade;
  }

  void aplicarFiltros() {
    final FiltroModel novoFiltro = FiltroModel(
      status: statusSelecionado,
      veiculo: veiculoSelecionado,
      prioridade: prioridadeSelecionada,
    );

    Navigator.pop(context, novoFiltro);
  }

  void cancelar() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar ordens de serviço',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Selecione os parâmetros para pesquisa.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: statusSelecionado,
                isExpanded: true,
                underline: const SizedBox(),
                items: status.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      statusSelecionado = valor;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Veículo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: veiculoSelecionado,
                isExpanded: true,
                underline: const SizedBox(),
                items: veiculos.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      veiculoSelecionado = valor;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Prioridade',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: prioridadeSelecionada,
                isExpanded: true,
                underline: const SizedBox(),
                items: prioridades.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      prioridadeSelecionada = valor;
                    });
                  }
                },
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: cancelar,
                    child: const Text('Cancelar'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: aplicarFiltros,
                    child: const Text('Aplicar filtros'),
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