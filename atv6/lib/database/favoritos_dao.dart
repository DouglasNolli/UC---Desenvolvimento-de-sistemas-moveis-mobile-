import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

import '../models/deputado.dart';

/// DAO (Data Access Object) dos deputados favoritos.
///
/// Garante a consulta offline exigida pelo projeto: uma vez favoritado,
/// o perfil fica disponível mesmo sem conexão com a API.
class FavoritosDao {
  FavoritosDao._interno();

  /// Instância única — evita abrir múltiplas conexões com o banco.
  static final FavoritosDao instancia = FavoritosDao._interno();

  static const String _tabela = 'favoritos';
  static Database? _db;

  /// Abre (ou cria) o banco local `portal_cidadao.db`.
  Future<Database> get _banco async {
    if (_db != null) return _db!;

    // Em Windows/Linux o sqflite precisa do backend FFI.
    if (Platform.isWindows || Platform.isLinux) {
      ffi.sqfliteFfiInit();
      databaseFactory = ffi.databaseFactoryFfi;
    }

    final String caminho = p.join(await getDatabasesPath(), 'portal_cidadao.db');
    _db = await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_tabela (
          id INTEGER PRIMARY KEY,
          nome TEXT NOT NULL,
          siglaPartido TEXT NOT NULL,
          siglaUf TEXT NOT NULL,
          urlFoto TEXT,
          email TEXT,
          idLegislatura INTEGER NOT NULL DEFAULT 57
        )
      '''),
    );
    return _db!;
  }

  /// CREATE — insere/atualiza o favorito (replace evita duplicidade de id).
  Future<void> inserir(Deputado deputado) async {
    final Database db = await _banco;
    await db.insert(
      _tabela,
      deputado.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// READ — lista todos os favoritos salvos.
  Future<List<Deputado>> listar() async {
    final Database db = await _banco;
    final List<Map<String, dynamic>> linhas = await db.query(_tabela, orderBy: 'nome ASC');
    return linhas.map(Deputado.fromMap).toList(growable: false);
  }

  /// READ — verifica se um deputado específico está favoritado.
  Future<bool> ehFavorito(int id) async {
    final Database db = await _banco;
    final List<Map<String, dynamic>> linhas =
        await db.query(_tabela, where: 'id = ?', whereArgs: [id], limit: 1);
    return linhas.isNotEmpty;
  }

  /// READ — ids favoritados, usado para marcar os cards da listagem.
  Future<Set<int>> listarIds() async {
    final Database db = await _banco;
    final List<Map<String, dynamic>> linhas = await db.query(_tabela, columns: ['id']);
    return linhas.map((l) => l['id'] as int).toSet();
  }

  /// DELETE — remove o favorito.
  Future<void> remover(int id) async {
    final Database db = await _banco;
    await db.delete(_tabela, where: 'id = ?', whereArgs: [id]);
  }

  /// UPDATE/toggle — alterna o estado e devolve `true` se ficou favoritado.
  Future<bool> alternar(Deputado deputado) async {
    if (await ehFavorito(deputado.id)) {
      await remover(deputado.id);
      return false;
    }
    await inserir(deputado);
    return true;
  }
}
