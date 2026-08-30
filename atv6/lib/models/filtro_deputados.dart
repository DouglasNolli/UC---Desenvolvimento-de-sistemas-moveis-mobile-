/// Objeto tipado de filtro trafegado entre a Home e a tela de Filtros.
///
/// A navegação nunca usa Strings soltas: a FiltroView devolve uma
/// instância desta classe via `Navigator.pop(context, filtro)`.
class FiltroDeputados {
  final String? uf;
  final String? partido;

  const FiltroDeputados({this.uf, this.partido});

  const FiltroDeputados.vazio() : uf = null, partido = null;

  bool get ativo => uf != null || partido != null;

  FiltroDeputados copyWith({String? uf, String? partido, bool limpar = false}) {
    if (limpar) return const FiltroDeputados.vazio();
    return FiltroDeputados(uf: uf ?? this.uf, partido: partido ?? this.partido);
  }

  /// Comparação usada pelo PopScope para detectar alterações não aplicadas.
  bool igualA(FiltroDeputados outro) => uf == outro.uf && partido == outro.partido;

  String get descricao {
    if (!ativo) return 'Todos os deputados';
    return [if (uf != null) 'UF: $uf', if (partido != null) 'Partido: $partido'].join('  •  ');
  }
}
