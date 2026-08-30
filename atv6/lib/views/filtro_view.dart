import 'package:flutter/material.dart';

import '../models/filtro_deputados.dart';
import '../services/camara_service.dart';
import '../themes/app_theme.dart';
import '../widgets/estado_view.dart';

/// Tela de filtros por estado (UF) e partido.
///
/// Devolve um [FiltroDeputados] tipado via `Navigator.pop` e usa
/// [PopScope] para impedir a perda acidental dos parâmetros escolhidos.
class FiltroView extends StatefulWidget {
  final FiltroDeputados filtroAtual;
  final CamaraService service;

  const FiltroView({super.key, required this.filtroAtual, required this.service});

  @override
  State<FiltroView> createState() => _FiltroViewState();
}

class _FiltroViewState extends State<FiltroView> {
  static const List<String> _ufs = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
    'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC',
    'SP', 'SE', 'TO',
  ];

  late FiltroDeputados _selecao;
  List<String> _partidos = const [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _selecao = widget.filtroAtual;
    _carregarPartidos();
  }

  Future<void> _carregarPartidos() async {
    try {
      final List<String> siglas = await widget.service.buscarSiglasPartidos();
      if (!mounted) return;
      setState(() {
        _partidos = siglas;
        _carregando = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  bool get _temAlteracaoPendente => !_selecao.igualA(widget.filtroAtual);

  /// Confirmação exibida quando o usuário tenta sair sem aplicar o filtro.
  Future<void> _confirmarSaida() async {
    final bool? sair = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Descartar filtros?'),
        content: const Text('Os critérios selecionados ainda não foram aplicados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Continuar editando'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if ((sair ?? false) && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      // Bloqueia o pop enquanto houver seleção não aplicada.
      canPop: !_temAlteracaoPendente,
      onPopInvokedWithResult: (bool saiu, Object? resultado) {
        if (!saiu) _confirmarSaida();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Filtros')),
        body: _carregando
            ? EstadoView.carregando('Carregando partidos...')
            : ListView(
                padding: const EdgeInsets.all(AppTheme.espacamentoPadrao),
                children: [
                  _titulo('Estado (UF)'),
                  _grupoChips(
                    opcoes: _ufs,
                    selecionado: _selecao.uf,
                    aoSelecionar: (valor) => setState(
                      () => _selecao =
                          FiltroDeputados(uf: valor, partido: _selecao.partido),
                    ),
                  ),
                  const SizedBox(height: AppTheme.espacamentoPadrao),
                  _titulo('Partido'),
                  _grupoChips(
                    opcoes: _partidos,
                    selecionado: _selecao.partido,
                    aoSelecionar: (valor) => setState(
                      () => _selecao =
                          FiltroDeputados(uf: _selecao.uf, partido: valor),
                    ),
                  ),
                  const SizedBox(height: AppTheme.espacamentoPadrao),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, _selecao),
                    icon: const Icon(Icons.check),
                    label: const Text('Aplicar filtros'),
                  ),
                  const SizedBox(height: AppTheme.espacamentoPequeno),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, const FiltroDeputados.vazio()),
                    child: const Text('Limpar filtros'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.espacamentoPequeno),
        child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
      );

  /// Grupo de chips selecionáveis reutilizado por UF e Partido (DRY).
  Widget _grupoChips({
    required List<String> opcoes,
    required String? selecionado,
    required ValueChanged<String?> aoSelecionar,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: opcoes.map((opcao) {
        final bool ativo = opcao == selecionado;
        return ChoiceChip(
          label: Text(opcao),
          selected: ativo,
          // Tocar novamente na opção ativa remove o filtro.
          onSelected: (_) => aoSelecionar(ativo ? null : opcao),
        );
      }).toList(),
    );
  }
}
