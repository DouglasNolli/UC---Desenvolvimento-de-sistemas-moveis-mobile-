import 'conversores.dart';

/// Modelo de um parlamentar retornado pelo endpoint `/deputados`.
///
/// É o objeto tipado trafegado entre as telas (Navigator) e também
/// persistido na tabela `favoritos` do SQLite.
class Deputado {
  final int id;
  final String nome;
  final String siglaPartido;
  final String siglaUf;
  final String? urlFoto;
  final String? email;

  /// Legislatura do mandato — exigida pelo endpoint de despesas da API.
  final int idLegislatura;

  const Deputado({
    required this.id,
    required this.nome,
    required this.siglaPartido,
    required this.siglaUf,
    this.urlFoto,
    this.email,
    this.idLegislatura = _legislaturaAtual,
  });

  /// Legislatura corrente, usada quando a API omite o campo.
  static const int _legislaturaAtual = 57;

  /// Mapeamento resiliente do JSON da API (campos podem vir nulos).
  factory Deputado.fromJson(Map<String, dynamic> json) {
    return Deputado(
      id: Conv.inteiro(json['id']),
      nome: Conv.texto(json['nome'], padrao: 'Não informado'),
      siglaPartido: Conv.texto(json['siglaPartido'], padrao: 'S/P'),
      siglaUf: Conv.texto(json['siglaUf'], padrao: '--'),
      urlFoto: Conv.textoOpcional(json['urlFoto']),
      email: Conv.textoOpcional(json['email']),
      idLegislatura:
          Conv.inteiro(json['idLegislatura'], padrao: _legislaturaAtual),
    );
  }

  /// Mapeamento vindo do SQLite (favoritos offline).
  factory Deputado.fromMap(Map<String, dynamic> map) => Deputado.fromJson(map);

  /// Serialização para o SQLite.
  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'siglaPartido': siglaPartido,
        'siglaUf': siglaUf,
        'urlFoto': urlFoto,
        'email': email,
        'idLegislatura': idLegislatura,
      };
}
