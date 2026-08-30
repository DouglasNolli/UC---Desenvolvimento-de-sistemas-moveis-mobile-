import 'conversores.dart';

/// Modelo de uma despesa (cota parlamentar) do endpoint `/deputados/{id}/despesas`.
class Despesa {
  final int ano;
  final int mes;
  final String tipoDespesa;
  final String fornecedor;
  final double valorLiquido;
  final DateTime? dataDocumento;

  const Despesa({
    required this.ano,
    required this.mes,
    required this.tipoDespesa,
    required this.fornecedor,
    required this.valorLiquido,
    this.dataDocumento,
  });

  /// `valorLiquido` costuma vir como String em registros antigos —
  /// por isso o parse passa por [Conv.decimal].
  factory Despesa.fromJson(Map<String, dynamic> json) {
    return Despesa(
      ano: Conv.inteiro(json['ano']),
      mes: Conv.inteiro(json['mes']),
      tipoDespesa: Conv.texto(json['tipoDespesa'], padrao: 'Despesa não classificada'),
      fornecedor: Conv.texto(json['nomeFornecedor'], padrao: 'Fornecedor não informado'),
      valorLiquido: Conv.decimal(json['valorLiquido']),
      dataDocumento: Conv.data(json['dataDocumento']),
    );
  }

  /// Classificação usada pelo badge de status na interface.
  String get nivel {
    if (valorLiquido >= 5000) return 'Alto';
    if (valorLiquido >= 1000) return 'Médio';
    return 'Baixo';
  }
}
