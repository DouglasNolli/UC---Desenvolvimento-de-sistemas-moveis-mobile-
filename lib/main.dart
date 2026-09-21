// =============================================================================
// PORTAL CIDADÃO: POLÍTICOS FAVORITOS (OFFLINE)
// -----------------------------------------------------------------------------
// App de demonstração didática de PERSISTÊNCIA DE DADOS LOCAL em Flutter:
//
//   • SQLite (via pacote `sqflite`)  -> dados estruturados (CRUD de políticos)
//   • SharedPreferences              -> configuração chave-valor (tema do app)
//
// Toda a aplicação foi mantida em UM ÚNICO ARQUIVO (main.dart) para facilitar
// a leitura em sala de aula. Em um projeto real, cada bloco abaixo (model,
// helper de banco, telas) viveria em seu próprio arquivo.
//
// Roteiro de leitura sugerido para os alunos:
//   1) PoliticoModel        -> como mapeamos objeto <-> linha da tabela
//   2) DatabaseHelper        -> Singleton + abertura do banco + CRUD
//   3) main() / MyApp        -> carregamento do tema salvo (SharedPreferences)
//   4) HomePage              -> FutureBuilder desenhando a lista do banco
// =============================================================================

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
// Importamos com prefixo `p` para deixar EXPLÍCITO que `join` vem do pacote
// `path`. Assim evitamos conflito com outras funções e fica didático.
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// 1) MODELO DE DADOS — PoliticoModel
// -----------------------------------------------------------------------------
// Classe IMUTÁVEL (todos os campos são `final`). Ela é a "ponte" entre:
//   - o mundo Dart (objetos que a UI entende)
//   - o mundo SQLite (linhas = Map<String, Object?>)
//
// `toMap()`   -> transforma o objeto em Map para GRAVAR no banco.
// `fromMap()` -> factory que reconstrói o objeto ao LER do banco.
// =============================================================================
class PoliticoModel {
  final int? id; // Nulo antes de inserir; o SQLite gera o valor (AUTOINCREMENT).
  final String nome;
  final String partido;
  final String uf;

  const PoliticoModel({
    this.id,
    required this.nome,
    required this.partido,
    required this.uf,
  });

  /// Converte o objeto em um Map compatível com as colunas da tabela.
  /// As CHAVES do Map devem ser IDÊNTICAS aos nomes das colunas no SQLite.
  Map<String, Object?> toMap() {
    return {
      // Se `id` for null, não o incluímos — deixamos o SQLite gerar via
      // AUTOINCREMENT. Incluir null também funcionaria, mas isto é mais claro.
      if (id != null) 'id': id,
      'nome': nome,
      'partido': partido,
      'uf': uf,
    };
  }

  /// Factory que RECONSTRÓI um PoliticoModel a partir de uma linha do banco.
  /// É o caminho inverso de `toMap()`.
  factory PoliticoModel.fromMap(Map<String, Object?> map) {
    return PoliticoModel(
      id: map['id'] as int?,
      nome: (map['nome'] as String?) ?? '',
      partido: (map['partido'] as String?) ?? '',
      uf: (map['uf'] as String?) ?? '',
    );
  }

  @override
  String toString() => 'PoliticoModel(id: $id, nome: $nome, partido: $partido, uf: $uf)';
}

// =============================================================================
// 2) CAMADA DE ACESSO A DADOS — DatabaseHelper (PADRÃO SINGLETON)
// -----------------------------------------------------------------------------
// Por que Singleton?
//   Abrir o mesmo arquivo de banco várias vezes em paralelo pode CORROMPER o
//   arquivo. O padrão Singleton garante UMA ÚNICA instância do helper e UMA
//   ÚNICA conexão (`Database`) reutilizada em todo o app.
//
// Como conseguimos isso:
//   - Construtor privado:   DatabaseHelper._internal()
//   - Instância estática:   static final instance
//   - Getter assíncrono:    Future<Database> get database  (lazy + cache)
// =============================================================================
class DatabaseHelper {
  // Construtor privado (o `_` torna-o inacessível fora deste arquivo).
  DatabaseHelper._internal();

  // Instância única e estática — SEMPRE a mesma em qualquer ponto do app.
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // Cache da conexão. Nula até a primeira abertura; depois é reutilizada.
  static Database? _database;

  // Metadados do banco centralizados (evita "strings mágicas" espalhadas).
  static const String _dbName = 'portal_cidadao.db';
  static const int _dbVersion = 1;
  static const String tabela = 'politicos';

  /// Getter ASSÍNCRONO do banco.
  /// - Se já existe uma conexão em cache, devolve-a imediatamente.
  /// - Caso contrário, abre (uma única vez) e guarda no cache.
  /// Isso previne múltiplas aberturas simultâneas e corrupção de arquivo.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Abre o arquivo do banco no diretório correto do dispositivo.
  Future<Database> _initDatabase() async {
    // getDatabasesPath() -> caminho padrão de bancos do SO (Android/iOS).
    final String dbPath = await getDatabasesPath();
    // p.join() -> monta o caminho completo com o separador correto do SO.
    final String caminhoCompleto = p.join(dbPath, _dbName);

    return openDatabase(
      caminhoCompleto,
      version: _dbVersion,
      onCreate: _onCreate, // chamado apenas na PRIMEIRA vez (banco novo).
    );
  }

  /// Cria a estrutura (schema) do banco na primeira execução.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tabela (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        partido TEXT NOT NULL,
        uf TEXT NOT NULL
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // OPERAÇÕES CRUD
  // ---------------------------------------------------------------------------

  /// CREATE — insere um novo político e retorna o id gerado.
  Future<int> insertPolitico(PoliticoModel politico) async {
    final db = await database;
    return db.insert(
      tabela,
      politico.toMap(),
      // Em caso de conflito de chave, substitui o registro (seguro para demo).
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// READ — lê todos os políticos e mapeia cada linha para um PoliticoModel.
  Future<List<PoliticoModel>> getPoliticos() async {
    final db = await database;
    // Ordenamos por nome para uma listagem previsível.
    final List<Map<String, Object?>> linhas =
        await db.query(tabela, orderBy: 'nome COLLATE NOCASE ASC');

    // Converte a lista de Maps (linhas) em lista de objetos.
    return linhas.map((linha) => PoliticoModel.fromMap(linha)).toList();
  }

  /// DELETE — remove um político pelo id.
  Future<int> deletePolitico(int id) async {
    final db = await database;
    return db.delete(
      tabela,
      where: 'id = ?',
      whereArgs: [id], // whereArgs evita SQL Injection (query parametrizada).
    );
  }
}

// =============================================================================
// 3) CHAVES DO SHAREDPREFERENCES
// -----------------------------------------------------------------------------
// Centralizamos as chaves em constantes para evitar erros de digitação.
// =============================================================================
class PrefsKeys {
  static const String isDarkMode = 'is_dark_mode';
}

// =============================================================================
// 4) PONTO DE ENTRADA — main()
// -----------------------------------------------------------------------------
// Antes de rodar o app, carregamos o TEMA salvo em SharedPreferences.
// `WidgetsFlutterBinding.ensureInitialized()` é obrigatório porque usamos
// código assíncrono (SharedPreferences) ANTES do runApp().
// =============================================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lê a preferência de tema. Se nunca foi salva, assume `false` (Modo Claro).
  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool(PrefsKeys.isDarkMode) ?? false;

  runApp(MyApp(temaInicialEscuro: isDark));
}

// =============================================================================
// 5) WIDGET RAIZ — MyApp
// -----------------------------------------------------------------------------
// Guarda o estado do tema (claro/escuro) e o persiste no SharedPreferences
// toda vez que o usuário alterna pelo botão da AppBar.
// =============================================================================
class MyApp extends StatefulWidget {
  final bool temaInicialEscuro;
  const MyApp({super.key, required this.temaInicialEscuro});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    // Inicializa com o valor lido no main() (vindo do SharedPreferences).
    _isDarkMode = widget.temaInicialEscuro;
  }

  /// Alterna o tema e PERSISTE a escolha no SharedPreferences.
  Future<void> _alternarTema() async {
    setState(() => _isDarkMode = !_isDarkMode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.isDarkMode, _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    // Cor semente compartilhada entre os dois temas para manter identidade.
    const Color seed = Color(0xFF1565C0);

    return MaterialApp(
      title: 'Portal Cidadão',
      debugShowCheckedModeBanner: false,
      // themeMode decide qual dos dois ThemeData abaixo será aplicado.
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      home: HomePage(
        isDarkMode: _isDarkMode,
        onAlternarTema: _alternarTema,
      ),
    );
  }
}

// =============================================================================
// 6) TELA PRINCIPAL — HomePage
// -----------------------------------------------------------------------------
// Responsável por:
//   - Disparar a leitura do banco (Future) e desenhá-la com FutureBuilder.
//   - Abrir o formulário (BottomSheet) para adicionar políticos.
//   - Pesquisar (filtro em memória sobre o resultado do banco).
//   - Remover registros e atualizar a tela com setState().
// =============================================================================
class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final Future<void> Function() onAlternarTema;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onAlternarTema,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Atalho para o Singleton do banco.
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Guarda o Future atual da consulta. Trocá-lo (em _recarregar) força o
  // FutureBuilder a refazer a leitura do banco.
  late Future<List<PoliticoModel>> _futurePoliticos;

  // Texto digitado na barra de pesquisa (filtro aplicado em memória).
  String _termoBusca = '';
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Primeira leitura do banco ao abrir a tela.
    _futurePoliticos = _db.getPoliticos();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  /// Reatribui o Future e chama setState -> o FutureBuilder relê o banco.
  void _recarregar() {
    setState(() {
      _futurePoliticos = _db.getPoliticos();
    });
  }

  /// Mostra um SnackBar de feedback ao usuário.
  void _mostrarSnack(String mensagem, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          behavior: SnackBarBehavior.floating,
          backgroundColor: erro ? Colors.red.shade700 : null,
        ),
      );
  }

  /// Remove um político pelo id e recarrega a lista.
  Future<void> _remover(PoliticoModel politico) async {
    if (politico.id == null) return;
    await _db.deletePolitico(politico.id!);
    _mostrarSnack('🗑️ "${politico.nome}" removido do banco offline.');
    _recarregar();
  }

  /// Abre o formulário (BottomSheet) para cadastrar um novo político.
  Future<void> _abrirFormulario() async {
    final novo = await showModalBottomSheet<PoliticoModel>(
      context: context,
      isScrollControlled: true, // sobe com o teclado.
      showDragHandle: true,
      builder: (_) => const _FormularioPolitico(),
    );

    // Se o usuário confirmou o cadastro, gravamos no banco.
    if (novo != null) {
      await _db.insertPolitico(novo);
      _mostrarSnack('✅ "${novo.nome}" salvo no banco offline.');
      _recarregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // ----------------------------- APP BAR --------------------------------
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primaryContainer,
        title: const Text('Portal Cidadão'),
        actions: [
          // Indicador visual de que o banco local está ativo.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Chip(
              avatar: Icon(Icons.storage,
                  size: 18, color: theme.colorScheme.primary),
              label: const Text('SQLite ativo'),
              visualDensity: VisualDensity.compact,
            ),
          ),
          // Botão de alternar tema — dispara a persistência no SharedPreferences.
          IconButton(
            tooltip: widget.isDarkMode
                ? 'Mudar para Modo Claro'
                : 'Mudar para Modo Escuro',
            icon: Icon(widget.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: widget.onAlternarTema,
          ),
        ],
      ),

      // ------------------------------- CORPO --------------------------------
      body: Column(
        children: [
          // Campo de pesquisa: filtra a lista em memória por nome/partido/UF.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome, partido ou UF...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _termoBusca.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaController.clear();
                          setState(() => _termoBusca = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (valor) => setState(() => _termoBusca = valor),
            ),
          ),

          // -------------------------------------------------------------------
          // FUTUREBUILDER — coração da demonstração de leitura assíncrona.
          // Ele observa o Future `_futurePoliticos` e reconstrói a UI conforme
          // o estado da operação (carregando / erro / vazio / com dados).
          // -------------------------------------------------------------------
          Expanded(
            child: FutureBuilder<List<PoliticoModel>>(
              future: _futurePoliticos,
              builder: (context, snapshot) {
                // ESTADO 1: CARREGANDO -> mostra o indicador de progresso.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ESTADO 2: ERRO -> informa e oferece nova tentativa.
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 56, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text('Erro ao ler o banco: ${snapshot.error}'),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: _recarregar,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                // Dados chegaram. Aplicamos o filtro de pesquisa em memória.
                final todos = snapshot.data ?? const <PoliticoModel>[];
                final termo = _termoBusca.trim().toLowerCase();
                final lista = termo.isEmpty
                    ? todos
                    : todos.where((pol) {
                        return pol.nome.toLowerCase().contains(termo) ||
                            pol.partido.toLowerCase().contains(termo) ||
                            pol.uf.toLowerCase().contains(termo);
                      }).toList();

                // ESTADO 3: VAZIO -> ícone amigável e mensagem.
                if (lista.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          termo.isEmpty
                              ? Icons.smart_toy_outlined // "robozinho" amigável
                              : Icons.search_off,
                          size: 72,
                          // withAlpha (0-255) evita a API depreciada withOpacity.
                          color: theme.colorScheme.primary.withAlpha(153), // ~60%
                        ),
                        const SizedBox(height: 16),
                        Text(
                          termo.isEmpty
                              ? 'Nenhum político salvo offline'
                              : 'Nenhum resultado para "$_termoBusca"',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        if (termo.isEmpty)
                          Text(
                            'Toque no botão + para cadastrar o primeiro.',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  );
                }

                // ESTADO 4: COM DADOS -> ListView.builder com Cards.
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final politico = lista[index];
                    return Card(
                      elevation: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        // Avatar com a sigla do partido.
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          child: Text(
                            _siglaPartido(politico.partido),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          politico.nome,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${politico.partido} • ${politico.uf}'),
                        // Botão de lixeira -> remove e atualiza via setState.
                        trailing: IconButton(
                          tooltip: 'Remover',
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () => _confirmarRemocao(politico),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Botão flutuante para abrir o formulário de cadastro.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Novo político'),
      ),
    );
  }

  /// Diálogo de confirmação antes de remover (evita exclusão acidental).
  Future<void> _confirmarRemocao(PoliticoModel politico) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover político?'),
        content: Text(
            'Deseja remover "${politico.nome}" do banco de dados local?'),
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

    if (confirmar == true) {
      await _remover(politico);
    }
  }

  /// Gera uma sigla curta a partir do nome do partido para o avatar.
  /// Ex.: "Partido Verde" -> "PV"; "PT" -> "PT".
  static String _siglaPartido(String partido) {
    final limpo = partido.trim();
    if (limpo.isEmpty) return '?';
    final palavras =
        limpo.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (palavras.length == 1) {
      // Uma palavra só: usa as duas primeiras letras em maiúsculo.
      final unica = palavras.first;
      return unica.substring(0, unica.length >= 2 ? 2 : 1).toUpperCase();
    }
    // Várias palavras: usa a inicial de cada uma (máx. 3 letras).
    return palavras
        .map((w) => w[0].toUpperCase())
        .take(3)
        .join();
  }
}

// =============================================================================
// 7) FORMULÁRIO DE CADASTRO — _FormularioPolitico (BottomSheet)
// -----------------------------------------------------------------------------
// Widget de formulário com validação. Ao confirmar, devolve um PoliticoModel
// para a HomePage via Navigator.pop(context, model). A HomePage é quem grava
// no banco — assim mantemos a responsabilidade de persistência centralizada.
// =============================================================================
class _FormularioPolitico extends StatefulWidget {
  const _FormularioPolitico();

  @override
  State<_FormularioPolitico> createState() => _FormularioPoliticoState();
}

class _FormularioPoliticoState extends State<_FormularioPolitico> {
  // GlobalKey para acessar e validar o estado do Form.
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _partidoController = TextEditingController();
  final _ufController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _partidoController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  /// Valida o formulário e, se OK, devolve o novo PoliticoModel.
  void _salvar() {
    // validate() dispara todos os `validator` dos campos.
    if (!_formKey.currentState!.validate()) return;

    final novo = PoliticoModel(
      nome: _nomeController.text.trim(),
      partido: _partidoController.text.trim(),
      uf: _ufController.text.trim().toUpperCase(),
    );

    // Retorna o objeto para quem abriu o BottomSheet (HomePage).
    Navigator.pop(context, novo);
  }

  @override
  Widget build(BuildContext context) {
    // Padding que respeita o teclado (viewInsets) para o form não ficar oculto.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cadastrar político',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Campo NOME
            TextFormField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o nome.';
                if (v.trim().length < 2) return 'Nome muito curto.';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Campo PARTIDO
            TextFormField(
              controller: _partidoController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Partido',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o partido.';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Campo UF (2 letras)
            TextFormField(
              controller: _ufController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 2,
              decoration: const InputDecoration(
                labelText: 'UF',
                hintText: 'Ex.: SP',
                prefixIcon: Icon(Icons.map),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe a UF.';
                if (v.trim().length != 2) return 'UF deve ter 2 letras.';
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Botão salvar
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save),
              label: const Text('Salvar no banco offline'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
