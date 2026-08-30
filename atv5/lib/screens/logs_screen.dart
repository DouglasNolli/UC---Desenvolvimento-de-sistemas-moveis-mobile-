import 'package:flutter/material.dart';

import '../models/ocorrencia_model.dart';
import '../themes/app_theme.dart';
import '../widgets/action_button.dart';
import 'filtro_screen.dart';

/// Tela 3 — Histórico de Logs de Ocorrência.
///
/// Demonstra:
/// * Loading simulado com [CircularProgressIndicator] e [Future.delayed]
/// * Ciclo de vida com [initState] e verificação de [mounted]
/// * [ListView.builder] performático para grandes listas
/// * [setState] para alteração individual de itens
/// * Navegação assíncrona com `await` + [Navigator.pop] para o filtro
/// * [SnackBar] informando o filtro aplicado
class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  bool _carregando = true;

  // Lista original (fonte da verdade) e lista exibida (após filtro).
  List<OcorrenciaModel> _todasOcorrencias = [];
  List<OcorrenciaModel> _ocorrenciasExibidas = [];

  String _filtroAtual = 'Todos';

  @override
  void initState() {
    super.initState();
    _carregarOcorrencias();
  }

  /// Simula uma requisição/carregamento de dados de aproximadamente
  /// 2 segundos antes de exibir o histórico de ocorrências.
  Future<void> _carregarOcorrencias() async {
    await Future.delayed(const Duration(seconds: 2));

    // Evita chamar setState caso a tela já tenha sido destruída
    // enquanto o Future estava em execução.
    if (!mounted) return;

    setState(() {
      _todasOcorrencias = _gerarOcorrencias();
      _ocorrenciasExibidas = List.of(_todasOcorrencias);
      _carregando = false;
    });
  }

  /// Gera 50 ocorrências simuladas, distribuídas entre as gravidades
  /// Crítico, Alerta e Info, com títulos e descrições realistas para um
  /// sistema de supervisão industrial.
  List<OcorrenciaModel> _gerarOcorrencias() {
    const List<Map<String, String>> modelos = [
      {'titulo': 'Alta temperatura no motor', 'descricao': 'Temperatura acima do limite operacional.', 'gravidade': 'Crítico'},
      {'titulo': 'Pressão hidráulica abaixo do limite', 'descricao': 'Pressão do circuito hidráulico insuficiente.', 'gravidade': 'Crítico'},
      {'titulo': 'Sobrecarga detectada', 'descricao': 'Corrente elétrica acima do valor nominal.', 'gravidade': 'Crítico'},
      {'titulo': 'Sensor desconectado', 'descricao': 'Falha de comunicação com o sensor de vibração.', 'gravidade': 'Crítico'},
      {'titulo': 'Parada de emergência acionada', 'descricao': 'Botão de emergência pressionado na linha 2.', 'gravidade': 'Crítico'},
      {'titulo': 'Vibração acima do normal', 'descricao': 'Nível de vibração excede o limite de segurança.', 'gravidade': 'Alerta'},
      {'titulo': 'Manutenção preventiva necessária', 'descricao': 'Ciclo de horas de uso próximo do limite.', 'gravidade': 'Alerta'},
      {'titulo': 'Nível de óleo baixo', 'descricao': 'Reservatório de óleo abaixo de 30%.', 'gravidade': 'Alerta'},
      {'titulo': 'Rotação instável', 'descricao': 'Variação incomum na velocidade do motor.', 'gravidade': 'Alerta'},
      {'titulo': 'Temperatura ambiente elevada', 'descricao': 'Temperatura da sala de máquinas acima do ideal.', 'gravidade': 'Alerta'},
      {'titulo': 'Tensão estabilizada', 'descricao': 'Tensão da rede retornou ao valor nominal.', 'gravidade': 'Info'},
      {'titulo': 'Ciclo de produção concluído', 'descricao': 'Lote de produção finalizado com sucesso.', 'gravidade': 'Info'},
      {'titulo': 'Sensor reconectado', 'descricao': 'Comunicação com o sensor restabelecida.', 'gravidade': 'Info'},
      {'titulo': 'Backup de dados realizado', 'descricao': 'Backup automático do sistema concluído.', 'gravidade': 'Info'},
      {'titulo': 'Início de turno registrado', 'descricao': 'Operador iniciou o turno na estação 3.', 'gravidade': 'Info'},
    ];

    return List.generate(50, (index) {
      final modelo = modelos[index % modelos.length];
      return OcorrenciaModel(
        id: index + 1,
        titulo: modelo['titulo']!,
        descricao: modelo['descricao']!,
        gravidade: modelo['gravidade']!,
        dataHora: DateTime.now().subtract(Duration(minutes: index * 7)),
      );
    });
  }

  /// Reconstrói a lista exibida a partir da lista original, aplicando
  /// o filtro de gravidade selecionado. Evita aplicar filtros
  /// sucessivos sobre uma lista já filtrada.
  void _aplicarFiltro(String filtro) {
    setState(() {
      _filtroAtual = filtro;
      _ocorrenciasExibidas = filtro == 'Todos'
          ? List.of(_todasOcorrencias)
          : _todasOcorrencias
              .where((ocorrencia) => ocorrencia.gravidade == filtro)
              .toList();
    });
  }

  /// Abre a tela de filtro e aguarda o retorno do valor selecionado.
  Future<void> _abrirFiltro() async {
    final filtroSelecionado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const FiltroScreen()),
    );

    if (filtroSelecionado != null) {
      _aplicarFiltro(filtroSelecionado);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exibindo apenas logs do tipo: $filtroSelecionado'),
        ),
      );
    }
  }

  /// Alterna o estado de reconhecimento de uma ocorrência específica,
  /// alterando apenas aquele item da lista.
  void _alternarReconhecimento(OcorrenciaModel ocorrencia) {
    setState(() {
      ocorrencia.reconhecida = !ocorrencia.reconhecida;
    });
  }

  IconData _iconePorGravidade(String gravidade) {
    switch (gravidade) {
      case 'Crítico':
        return Icons.error;
      case 'Alerta':
        return Icons.warning_amber;
      default:
        return Icons.info;
    }
  }

  String _formatarDataHora(DateTime dataHora) {
    final data = '${dataHora.day.toString().padLeft(2, '0')}/'
        '${dataHora.month.toString().padLeft(2, '0')}';
    final hora = '${dataHora.hour.toString().padLeft(2, '0')}:'
        '${dataHora.minute.toString().padLeft(2, '0')}';
    return '$data às $hora';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Ocorrências')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppTheme.espacamentoPadrao),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_ocorrenciasExibidas.length} ocorrências '
                        '(filtro: $_filtroAtual)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.espacamentoPequeno),
                  Expanded(
                    child: _ocorrenciasExibidas.isEmpty
                        ? const Center(
                            child: Text('Nenhuma ocorrência encontrada.'),
                          )
                        : ListView.builder(
                            itemCount: _ocorrenciasExibidas.length,
                            itemBuilder: (context, index) {
                              final ocorrencia = _ocorrenciasExibidas[index];
                              final Color cor = AppTheme.corPorStatus(
                                ocorrencia.gravidade,
                              );

                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: AppTheme.espacamentoPequeno,
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusPadrao,
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: cor.withOpacity(0.15),
                                    child: Icon(
                                      ocorrencia.reconhecida
                                          ? Icons.check
                                          : _iconePorGravidade(
                                              ocorrencia.gravidade,
                                            ),
                                      color: cor,
                                    ),
                                  ),
                                  title: Text(
                                    ocorrencia.titulo,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: ocorrencia.reconhecida
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: Text(
                                    ocorrencia.reconhecida
                                        ? 'Ocorrência reconhecida • '
                                            '${_formatarDataHora(ocorrencia.dataHora)}'
                                        : '${ocorrencia.descricao}\n'
                                            '${_formatarDataHora(ocorrencia.dataHora)}',
                                  ),
                                  isThreeLine: !ocorrencia.reconhecida,
                                  trailing: IconButton(
                                    icon: Icon(
                                      ocorrencia.reconhecida
                                          ? Icons.check_circle
                                          : Icons.check_circle_outline,
                                      color: ocorrencia.reconhecida
                                          ? AppTheme.corNormal
                                          : AppTheme.corTextoSecundario,
                                    ),
                                    tooltip: 'Reconhecer alarme',
                                    onPressed: () =>
                                        _alternarReconhecimento(ocorrencia),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: AppTheme.espacamentoPadrao),
                  ActionButton(
                    label: 'Filtrar por Gravidade',
                    icon: Icons.filter_list,
                    onPressed: _abrirFiltro,
                  ),
                ],
              ),
            ),
    );
  }
}
