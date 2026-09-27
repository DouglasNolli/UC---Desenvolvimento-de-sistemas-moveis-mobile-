// =============================================================================
// MODELO DE DADOS — FilmeModel
// -----------------------------------------------------------------------------
// Entidade IMUTÁVEL (campos `final`). É a ponte entre o mundo Dart (objetos que
// a UI entende) e o SQLite (linhas = Map<String, Object?>).
//
//   • toMap()   -> objeto -> Map    (para GRAVAR no banco)
//   • fromMap() -> Map    -> objeto (para LER do banco)
//
// A tabela `filmes` tem 4 campos além do `id`: titulo, diretor, genero e ano.
// Note que `ano` é INTEGER no banco (e `int` aqui) — os demais são TEXT.
// =============================================================================
class FilmeModel {
  final int? id; // Nulo antes de inserir; o SQLite gera via AUTOINCREMENT.
  final String titulo;
  final String diretor;
  final String genero;
  final int ano;

  const FilmeModel({
    this.id,
    required this.titulo,
    required this.diretor,
    required this.genero,
    required this.ano,
  });

  /// Converte o objeto em Map compatível com as colunas da tabela.
  /// As CHAVES devem ser idênticas aos nomes das colunas no SQLite.
  Map<String, Object?> toMap() {
    return {
      // Omitimos `id` quando null para deixar o AUTOINCREMENT agir.
      if (id != null) 'id': id,
      'titulo': titulo,
      'diretor': diretor,
      'genero': genero,
      'ano': ano,
    };
  }

  /// Factory que reconstrói um FilmeModel a partir de uma linha do banco.
  factory FilmeModel.fromMap(Map<String, Object?> map) {
    return FilmeModel(
      id: map['id'] as int?,
      titulo: (map['titulo'] as String?) ?? '',
      diretor: (map['diretor'] as String?) ?? '',
      genero: (map['genero'] as String?) ?? '',
      // O SQLite devolve int, mas tratamos num de forma defensiva.
      ano: (map['ano'] as num?)?.toInt() ?? 0,
    );
  }

  /// Cópia com alterações pontuais (útil para editar mantendo imutabilidade).
  FilmeModel copyWith({
    int? id,
    String? titulo,
    String? diretor,
    String? genero,
    int? ano,
  }) {
    return FilmeModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      diretor: diretor ?? this.diretor,
      genero: genero ?? this.genero,
      ano: ano ?? this.ano,
    );
  }

  @override
  String toString() => 'FilmeModel(id: $id, titulo: $titulo, '
      'diretor: $diretor, genero: $genero, ano: $ano)';
}
