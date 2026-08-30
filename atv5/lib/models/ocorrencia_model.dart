/// Representa uma ocorrência (evento/alarme) registrada no histórico
/// do sistema de supervisão industrial.
///
/// A [gravidade] deve ser uma das strings: 'Crítico', 'Alerta' ou 'Info'.
/// O campo [reconhecida] indica se o operador já reconheceu/tratou a
/// ocorrência, podendo ser alterado dinamicamente pela interface.
class OcorrenciaModel {
  final int id;
  final String titulo;
  final String descricao;
  final String gravidade;
  final DateTime dataHora;
  bool reconhecida;

  OcorrenciaModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.gravidade,
    required this.dataHora,
    this.reconhecida = false,
  });
}
