import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/deputado.dart';
import '../models/despesa.dart';
import '../models/filtro_deputados.dart';
import '../models/proposicao.dart';

/// Exceção de domínio da camada de rede, exibida amigavelmente na UI.
class ApiException implements Exception {
  final String mensagem;
  const ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Camada de consumo da API de Dados Abertos da Câmara dos Deputados.
///
/// Documentação: https://dadosabertos.camara.leg.br/swagger/api.html
class CamaraService {
  static const String _baseUrl = 'https://dadosabertos.camara.leg.br/api/v2';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  CamaraService({http.Client? client}) : _client = client ?? http.Client();

  /// Libera o cliente HTTP (chamado no `dispose()` das telas).
  void dispose() => _client.close();

  /// Executa a requisição e devolve a lista contida no campo `dados`.
  /// Centraliza o tratamento de erros de rede (DRY).
  Future<List<dynamic>> _buscarDados(String caminho, Map<String, String> query) async {
    final Uri uri = Uri.parse('$_baseUrl$caminho').replace(queryParameters: query);
    try {
      final http.Response resposta =
          await _client.get(uri, headers: {'Accept': 'application/json'}).timeout(_timeout);

      if (resposta.statusCode != 200) {
        throw ApiException('A Câmara respondeu com erro ${resposta.statusCode}.');
      }

      final dynamic corpo = json.decode(utf8.decode(resposta.bodyBytes));
      if (corpo is! Map<String, dynamic> || corpo['dados'] is! List) {
        throw const ApiException('Resposta da API em formato inesperado.');
      }
      return corpo['dados'] as List<dynamic>;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        'Não foi possível conectar à Câmara. Verifique sua internet e tente novamente.',
      );
    }
  }

  /// Lista os deputados em exercício, aplicando os filtros no servidor.
  Future<List<Deputado>> buscarDeputados(FiltroDeputados filtro) async {
    final List<dynamic> dados = await _buscarDados('/deputados', {
      'ordem': 'ASC',
      'ordenarPor': 'nome',
      'itens': '100',
      if (filtro.uf != null) 'siglaUf': filtro.uf!,
      if (filtro.partido != null) 'siglaPartido': filtro.partido!,
    });
    return dados
        .whereType<Map<String, dynamic>>()
        .map(Deputado.fromJson)
        .toList(growable: false);
  }

  /// Despesas (cota parlamentar) mais recentes do parlamentar.
  ///
  /// `idLegislatura` é obrigatório: sem esse parâmetro a API responde
  /// com uma lista vazia mesmo para deputados com gastos registrados.
  Future<List<Despesa>> buscarDespesas(Deputado deputado) async {
    final List<dynamic> dados =
        await _buscarDados('/deputados/${deputado.id}/despesas', {
      'idLegislatura': '${deputado.idLegislatura}',
      'ordem': 'DESC',
      'ordenarPor': 'dataDocumento',
      'itens': '100',
    });
    return dados
        .whereType<Map<String, dynamic>>()
        .map(Despesa.fromJson)
        .toList(growable: false);
  }

  /// Proposições legislativas de autoria do deputado.
  Future<List<Proposicao>> buscarProposicoes(int idDeputado) async {
    final List<dynamic> dados = await _buscarDados('/proposicoes', {
      'idDeputadoAutor': '$idDeputado',
      'ordem': 'DESC',
      'ordenarPor': 'id',
      'itens': '50',
    });
    return dados
        .whereType<Map<String, dynamic>>()
        .map(Proposicao.fromJson)
        .toList(growable: false);
  }

  /// Siglas dos partidos com representação atual (usado na tela de filtros).
  Future<List<String>> buscarSiglasPartidos() async {
    final List<dynamic> dados = await _buscarDados('/partidos', {
      'ordem': 'ASC',
      'ordenarPor': 'sigla',
      'itens': '100',
    });
    return dados
        .whereType<Map<String, dynamic>>()
        .map((p) => (p['sigla'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }
}
