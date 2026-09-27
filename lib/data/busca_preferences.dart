// =============================================================================
// CAMADA DE DADOS — BuscaPreferences (SharedPreferences)  ⭐ NOVA PREFERÊNCIA
// -----------------------------------------------------------------------------
// Segue exatamente o mesmo padrão de `theme_preferences.dart`, mas persiste o
// ÚLTIMO TERMO DE BUSCA digitado pelo usuário.
//
// Por que isso é uma "preferência" e não um dado do banco?
//   • É uma configuração simples (chave -> valor), não uma entidade com
//     relacionamentos. Criar uma tabela SQLite para guardar UMA string seria
//     usar um caminhão para carregar uma carta.
//   • SQLite  -> dados estruturados (a coleção de filmes).
//     SharedPreferences -> estado/configuração da interface (tema + busca).
//
// Efeito prático: o usuário fecha o app pesquisando "nolan", reabre depois e
// o filtro continua aplicado, com o campo de busca já preenchido.
// =============================================================================
import 'package:shared_preferences/shared_preferences.dart';

class BuscaPreferences {
  // Chave centralizada (evita erro de digitação espalhado pelo código).
  static const String _kUltimaBusca = 'ultimo_termo_busca';

  /// Carrega o último termo pesquisado. Default = '' (sem filtro) na 1ª execução.
  Future<String> loadUltimoTermo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUltimaBusca) ?? '';
  }

  /// Persiste o termo digitado.
  ///
  /// Quando o termo está vazio REMOVEMOS a chave em vez de gravar '' — assim o
  /// arquivo de preferências não fica com lixo e o comportamento volta a ser
  /// idêntico ao da primeira instalação.
  Future<void> saveUltimoTermo(String termo) async {
    final prefs = await SharedPreferences.getInstance();
    final limpo = termo.trim();
    if (limpo.isEmpty) {
      await prefs.remove(_kUltimaBusca);
    } else {
      await prefs.setString(_kUltimaBusca, limpo);
    }
  }
}
