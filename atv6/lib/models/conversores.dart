/// Conversores seguros de JSON (Type Safety).
///
/// A API da Câmara dos Deputados é inconsistente quanto aos tipos:
/// o mesmo campo pode voltar como `int`, `double`, `String` ou `null`
/// dependendo do registro (principalmente em dados históricos).
/// Estas funções centralizam o tratamento (princípio DRY) e evitam
/// exceções de cast em tempo de execução.
class Conv {
  Conv._();

  /// Converte qualquer valor para [String], usando [padrao] quando nulo/vazio.
  static String texto(dynamic valor, {String padrao = '-'}) {
    if (valor == null) return padrao;
    final String s = valor.toString().trim();
    return s.isEmpty ? padrao : s;
  }

  /// Converte para [String] permitindo nulo (campos realmente opcionais).
  static String? textoOpcional(dynamic valor) {
    if (valor == null) return null;
    final String s = valor.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// Converte para [int] aceitando `int`, `double`, `String` ou `null`.
  static int inteiro(dynamic valor, {int padrao = 0}) {
    if (valor is int) return valor;
    if (valor is double) return valor.toInt();
    return int.tryParse(valor?.toString().trim() ?? '') ?? padrao;
  }

  /// Converte para [double] aceitando vírgula decimal ("1.234,56") e nulos.
  static double decimal(dynamic valor, {double padrao = 0.0}) {
    if (valor is double) return valor;
    if (valor is int) return valor.toDouble();
    if (valor == null) return padrao;
    final String bruto = valor.toString().trim();
    if (bruto.isEmpty) return padrao;
    // Normaliza formatos com separador brasileiro antes do parse.
    final String normalizado =
        bruto.contains(',') ? bruto.replaceAll('.', '').replaceAll(',', '.') : bruto;
    return double.tryParse(normalizado) ?? padrao;
  }

  /// Converte para [DateTime] sem lançar exceção em datas ausentes/inválidas.
  static DateTime? data(dynamic valor) {
    final String? bruto = textoOpcional(valor);
    if (bruto == null) return null;
    return DateTime.tryParse(bruto);
  }
}
