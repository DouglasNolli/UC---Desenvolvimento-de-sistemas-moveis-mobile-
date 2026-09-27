// =============================================================================
// CAMADA DE DADOS — FilmeRepository (padrão Repository)
// -----------------------------------------------------------------------------
// Abstrai o SQLite da UI. A tela NÃO sabe que existe `sqflite` — ela só pede
// "insere", "lista", "remove". Isso facilita testes e uma eventual troca de
// fonte de dados (ex.: API, Hive) sem tocar na interface.
// =============================================================================
import '../models/filme_model.dart';
import 'database_helper.dart';
import 'i_filme_repository.dart';

class FilmeRepository implements IFilmeRepository {
  final DatabaseHelper _helper;

  // Injeção de dependência com default para o Singleton (facilita testes).
  FilmeRepository({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  /// CREATE — insere um filme e retorna o id gerado.
  @override
  Future<int> insert(FilmeModel filme) async {
    final db = await _helper.database;
    return db.insert(DatabaseHelper.tabelaFilmes, filme.toMap());
  }

  /// READ — lê todos os filmes ordenados por título (ignorando maiúsculas).
  @override
  Future<List<FilmeModel>> getAll() async {
    final db = await _helper.database;
    final linhas = await db.query(
      DatabaseHelper.tabelaFilmes,
      orderBy: 'titulo COLLATE NOCASE ASC',
    );
    // Mapeia cada linha (Map) para um objeto do domínio.
    return linhas.map(FilmeModel.fromMap).toList();
  }

  /// UPDATE — atualiza um filme existente (pelo id). Retorna nº de linhas.
  @override
  Future<int> update(FilmeModel filme) async {
    final db = await _helper.database;
    return db.update(
      DatabaseHelper.tabelaFilmes,
      filme.toMap(),
      where: 'id = ?',
      whereArgs: [filme.id],
    );
  }

  /// DELETE — remove por id. `whereArgs` evita SQL Injection.
  @override
  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete(
      DatabaseHelper.tabelaFilmes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
