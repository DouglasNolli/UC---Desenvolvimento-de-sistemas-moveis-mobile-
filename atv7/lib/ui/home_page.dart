// =============================================================================
// TELA PRINCIPAL — HomePage
// -----------------------------------------------------------------------------
// Orquestra a UI: dispara a leitura do banco (Future) e a desenha com
// FutureBuilder, abre o formulário, filtra a busca e remove registros.
// Toda persistência é delegada ao FilmeRepository — a tela não conhece SQL.
//
// Além disso, esta tela LÊ e GRAVA a nova preferência (último termo de busca):
// abre já filtrada pelo termo da sessão anterior e salva cada alteração do
// campo de pesquisa via BuscaPreferences.
// =============================================================================
import 'package:flutter/material.dart';

import '../data/busca_preferences.dart';
import '../data/filme_repository.dart';
import '../data/i_filme_repository.dart';
import '../models/filme_model.dart';
import 'widgets/empty_state.dart';
import 'widgets/filme_card.dart';
import 'widgets/filme_form.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final Future<void> Function() onAlternarTema;

  /// Termo de busca restaurado do SharedPreferences (vem do main()).
  final String termoBuscaInicial;

  /// Repositório injetável. Em produção usa o SQLite; em testes, um fake.
  final IFilmeRepository? repository;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onAlternarTema,
    this.termoBuscaInicial = '',
    this.repository,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final IFilmeRepository _repository =
      widget.repository ?? FilmeRepository();

  // Wrapper da nova preferência (mesmo padrão do ThemePreferences).
  final BuscaPreferences _buscaPrefs = BuscaPreferences();

  // O Future observado pelo FutureBuilder. Trocá-lo força uma releitura.
  late Future<List<FilmeModel>> _futureFilmes;

  late String _termoBusca;
  late final TextEditingController _buscaController;

  /// True enquanto o filtro exibido ainda for o que veio do disco. Serve apenas
  /// para mostrar o aviso "busca restaurada" e provar a persistência na tela.
  late bool _buscaRestaurada;

  @override
  void initState() {
    super.initState();
    // A tela JÁ NASCE com o último termo pesquisado pelo usuário.
    _termoBusca = widget.termoBuscaInicial;
    _buscaController = TextEditingController(text: widget.termoBuscaInicial);
    _buscaRestaurada = widget.termoBuscaInicial.trim().isNotEmpty;

    _futureFilmes = _repository.getAll(); // primeira leitura
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  /// Reatribui o Future -> o FutureBuilder relê o banco.
  void _recarregar() {
    // IMPORTANTE: usar corpo de bloco `{ }` e NÃO `=>`.
    // Com arrow (`=> _futureFilmes = ...`) o callback RETORNA o valor da
    // atribuição (um Future), e o setState rejeita callbacks que retornam
    // Future — lançando exceção e deixando de aplicar a atualização.
    setState(() {
      _futureFilmes = _repository.getAll();
    });
  }

  /// Atualiza o filtro na tela E persiste o termo no SharedPreferences.
  Future<void> _aplicarBusca(String termo) async {
    setState(() {
      _termoBusca = termo;
      _buscaRestaurada = false; // o usuário assumiu o controle do campo
    });
    await _buscaPrefs.saveUltimoTermo(termo);
  }

  void _mostrarSnack(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _abrirFormulario() async {
    final novo = await FilmeForm.mostrar(context);
    if (novo == null) return;
    await _repository.insert(novo);
    _mostrarSnack('🎬 "${novo.titulo}" salvo no banco offline.');
    _recarregar();
  }

  /// Abre o formulário em modo EDIÇÃO (pré-preenchido) e aplica o UPDATE.
  Future<void> _editar(FilmeModel filme) async {
    final editado = await FilmeForm.mostrar(context, filme: filme);
    if (editado == null) return;
    await _repository.update(editado);
    _mostrarSnack('✏️ "${editado.titulo}" atualizado no banco offline.');
    _recarregar();
  }

  Future<void> _confirmarRemocao(FilmeModel filme) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover filme?'),
        content:
            Text('Deseja remover "${filme.titulo}" do banco de dados local?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmar == true && filme.id != null) {
      await _repository.delete(filme.id!);
      _mostrarSnack('🗑️ "${filme.titulo}" removido do banco offline.');
      _recarregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primaryContainer,
        // titleSpacing menor + fonte reduzida para o nome caber ao lado do
        // chip mesmo em telas estreitas (sem reticências).
        titleSpacing: 12,
        title: const Text(
          'Minha Cinemateca',
          style: TextStyle(fontSize: 19),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Indicador visual de banco local ativo.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Chip(
              avatar: Icon(Icons.storage,
                  size: 15, color: theme.colorScheme.primary),
              label: const Text('SQLite ativo'),
              labelStyle: const TextStyle(fontSize: 11),
              labelPadding: const EdgeInsets.only(left: 2, right: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          // Alternar tema (persiste no SharedPreferences via callback).
          IconButton(
            tooltip: widget.isDarkMode
                ? 'Mudar para Modo Claro'
                : 'Mudar para Modo Escuro',
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onAlternarTema,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa (filtro em memória sobre o resultado do banco).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por título, diretor, gênero ou ano...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _termoBusca.isNotEmpty
                    ? IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaController.clear();
                          // Limpa também a preferência salva.
                          _aplicarBusca('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _aplicarBusca, // filtra E persiste
            ),
          ),

          // Prova visual da nova preferência: aparece quando o app abre já com
          // o termo da sessão anterior restaurado do disco.
          if (_buscaRestaurada)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Row(
                children: [
                  Icon(Icons.bookmark_added_outlined,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Busca restaurada da última sessão',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),

          // ------------------------------------------------------------------
          // FUTUREBUILDER — leitura assíncrona do banco com seus 4 estados.
          // ------------------------------------------------------------------
          Expanded(
            child: FutureBuilder<List<FilmeModel>>(
              future: _futureFilmes,
              builder: (context, snapshot) {
                // 1) CARREGANDO
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2) ERRO
                if (snapshot.hasError) {
                  return EmptyState(
                    icone: Icons.error_outline,
                    titulo: 'Erro ao ler o banco',
                    subtitulo: '${snapshot.error}',
                  );
                }

                // Filtro de busca em memória.
                final todos = snapshot.data ?? const <FilmeModel>[];
                final termo = _termoBusca.trim().toLowerCase();
                final lista = termo.isEmpty
                    ? todos
                    : todos
                        .where((f) =>
                            f.titulo.toLowerCase().contains(termo) ||
                            f.diretor.toLowerCase().contains(termo) ||
                            f.genero.toLowerCase().contains(termo) ||
                            f.ano.toString().contains(termo))
                        .toList();

                // 3) VAZIO
                if (lista.isEmpty) {
                  return EmptyState(
                    icone: termo.isEmpty
                        ? Icons.movie_filter_outlined
                        : Icons.search_off,
                    titulo: termo.isEmpty
                        ? 'Nenhum filme salvo offline'
                        : 'Nenhum resultado para "$_termoBusca"',
                    subtitulo: termo.isEmpty
                        ? 'Toque no botão + para cadastrar o primeiro.'
                        : null,
                  );
                }

                // 4) COM DADOS
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final filme = lista[index];
                    return FilmeCard(
                      filme: filme,
                      onEditar: () => _editar(filme),
                      onRemover: () => _confirmarRemocao(filme),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Novo filme'),
      ),
    );
  }
}
