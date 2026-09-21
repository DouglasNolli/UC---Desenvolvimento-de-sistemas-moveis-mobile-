// =============================================================================
// TESTES — Portal Cidadão
// -----------------------------------------------------------------------------
// Provam que o app funciona SEM device físico, cobrindo as duas camadas:
//
//   1) CAMADA DE DADOS (SQLite real, em memória via `sqflite_common_ffi`):
//      testa o CRUD do PoliticoRepository e o mapeamento do modelo.
//
//   2) CAMADA DE UI (FutureBuilder + estados): usa um repositório FAKE em
//      memória (Dart puro). Fazemos isso porque o SQLite via FFI usa I/O
//      assíncrono real, incompatível com o "fake async" do testWidgets —
//      então injetamos um fake, que é a prática recomendada para testar UI.
//
// Para os alunos: rode com  ->  flutter test
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:persistence_app/app.dart';
import 'package:persistence_app/data/i_politico_repository.dart';
import 'package:persistence_app/data/politico_repository.dart';
import 'package:persistence_app/models/politico_model.dart';

/// Repositório FAKE em memória — implementa o mesmo contrato do real.
/// Resolve os Futures instantaneamente, o que funciona com o testWidgets.
class FakePoliticoRepository implements IPoliticoRepository {
  final List<PoliticoModel> _dados = [];
  int _seq = 0;

  @override
  Future<int> insert(PoliticoModel politico) async {
    _seq++;
    _dados.add(politico.copyWith(id: _seq));
    return _seq;
  }

  @override
  Future<List<PoliticoModel>> getAll() async {
    final copia = [..._dados]
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return copia;
  }

  @override
  Future<int> update(PoliticoModel politico) async {
    final i = _dados.indexWhere((p) => p.id == politico.id);
    if (i < 0) return 0;
    _dados[i] = politico;
    return 1;
  }

  @override
  Future<int> delete(int id) async {
    final antes = _dados.length;
    _dados.removeWhere((p) => p.id == id);
    return antes - _dados.length;
  }
}

void main() {
  // -------------------------------------------------------------------------
  // 1) CAMADA DE DADOS — SQLite REAL em memória
  // -------------------------------------------------------------------------
  group('CRUD no SQLite real (Repository)', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test('insere, lista e remove um político', () async {
      final repo = PoliticoRepository();
      // Limpa qualquer resíduo.
      for (final p in await repo.getAll()) {
        await repo.delete(p.id!);
      }

      // CREATE
      final id = await repo.insert(
        const PoliticoModel(nome: 'Fulano de Tal', partido: 'PX', uf: 'SP'),
      );
      expect(id, greaterThan(0));

      // READ
      var lista = await repo.getAll();
      expect(lista.length, 1);
      expect(lista.first.nome, 'Fulano de Tal');
      expect(lista.first.partido, 'PX');
      expect(lista.first.uf, 'SP');

      // DELETE
      final removidos = await repo.delete(lista.first.id!);
      expect(removidos, 1);
      lista = await repo.getAll();
      expect(lista, isEmpty);
    });

    test('atualiza (UPDATE) um político existente', () async {
      final repo = PoliticoRepository();
      for (final p in await repo.getAll()) {
        await repo.delete(p.id!);
      }

      final id = await repo.insert(
        const PoliticoModel(nome: 'Antigo Nome', partido: 'PA', uf: 'AM'),
      );

      // Atualiza mantendo o mesmo id.
      final linhas = await repo.update(
        PoliticoModel(id: id, nome: 'Novo Nome', partido: 'PB', uf: 'BA'),
      );
      expect(linhas, 1);

      final lista = await repo.getAll();
      expect(lista.length, 1);
      expect(lista.first.id, id); // mesmo registro
      expect(lista.first.nome, 'Novo Nome');
      expect(lista.first.partido, 'PB');
      expect(lista.first.uf, 'BA');
    });
  });

  // -------------------------------------------------------------------------
  // MAPEAMENTO DO MODELO
  // -------------------------------------------------------------------------
  group('Mapeamento do modelo', () {
    test('toMap/fromMap são simétricos', () {
      const original =
          PoliticoModel(id: 7, nome: 'Ciclana', partido: 'PY', uf: 'RJ');
      final recriado = PoliticoModel.fromMap(original.toMap());
      expect(recriado.id, 7);
      expect(recriado.nome, 'Ciclana');
      expect(recriado.partido, 'PY');
      expect(recriado.uf, 'RJ');
    });
  });

  // -------------------------------------------------------------------------
  // 2) CAMADA DE UI — com repositório FAKE
  // -------------------------------------------------------------------------
  group('UI (FutureBuilder)', () {
    testWidgets('mostra estado vazio quando não há políticos',
        (tester) async {
      await tester.pumpWidget(PortalCidadaoApp(
        temaInicialEscuro: false,
        repository: FakePoliticoRepository(),
      ));
      await tester.pumpAndSettle(); // aguarda o FutureBuilder resolver

      expect(find.text('Portal Cidadão'), findsOneWidget); // AppBar
      expect(find.text('SQLite ativo'), findsOneWidget); // indicador do banco
      expect(find.text('Nenhum político salvo offline'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('exibe político salvo na lista', (tester) async {
      final fake = FakePoliticoRepository();
      await fake.insert(
        const PoliticoModel(nome: 'Beltrano', partido: 'PZ', uf: 'MG'),
      );

      await tester.pumpWidget(PortalCidadaoApp(
        temaInicialEscuro: false,
        repository: fake,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Beltrano'), findsOneWidget);
      expect(find.text('PZ • MG'), findsOneWidget);
    });

    testWidgets('filtra a lista pela busca', (tester) async {
      final fake = FakePoliticoRepository();
      await fake.insert(
          const PoliticoModel(nome: 'Ana Souza', partido: 'PA', uf: 'BA'));
      await fake.insert(
          const PoliticoModel(nome: 'Bruno Lima', partido: 'PB', uf: 'CE'));

      await tester.pumpWidget(PortalCidadaoApp(
        temaInicialEscuro: false,
        repository: fake,
      ));
      await tester.pumpAndSettle();

      // Ambos aparecem inicialmente.
      expect(find.text('Ana Souza'), findsOneWidget);
      expect(find.text('Bruno Lima'), findsOneWidget);

      // Digita na busca -> filtra.
      await tester.enterText(find.byType(TextField), 'bruno');
      await tester.pumpAndSettle();

      expect(find.text('Ana Souza'), findsNothing);
      expect(find.text('Bruno Lima'), findsOneWidget);
    });

    // REGRESSÃO: garante que, ao cadastrar pelo formulário, a lista atualiza
    // SEM precisar reabrir o app. Esse teste teria pego o bug do `setState`
    // que retornava um Future (o refresh não era aplicado).
    testWidgets('cadastrar pelo formulário atualiza a lista na hora',
        (tester) async {
      await tester.pumpWidget(PortalCidadaoApp(
        temaInicialEscuro: false,
        repository: FakePoliticoRepository(),
      ));
      await tester.pumpAndSettle();

      // Começa vazio.
      expect(find.text('Nenhum político salvo offline'), findsOneWidget);

      // Abre o formulário (FAB).
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Preenche os campos.
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'), 'Carlos Dias');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Partido'), 'PC');
      await tester.enterText(find.widgetWithText(TextFormField, 'UF'), 'RS');

      // Salva.
      await tester.tap(find.text('Salvar no banco offline'));
      await tester.pumpAndSettle();

      // A lista atualizou sem reabrir o app.
      expect(find.text('Nenhum político salvo offline'), findsNothing);
      expect(find.text('Carlos Dias'), findsOneWidget);
      expect(find.text('PC • RS'), findsOneWidget);
    });

    testWidgets('editar pelo formulário atualiza o card', (tester) async {
      final fake = FakePoliticoRepository();
      await fake.insert(
        const PoliticoModel(nome: 'Nome Antigo', partido: 'PA', uf: 'AM'),
      );

      await tester.pumpWidget(PortalCidadaoApp(
        temaInicialEscuro: false,
        repository: fake,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Nome Antigo'), findsOneWidget);

      // Abre a edição pelo botão de lápis.
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // O formulário abre em modo edição, pré-preenchido.
      expect(find.text('Editar político'), findsOneWidget);

      // Altera o nome e salva.
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'), 'Nome Novo');
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      // O card reflete a alteração, sem duplicar registros.
      expect(find.text('Nome Antigo'), findsNothing);
      expect(find.text('Nome Novo'), findsOneWidget);
    });
  });
}
