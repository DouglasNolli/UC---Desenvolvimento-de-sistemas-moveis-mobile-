// =============================================================================
// TESTES — Minha Cinemateca
// -----------------------------------------------------------------------------
// Provam que o app funciona SEM device físico, cobrindo as três camadas:
//
//   1) CAMADA DE DADOS (SQLite real, em memória via `sqflite_common_ffi`):
//      testa o CRUD do FilmeRepository e o mapeamento do modelo.
//
//   2) PREFERÊNCIAS (SharedPreferences com store em memória): prova que o
//      último termo de busca é gravado e lido de volta — é a persistência da
//      nova preferência exigida pela tarefa.
//
//   3) CAMADA DE UI (FutureBuilder + estados): usa um repositório FAKE em
//      memória (Dart puro). Fazemos isso porque o SQLite via FFI usa I/O
//      assíncrono real, incompatível com o "fake async" do testWidgets —
//      então injetamos um fake, que é a prática recomendada para testar UI.
//
// Para rodar:  flutter test
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:persistence_app/app.dart';
import 'package:persistence_app/data/busca_preferences.dart';
import 'package:persistence_app/data/filme_repository.dart';
import 'package:persistence_app/data/i_filme_repository.dart';
import 'package:persistence_app/data/theme_preferences.dart';
import 'package:persistence_app/models/filme_model.dart';
import 'package:persistence_app/ui/widgets/filme_card.dart';

/// Repositório FAKE em memória — implementa o mesmo contrato do real.
/// Resolve os Futures instantaneamente, o que funciona com o testWidgets.
class FakeFilmeRepository implements IFilmeRepository {
  final List<FilmeModel> _dados = [];
  int _seq = 0;

  @override
  Future<int> insert(FilmeModel filme) async {
    _seq++;
    _dados.add(filme.copyWith(id: _seq));
    return _seq;
  }

  @override
  Future<List<FilmeModel>> getAll() async {
    final copia = [..._dados]..sort(
        (a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
    return copia;
  }

  @override
  Future<int> update(FilmeModel filme) async {
    final i = _dados.indexWhere((f) => f.id == filme.id);
    if (i < 0) return 0;
    _dados[i] = filme;
    return 1;
  }

  @override
  Future<int> delete(int id) async {
    final antes = _dados.length;
    _dados.removeWhere((f) => f.id == id);
    return antes - _dados.length;
  }
}

void main() {
  // Necessário para usar o store em memória do SharedPreferences nos testes.
  TestWidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------------------------------
  // 1) CAMADA DE DADOS — SQLite REAL em memória
  // -------------------------------------------------------------------------
  group('CRUD no SQLite real (Repository)', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test('insere, lista e remove um filme', () async {
      final repo = FilmeRepository();
      // Limpa qualquer resíduo.
      for (final f in await repo.getAll()) {
        await repo.delete(f.id!);
      }

      // CREATE
      final id = await repo.insert(
        const FilmeModel(
          titulo: 'Cidade de Deus',
          diretor: 'Fernando Meirelles',
          genero: 'Drama',
          ano: 2002,
        ),
      );
      expect(id, greaterThan(0));

      // READ
      var lista = await repo.getAll();
      expect(lista.length, 1);
      expect(lista.first.titulo, 'Cidade de Deus');
      expect(lista.first.diretor, 'Fernando Meirelles');
      expect(lista.first.genero, 'Drama');
      expect(lista.first.ano, 2002);

      // DELETE
      final removidos = await repo.delete(lista.first.id!);
      expect(removidos, 1);
      lista = await repo.getAll();
      expect(lista, isEmpty);
    });

    test('atualiza (UPDATE) um filme existente', () async {
      final repo = FilmeRepository();
      for (final f in await repo.getAll()) {
        await repo.delete(f.id!);
      }

      final id = await repo.insert(
        const FilmeModel(
          titulo: 'Titulo Antigo',
          diretor: 'Diretor Antigo',
          genero: 'Ação',
          ano: 1999,
        ),
      );

      // Atualiza mantendo o mesmo id.
      final linhas = await repo.update(
        FilmeModel(
          id: id,
          titulo: 'Titulo Novo',
          diretor: 'Diretor Novo',
          genero: 'Suspense',
          ano: 2010,
        ),
      );
      expect(linhas, 1);

      final lista = await repo.getAll();
      expect(lista.length, 1);
      expect(lista.first.id, id); // mesmo registro
      expect(lista.first.titulo, 'Titulo Novo');
      expect(lista.first.diretor, 'Diretor Novo');
      expect(lista.first.genero, 'Suspense');
      expect(lista.first.ano, 2010);
    });

    test('a lista vem ordenada por título (ORDER BY do SQL)', () async {
      final repo = FilmeRepository();
      for (final f in await repo.getAll()) {
        await repo.delete(f.id!);
      }

      await repo.insert(const FilmeModel(
          titulo: 'Zodíaco', diretor: 'Fincher', genero: 'Suspense', ano: 2007));
      await repo.insert(const FilmeModel(
          titulo: 'Amnésia', diretor: 'Nolan', genero: 'Suspense', ano: 2000));

      final lista = await repo.getAll();
      expect(lista.map((f) => f.titulo).toList(), ['Amnésia', 'Zodíaco']);
    });
  });

  // -------------------------------------------------------------------------
  // MAPEAMENTO DO MODELO
  // -------------------------------------------------------------------------
  group('Mapeamento do modelo', () {
    test('toMap/fromMap são simétricos', () {
      const original = FilmeModel(
        id: 7,
        titulo: 'A Origem',
        diretor: 'Christopher Nolan',
        genero: 'Ficção',
        ano: 2010,
      );
      final recriado = FilmeModel.fromMap(original.toMap());
      expect(recriado.id, 7);
      expect(recriado.titulo, 'A Origem');
      expect(recriado.diretor, 'Christopher Nolan');
      expect(recriado.genero, 'Ficção');
      expect(recriado.ano, 2010);
    });

    test('toMap omite o id quando ainda não foi inserido', () {
      const novo = FilmeModel(
        titulo: 'Parasita',
        diretor: 'Bong Joon-ho',
        genero: 'Drama',
        ano: 2019,
      );
      expect(novo.toMap().containsKey('id'), isFalse);
    });

    test('a sigla do avatar ignora artigos e preposições', () {
      expect(FilmeCard.siglaTitulo('Cidade de Deus'), 'CD');
      expect(FilmeCard.siglaTitulo('Matrix'), 'MA');
      // Sobrando uma palavra só, usa duas letras dela (e não um "O" solto).
      expect(FilmeCard.siglaTitulo('A Origem'), 'OR');
      // Título formado apenas por conectores: cai para as próprias palavras.
      expect(FilmeCard.siglaTitulo('O e A'), 'OEA');
      expect(FilmeCard.siglaTitulo(''), '?');
    });
  });

  // -------------------------------------------------------------------------
  // 2) PREFERÊNCIAS — tema (já existia) + último termo de busca (NOVA)
  // -------------------------------------------------------------------------
  group('SharedPreferences', () {
    setUp(() {
      // Store em memória limpo antes de cada teste (simula app recém-instalado).
      SharedPreferences.setMockInitialValues({});
    });

    test('tema: default é claro e a escolha é persistida', () async {
      final prefs = ThemePreferences();
      expect(await prefs.loadIsDarkMode(), isFalse); // 1ª execução

      await prefs.saveIsDarkMode(true);
      // Uma NOVA instância lê o valor gravado — foi para o disco, não ficou
      // apenas na memória do objeto.
      expect(await ThemePreferences().loadIsDarkMode(), isTrue);
    });

    test('busca: default é vazio e o termo digitado é persistido', () async {
      final prefs = BuscaPreferences();
      expect(await prefs.loadUltimoTermo(), ''); // 1ª execução

      await prefs.saveUltimoTermo('nolan');
      expect(await BuscaPreferences().loadUltimoTermo(), 'nolan');
    });

    test('busca: termo em branco limpa a preferência', () async {
      final prefs = BuscaPreferences();
      await prefs.saveUltimoTermo('drama');
      expect(await prefs.loadUltimoTermo(), 'drama');

      await prefs.saveUltimoTermo('   ');
      expect(await prefs.loadUltimoTermo(), '');
    });
  });

  // -------------------------------------------------------------------------
  // 3) CAMADA DE UI — com repositório FAKE
  // -------------------------------------------------------------------------
  group('UI (FutureBuilder)', () {
    setUp(() {
      // A HomePage grava a busca no SharedPreferences — precisa do store fake.
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('mostra estado vazio quando não há filmes', (tester) async {
      await tester.pumpWidget(MinhaCinematecaApp(
        temaInicialEscuro: false,
        repository: FakeFilmeRepository(),
      ));
      await tester.pumpAndSettle(); // aguarda o FutureBuilder resolver

      expect(find.text('Minha Cinemateca'), findsOneWidget); // AppBar
      expect(find.text('SQLite ativo'), findsOneWidget); // indicador do banco
      expect(find.text('Nenhum filme salvo offline'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('exibe filme salvo na lista', (tester) async {
      final fake = FakeFilmeRepository();
      await fake.insert(const FilmeModel(
        titulo: 'Parasita',
        diretor: 'Bong Joon-ho',
        genero: 'Drama',
        ano: 2019,
      ));

      await tester.pumpWidget(MinhaCinematecaApp(
        temaInicialEscuro: false,
        repository: fake,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Parasita'), findsOneWidget);
      expect(find.text('Bong Joon-ho • Drama • 2019'), findsOneWidget);
    });

    testWidgets('filtra a lista pela busca', (tester) async {
      final fake = FakeFilmeRepository();
      await fake.insert(const FilmeModel(
          titulo: 'A Origem',
          diretor: 'Christopher Nolan',
          genero: 'Ficção',
          ano: 2010));
      await fake.insert(const FilmeModel(
          titulo: 'Bacurau',
          diretor: 'Kleber Mendonça',
          genero: 'Suspense',
          ano: 2019));

      await tester.pumpWidget(MinhaCinematecaApp(
        temaInicialEscuro: false,
        repository: fake,
      ));
      await tester.pumpAndSettle();

      // Ambos aparecem inicialmente.
      expect(find.text('A Origem'), findsOneWidget);
      expect(find.text('Bacurau'), findsOneWidget);

      // Digita na busca -> filtra (aqui pelo nome do DIRETOR).
      await tester.enterText(find.byType(TextField), 'nolan');
      await tester.pumpAndSettle();

      expect(find.text('Bacurau'), findsNothing);
      expect(find.text('A Origem'), findsOneWidget);
    });

    // ⭐ NOVA PREFERÊNCIA — os dois testes abaixo cobrem o ciclo completo:
    //    gravar ao digitar e restaurar o filtro ao abrir o app.
    testWidgets('digitar na busca PERSISTE o termo no SharedPreferences',
        (tester) async {
      await tester.pumpWidget(MinhaCinematecaApp(
        temaInicialEscuro: false,
        repository: FakeFilmeRepository(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'drama');
      await tester.pumpAndSettle();

      // Lê direto da preferência: é isso que o main() vai ler no próximo boot.
      expect(await BuscaPreferences().loadUltimoTermo(), 'drama');
    });

    testWidgets('app reabre já filtrado pelo último termo de busca',
        (tester) async {
      final fake = FakeFilmeRepository();
      await fake.insert(const FilmeModel(
          titulo: 'A Origem',
          diretor: 'Christopher Nolan',
          genero: 'Ficção',
          ano: 2010));
      await fake.insert(const FilmeModel(
          titulo: 'Bacurau',
          diretor: 'Kleber Mendonça',
          genero: 'Suspense',
          ano: 2019));

      // Simula o main() tendo lido 'nolan' do disco na abertura do app.
      await tester.pumpWidget(MinhaCinematecaApp(
        temaInicialEscuro: false,
        termoBuscaInicial: 'nolan',
        repository: fake,
      ));
      await tester.pumpAndSettle();

      // O campo de busca já vem preenchido e a lista já vem filtrada.
      expect(find.text('nolan'), findsOneWidget);
      expect(find.text('Busca restaurada da última sessão'), findsOneWidget);
      expect(find.text('A Origem'), findsOneWidget);
      expect(find.text('Bacurau'), findsNothing);
    });

    testWidgets('limpar a busca apaga a preferência salva', (tester) async {
      SharedPreferences.setMockInitialValues({'ultimo_termo_busca': 'nolan'});

      await tester.pumpWidget(MinhaCinematecaApp(
        temaInicialEscuro: false,
        termoBuscaInicial: 'nolan',
        repository: FakeFilmeRepository(),
      ));
      await tester.pumpAndSettle();

      // Toca no "X" do campo de busca.
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(await BuscaPreferences().loadUltimoTermo(), '');
    });

    // REGRESSÃO: garante que, ao cadastrar pelo formulário, a lista atualiza
    // SEM precisar reabrir o app. Esse teste teria pego o bug do `setState`
    // que retornava um Future (o refresh não era aplicado).
    testWidgets('cadastrar pelo formulário atualiza a lista na hora',
        (tester) async {
      await tester.pumpWidget(MinhaCinematecaApp(
        temaInicialEscuro: false,
        repository: FakeFilmeRepository(),
      ));
      await tester.pumpAndSettle();

      // Começa vazio.
      expect(find.text('Nenhum filme salvo offline'), findsOneWidget);

      // Abre o formulário (FAB).
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Preenche os campos.
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Título'), 'Whiplash');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Diretor'), 'Damien Chazelle');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Gênero'), 'Drama');
      await tester.enterText(find.widgetWithText(TextFormField, 'Ano'), '2014');

      // Salva.
      await tester.tap(find.text('Salvar no banco offline'));
      await tester.pumpAndSettle();

      // A lista atualizou sem reabrir o app.
      expect(find.text('Nenhum filme salvo offline'), findsNothing);
      expect(find.text('Whiplash'), findsOneWidget);
      expect(find.text('Damien Chazelle • Drama • 2014'), findsOneWidget);
    });

    testWidgets('o formulário recusa ano inválido', (tester) async {
      await tester.pumpWidget(MinhaCinematecaApp(
        temaInicialEscuro: false,
        repository: FakeFilmeRepository(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Título'), 'Filme Impossível');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Diretor'), 'Alguém');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Gênero'), 'Drama');
      // Ano anterior ao primeiro filme da história.
      await tester.enterText(find.widgetWithText(TextFormField, 'Ano'), '1500');

      await tester.tap(find.text('Salvar no banco offline'));
      await tester.pumpAndSettle();

      // O form NÃO fechou e nada foi salvo.
      expect(find.text('Cadastrar filme'), findsOneWidget);
      expect(find.textContaining('Use um ano entre'), findsOneWidget);
    });

    testWidgets('editar pelo formulário atualiza o card', (tester) async {
      final fake = FakeFilmeRepository();
      await fake.insert(const FilmeModel(
        titulo: 'Titulo Antigo',
        diretor: 'Diretor X',
        genero: 'Ação',
        ano: 1999,
      ));

      await tester.pumpWidget(MinhaCinematecaApp(
        temaInicialEscuro: false,
        repository: fake,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Titulo Antigo'), findsOneWidget);

      // Abre a edição pelo botão de lápis.
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // O formulário abre em modo edição, pré-preenchido.
      expect(find.text('Editar filme'), findsOneWidget);

      // Altera o título e salva.
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Título'), 'Titulo Novo');
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      // O card reflete a alteração, sem duplicar registros.
      expect(find.text('Titulo Antigo'), findsNothing);
      expect(find.text('Titulo Novo'), findsOneWidget);
    });

    testWidgets('remover pede confirmação e apaga o card', (tester) async {
      final fake = FakeFilmeRepository();
      await fake.insert(const FilmeModel(
        titulo: 'Filme Descartável',
        diretor: 'Diretor Y',
        genero: 'Comédia',
        ano: 2005,
      ));

      await tester.pumpWidget(MinhaCinematecaApp(
        temaInicialEscuro: false,
        repository: fake,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Filme Descartável'), findsOneWidget);

      // Toca na lixeira -> abre o diálogo de confirmação.
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Remover filme?'), findsOneWidget);

      // Confirma.
      await tester.tap(find.widgetWithText(FilledButton, 'Remover'));
      await tester.pumpAndSettle();

      expect(find.text('Filme Descartável'), findsNothing);
      expect(find.text('Nenhum filme salvo offline'), findsOneWidget);
    });
  });
}
