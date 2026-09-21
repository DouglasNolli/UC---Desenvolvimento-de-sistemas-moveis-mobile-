// =============================================================================
// CAMADA DE DADOS — PoliticoRepository (padrão Repository)
// -----------------------------------------------------------------------------
// Abstrai o SQLite da UI. A tela NÃO sabe que existe `sqflite` — ela só pede
// "insere", "lista", "remove". Isso facilita testes e uma eventual troca de
// fonte de dados (ex.: API, Hive) sem tocar na interface.
// =============================================================================
import '../models/politico_model.dart';
import 'database_helper.dart';

class PoliticoRepository {
  final DatabaseHelper _helper;

  // Injeção de dependência com default para o Singleton (facilita testes).
  PoliticoRepository({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  /// CREATE — insere um político e retorna o id gerado.
  Future<int> insert(PoliticoModel politico) async {
    final db = await _helper.database;
    return db.insert(DatabaseHelper.tabelaPoliticos, politico.toMap());
  }

  /// READ — lê todos os políticos ordenados por nome.
  Future<List<PoliticoModel>> getAll() async {
    final db = await _helper.database;
    final linhas = await db.query(
      DatabaseHelper.tabelaPoliticos,
      orderBy: 'nome COLLATE NOCASE ASC',
    );
    // Mapeia cada linha (Map) para um objeto do domínio.
    return linhas.map(PoliticoModel.fromMap).toList();
  }

  /// DELETE — remove por id. `whereArgs` evita SQL Injection.
  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete(
      DatabaseHelper.tabelaPoliticos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
