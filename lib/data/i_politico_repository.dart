// =============================================================================
// CONTRATO — IPoliticoRepository
// -----------------------------------------------------------------------------
// Interface (contrato) da camada de dados. A UI depende DESTA abstração, não da
// implementação concreta com SQLite. Isso permite:
//   • trocar a fonte de dados (SQLite, API, memória) sem tocar na UI;
//   • testar a UI com um repositório "fake" em memória.
// =============================================================================
import '../models/politico_model.dart';

abstract class IPoliticoRepository {
  Future<int> insert(PoliticoModel politico);
  Future<List<PoliticoModel>> getAll();
  Future<int> update(PoliticoModel politico);
  Future<int> delete(int id);
}
