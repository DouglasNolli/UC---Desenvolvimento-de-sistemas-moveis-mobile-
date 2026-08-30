import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/favoritos_dao.dart';
import '../models/deputado.dart';
import '../models/despesa.dart';
import '../models/proposicao.dart';
import '../services/camara_service.dart';
import '../themes/app_theme.dart';
import '../widgets/despesa_tile.dart';
import '../widgets/estado_view.dart';
import '../widgets/status_badge.dart';

/// Tela de detalhes do parlamentar — recebe um [Deputado] tipado.
///
/// Exibe, em abas, as despesas da cota parlamentar e as proposições
/// de autoria do deputado, ambas carregadas no `initState()`.
class DeputadoDetalheView extends StatefulWidget {
  final Deputado deputado;

  const DeputadoDetalheView({super.key, required this.deputado});

  @override
  State<DeputadoDetalheView> createState() => _DeputadoDetalheViewState();
}

class _DeputadoDetalheViewState extends State<DeputadoDetalheView>
    with SingleTickerProviderStateMixin {
  final CamaraService _service = CamaraService();
  final FavoritosDao _dao = FavoritosDao.instancia;

  late final TabController _tabController;
  final NumberFormat _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  List<Despesa> _despesas = const [];
  List<Proposicao> _proposicoes = const [];
  bool _carregando = true;
  bool _favorito = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarDados();
  }

  @override
  void dispose() {
    // Liberação explícita do TabController e do cliente HTTP.
    _tabController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    final bool favorito = await _dao.ehFavorito(widget.deputado.id);
    try {
      // Requisições paralelas reduzem o tempo de espera do cidadão.
      final List<dynamic> resultados = await Future.wait([
        _service.buscarDespesas(widget.deputado),
        _service.buscarProposicoes(widget.deputado.id),
      ]);
      if (!mounted) return;
      setState(() {
        _despesas = resultados[0] as List<Despesa>;
        _proposicoes = resultados[1] as List<Proposicao>;
        _favorito = favorito;
        _carregando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _favorito = favorito;
        _carregando = false;
      });
    }
  }

  Future<void> _alternarFavorito() async {
    final bool favoritado = await _dao.alternar(widget.deputado);
    if (!mounted) return;
    setState(() => _favorito = favoritado);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(favoritado
            ? 'Perfil salvo para consulta offline.'
            : 'Perfil removido dos favoritos.'),
      ),
    );
  }

  double get _totalGasto =>
      _despesas.fold(0.0, (soma, despesa) => soma + despesa.valorLiquido);

  @override
  Widget build(BuildContext context) {
    final Deputado deputado = widget.deputado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Parlamentar'),
        actions: [
          IconButton(
            tooltip: _favorito ? 'Remover dos favoritos' : 'Salvar offline',
            onPressed: _alternarFavorito,
            icon: Icon(_favorito ? Icons.star : Icons.star_border),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Despesas'),
            Tab(text: 'Proposições'),
          ],
        ),
      ),
      body: Column(
        children: [
          _cabecalho(deputado),
          Expanded(child: _corpo()),
        ],
      ),
    );
  }

  Widget _cabecalho(Deputado deputado) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.espacamentoPadrao),
      color: Theme.of(context).cardTheme.color,
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            foregroundImage:
                deputado.urlFoto != null ? NetworkImage(deputado.urlFoto!) : null,
            child: const Icon(Icons.person),
          ),
          const SizedBox(width: AppTheme.espacamentoPadrao),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deputado.nome,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${deputado.siglaPartido} • ${deputado.siglaUf}',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                if (!_carregando && _erro == null)
                  StatusBadge(
                    texto: 'Total: ${_moeda.format(_totalGasto)}',
                    cor: AppTheme.corAlto,
                    icone: Icons.receipt_long,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _corpo() {
    if (_carregando) return EstadoView.carregando('Buscando gastos e proposições...');

    if (_erro != null) {
      return EstadoView(
        icone: Icons.wifi_off,
        mensagem: _erro!,
        aoTentarNovamente: _carregarDados,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [_abaDespesas(), _abaProposicoes()],
    );
  }

  Widget _abaDespesas() {
    if (_despesas.isEmpty) {
      return const EstadoView(
        icone: Icons.receipt_long,
        mensagem: 'Nenhuma despesa registrada para este parlamentar.',
      );
    }

    // ListView.builder: reciclagem de memória para grandes volumes.
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.espacamentoPadrao),
      itemCount: _despesas.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.espacamentoPequeno),
        child: DespesaTile(despesa: _despesas[index]),
      ),
    );
  }

  Widget _abaProposicoes() {
    if (_proposicoes.isEmpty) {
      return const EstadoView(
        icone: Icons.gavel,
        mensagem: 'Nenhuma proposição de autoria encontrada.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.espacamentoPadrao),
      itemCount: _proposicoes.length,
      itemBuilder: (context, index) {
        final Proposicao proposicao = _proposicoes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.espacamentoPequeno),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.gavel),
              title: Text(proposicao.identificacao),
              subtitle: Text(
                proposicao.ementa,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }
}
