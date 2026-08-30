import 'dart:async';

import 'package:flutter/material.dart';

import '../database/favoritos_dao.dart';
import '../models/deputado.dart';
import '../models/filtro_deputados.dart';
import '../services/camara_service.dart';
import '../themes/app_theme.dart';
import '../widgets/deputado_card.dart';
import '../widgets/estado_view.dart';
import 'deputado_detalhe_view.dart';
import 'favoritos_view.dart';
import 'filtro_view.dart';

/// Tela principal — listagem de parlamentares em exercício.
///
/// Consome a API da Câmara no `initState()`, exibe loader durante o
/// processamento e renderiza os resultados com `ListView.builder`.
class HomeView extends StatefulWidget {
  /// Notificador do tema, controlado pelo widget raiz do app.
  final ValueNotifier<ThemeMode> temaNotifier;

  const HomeView({super.key, required this.temaNotifier});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final CamaraService _service = CamaraService();
  final FavoritosDao _dao = FavoritosDao.instancia;
  final TextEditingController _buscaController = TextEditingController();

  Timer? _debounce;
  List<Deputado> _deputados = const [];
  Set<int> _idsFavoritos = const {};
  FiltroDeputados _filtro = const FiltroDeputados.vazio();
  bool _carregando = true;
  String? _erro;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    // Requisição disparada no ciclo de vida inicial da tela.
    _carregarDeputados();
  }

  @override
  void dispose() {
    // Limpeza explícita: controller, timer de debounce e cliente HTTP.
    _debounce?.cancel();
    _buscaController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _carregarDeputados() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final List<Deputado> lista = await _service.buscarDeputados(_filtro);
      final Set<int> favoritos = await _dao.listarIds();
      if (!mounted) return; // Evita setState após a tela ser destruída.
      setState(() {
        _deputados = lista;
        _idsFavoritos = favoritos;
        _carregando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    }
  }

  /// Busca local por nome, com debounce para não reconstruir a lista a cada tecla.
  void _aoDigitar(String valor) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _busca = valor.toLowerCase());
    });
  }

  Future<void> _abrirFiltros() async {
    // Navegação com objeto tipado: recebe de volta um FiltroDeputados.
    final FiltroDeputados? novo = await Navigator.push<FiltroDeputados>(
      context,
      MaterialPageRoute(
        builder: (_) => FiltroView(filtroAtual: _filtro, service: _service),
      ),
    );
    if (novo == null || !mounted) return;
    setState(() => _filtro = novo);
    _carregarDeputados();
  }

  Future<void> _alternarFavorito(Deputado deputado) async {
    final bool favoritado = await _dao.alternar(deputado);
    if (!mounted) return;
    setState(() {
      _idsFavoritos = {..._idsFavoritos};
      favoritado ? _idsFavoritos.add(deputado.id) : _idsFavoritos.remove(deputado.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(favoritado
            ? '${deputado.nome} salvo para consulta offline.'
            : '${deputado.nome} removido dos favoritos.'),
      ),
    );
  }

  List<Deputado> get _listaFiltrada => _busca.isEmpty
      ? _deputados
      : _deputados.where((d) => d.nome.toLowerCase().contains(_busca)).toList();

  @override
  Widget build(BuildContext context) {
    final bool escuro = widget.temaNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Cidadão'),
        actions: [
          IconButton(
            tooltip: 'Alternar tema',
            onPressed: () => widget.temaNotifier.value =
                escuro ? ThemeMode.light : ThemeMode.dark,
            icon: Icon(escuro ? Icons.light_mode : Icons.dark_mode),
          ),
          IconButton(
            tooltip: 'Favoritos offline',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritosView()),
              );
              if (!mounted) return;
              final Set<int> ids = await _dao.listarIds();
              if (mounted) setState(() => _idsFavoritos = ids);
            },
            icon: const Icon(Icons.star),
          ),
          IconButton(
            tooltip: 'Filtrar',
            onPressed: _abrirFiltros,
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.espacamentoPadrao),
            child: Column(
              children: [
                TextField(
                  controller: _buscaController,
                  onChanged: _aoDigitar,
                  decoration: const InputDecoration(
                    hintText: 'Buscar deputado pelo nome',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: AppTheme.espacamentoPequeno),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _filtro.descricao,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _construirCorpo()),
        ],
      ),
    );
  }

  Widget _construirCorpo() {
    if (_carregando) return EstadoView.carregando('Consultando a Câmara dos Deputados...');

    if (_erro != null) {
      return EstadoView(
        icone: Icons.wifi_off,
        mensagem: _erro!,
        aoTentarNovamente: _carregarDeputados,
      );
    }

    final List<Deputado> lista = _listaFiltrada;
    if (lista.isEmpty) {
      return const EstadoView(
        icone: Icons.search_off,
        mensagem: 'Nenhum deputado encontrado para os critérios informados.',
      );
    }

    // ListView.builder: renderiza apenas os itens visíveis (lazy loading).
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        final Deputado deputado = lista[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.espacamentoPequeno),
          child: DeputadoCard(
            deputado: deputado,
            favorito: _idsFavoritos.contains(deputado.id),
            onFavoritar: () => _alternarFavorito(deputado),
            onTap: () => Navigator.push(
              context,
              // Passagem de dados por objeto tipado (nunca por String).
              MaterialPageRoute(
                builder: (_) => DeputadoDetalheView(deputado: deputado),
              ),
            ),
          ),
        );
      },
    );
  }
}
