import 'package:flutter_test/flutter_test.dart';

import 'package:portal_cidadao_fiscalizacao_publica/models/despesa.dart';

void main() {
  test('Despesa converte valor em String para double (Type Safety)', () {
    final Despesa despesa = Despesa.fromJson({
      'ano': '2024',
      'mes': '3',
      'tipoDespesa': 'DIVULGACAO DA ATIVIDADE PARLAMENTAR',
      'nomeFornecedor': null,
      'valorLiquido': '1234.56',
      'dataDocumento': null,
    });

    expect(despesa.ano, 2024);
    expect(despesa.valorLiquido, 1234.56);
    expect(despesa.fornecedor, 'Fornecedor não informado');
    expect(despesa.dataDocumento, isNull);
    expect(despesa.nivel, 'Médio');
  });
}
