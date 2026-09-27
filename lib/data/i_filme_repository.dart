// =============================================================================
// CONTRATO — IFilmeRepository
// -----------------------------------------------------------------------------
// Interface (contrato) da camada de dados. A UI depende DESTA abstração, não da
// implementação concreta com SQLite. Isso permite:
//   • trocar a fonte de dados (SQLite, API, memória) sem tocar na UI;
//   • testar a UI com um repositório "fake" em memória.
// =============================================================================
import '../models/filme_model.dart';

abstract class IFilmeRepository {
  Future<int> insert(FilmeModel filme);
  Future<List<FilmeModel>> getAll();
  Future<int> update(FilmeModel filme);
  Future<int> delete(int id);
}
