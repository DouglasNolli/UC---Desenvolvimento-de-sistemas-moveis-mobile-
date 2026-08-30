import 'conversores.dart';

/// Modelo de uma proposição legislativa (`/proposicoes?idDeputadoAutor=`).
class Proposicao {
  final int id;
  final String siglaTipo;
  final int numero;
  final int ano;
  final String ementa;

  const Proposicao({
    required this.id,
    required this.siglaTipo,
    required this.numero,
    required this.ano,
    required this.ementa,
  });

  factory Proposicao.fromJson(Map<String, dynamic> json) {
    return Proposicao(
      id: Conv.inteiro(json['id']),
      siglaTipo: Conv.texto(json['siglaTipo'], padrao: 'PROP'),
      numero: Conv.inteiro(json['numero']),
      ano: Conv.inteiro(json['ano']),
      // A ementa é omitida em vários registros históricos.
      ementa: Conv.texto(json['ementa'], padrao: 'Ementa não disponível.'),
    );
  }

  String get identificacao => '$siglaTipo $numero/$ano';
}
