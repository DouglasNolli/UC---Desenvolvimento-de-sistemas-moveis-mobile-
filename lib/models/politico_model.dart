// =============================================================================
// MODELO DE DADOS — PoliticoModel
// -----------------------------------------------------------------------------
// Entidade IMUTÁVEL (campos `final`). É a ponte entre o mundo Dart (objetos que
// a UI entende) e o SQLite (linhas = Map<String, Object?>).
//
//   • toMap()   -> objeto  -> Map  (para GRAVAR no banco)
//   • fromMap() -> Map      -> objeto (para LER do banco)
// =============================================================================
class PoliticoModel {
  final int? id; // Nulo antes de inserir; o SQLite gera via AUTOINCREMENT.
  final String nome;
  final String partido;
  final String uf;

  const PoliticoModel({
    this.id,
    required this.nome,
    required this.partido,
    required this.uf,
  });

  /// Converte o objeto em Map compatível com as colunas da tabela.
  /// As CHAVES devem ser idênticas aos nomes das colunas no SQLite.
  Map<String, Object?> toMap() {
    return {
      // Omitimos `id` quando null para deixar o AUTOINCREMENT agir.
      if (id != null) 'id': id,
      'nome': nome,
      'partido': partido,
      'uf': uf,
    };
  }

  /// Factory que reconstrói um PoliticoModel a partir de uma linha do banco.
  factory PoliticoModel.fromMap(Map<String, Object?> map) {
    return PoliticoModel(
      id: map['id'] as int?,
      nome: (map['nome'] as String?) ?? '',
      partido: (map['partido'] as String?) ?? '',
      uf: (map['uf'] as String?) ?? '',
    );
  }

  /// Cópia com alterações pontuais (útil para editar mantendo imutabilidade).
  PoliticoModel copyWith({int? id, String? nome, String? partido, String? uf}) {
    return PoliticoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      partido: partido ?? this.partido,
      uf: uf ?? this.uf,
    );
  }

  @override
  String toString() =>
      'PoliticoModel(id: $id, nome: $nome, partido: $partido, uf: $uf)';
}
