# Prompt Log & Code Review — Portal Cidadão

Documento de governança de IA da atividade. Registra os prompts usados, os bugs encontrados no código gerado e as correções manuais aplicadas.

---

## 1. Registro de Prompts

| # | Objetivo | Prompt utilizado |
|---|----------|------------------|
| 1 | **Models** | "Gere as classes Dart `Deputado`, `Despesa` e `Proposicao` com Null Safety e factory `fromJson`, mapeando o JSON da API da Câmara dos Deputados (`/deputados`, `/deputados/{id}/despesas`, `/proposicoes`). Campos opcionais devem ser anuláveis." |
| 2 | **Type Safety** | "A API devolve o mesmo campo ora como `int`, ora como `String`, ora como `null`. Crie uma classe utilitária de conversão segura com métodos para inteiro, decimal, texto e data, e use-a em todos os `fromJson`." |
| 3 | **Service** | "Implemente `CamaraService` usando o pacote `http`, com base URL da API v2, timeout, decodificação UTF-8 e uma exceção de domínio `ApiException` com mensagem amigável para a UI." |
| 4 | **Filtros** | "Crie a lógica de filtragem de deputados por UF e partido enviando `siglaUf` e `siglaPartido` como query params, e uma classe `FiltroDeputados` imutável para trafegar o filtro entre as telas." |
| 5 | **SQLite** | "Implemente um DAO `FavoritosDao` com `sqflite` para CRUD de deputados favoritos (inserir, listar, verificar, remover e alternar), usando singleton e `ConflictAlgorithm.replace`." |
| 6 | **UI/Tema** | "Crie um `ThemeData` centralizado com Light e Dark Mode e paleta institucional neutra, além de widgets reutilizáveis: card de político, item de despesa, badge de status e componente de estado (loading/erro/vazio)." |
| 7 | **Ciclo de vida** | "Nas telas, dispare as requisições no `initState()`, exiba `CircularProgressIndicator` durante o carregamento e libere controllers, timers e o cliente HTTP no `dispose()`." |
| 8 | **PopScope** | "Na tela de filtros, use `PopScope` para impedir a saída acidental quando houver filtros selecionados e não aplicados, exibindo um diálogo de confirmação." |

---

## 2. Log de Debugging

### Bug 1 — Endpoint de despesas retornando lista vazia (bug de lógica)
- **Sintoma:** a aba "Despesas" ficava sempre vazia, sem erro de rede. O código gerado pela IA montava a URL como `/deputados/{id}/despesas?ordem=DESC&ordenarPor=dataDocumento&itens=100`.
- **Diagnóstico:** testando o endpoint diretamente via `curl`, a API responde `{"dados":[]}` (HTTP 200) quando o parâmetro `idLegislatura` não é enviado — inclusive ao filtrar por `ano`. Como o status era 200, o tratamento de erro não acusava nada.
- **Correção manual:** o campo `idLegislatura` foi adicionado ao model `Deputado` (vem no próprio JSON de `/deputados`) e à tabela do SQLite, e o método passou a receber o objeto `Deputado` inteiro em vez de apenas o `id`:

```dart
Future<List<Despesa>> buscarDespesas(Deputado deputado) async {
  final List<dynamic> dados =
      await _buscarDados('/deputados/${deputado.id}/despesas', {
    'idLegislatura': '${deputado.idLegislatura}', // sem isto, a API devolve lista vazia
    'ordem': 'DESC',
    'ordenarPor': 'dataDocumento',
    'itens': '100',
  });
  ...
}
```

### Bug 2 — Erro de tipagem em `valorLiquido` e data nula (bug de tipagem)
- **Sintoma:** o `fromJson` gerado usava cast direto, `valorLiquido: json['valorLiquido'] as double` e `dataDocumento: DateTime.parse(json['dataDocumento'])`. Em registros históricos o valor vem como `String` e a data pode vir `null`, causando `type 'String' is not a subtype of type 'double'` e `Null check operator used on a null value`.
- **Correção manual:** criada a classe `Conv` (`models/conversores.dart`), aplicada em todos os models. `Conv.decimal` aceita `int`, `double` e `String` (inclusive com vírgula decimal) e `Conv.data` usa `DateTime.tryParse`, devolvendo `DateTime?`:

```dart
static double decimal(dynamic valor, {double padrao = 0.0}) {
  if (valor is double) return valor;
  if (valor is int) return valor.toDouble();
  if (valor == null) return padrao;
  final String bruto = valor.toString().trim();
  final String normalizado = bruto.contains(',')
      ? bruto.replaceAll('.', '').replaceAll(',', '.')
      : bruto;
  return double.tryParse(normalizado) ?? padrao;
}
```

O comportamento está coberto pelo teste automatizado em `test/widget_test.dart`, que valida a conversão de `"1234.56"` (String) para `double` e a data nula.

### Bug 3 — `setState()` após o `dispose()` da tela
- **Sintoma:** ao voltar da tela de detalhes antes do fim da requisição, o console exibia `setState() called after dispose()`.
- **Correção manual:** inserido `if (!mounted) return;` antes de todo `setState()` posterior a um `await`, e o `http.Client` passou a ser fechado no `dispose()` de cada tela.

---

## 3. Refatoração Manual

| Ponto | Código gerado pela IA | Refatoração aplicada |
|-------|----------------------|----------------------|
| **Arquitetura** | Telas com chamadas `http.get` e SQL embutidos no `build()`. | Separação em camadas conforme a especificação: `services/` (API), `database/` (SQLite), `models/` (dados) e `views/` (apenas UI e estado). |
| **DRY** | Cada tela repetia `Center(child: CircularProgressIndicator())`, colunas de erro e a decoração dos badges. | Criados `EstadoView` (loading/erro/vazio), `StatusBadge`, `DeputadoCard` e `DespesaTile`, reutilizados por todas as telas. |
| **Navegação tipada** | `Navigator.pushNamed(context, '/detalhe', arguments: {'id': id, 'nome': nome})`. | Substituído por `MaterialPageRoute(builder: (_) => DeputadoDetalheView(deputado: deputado))`, com o objeto `Deputado` tipado. O filtro virou a classe `FiltroDeputados` devolvida por `Navigator.pop`. |
| **Performance** | `Column` dentro de `SingleChildScrollView` com `.map()` sobre a lista inteira. | Trocado por `ListView.builder` em todas as listagens, garantindo lazy loading e reciclagem de memória. |
| **Tema** | Cores declaradas diretamente nos widgets (`Colors.blue`, `Color(0xFF...)`). | Centralizadas em `AppTheme`, com `lightTheme` e `darkTheme` gerados por um único método privado `_construir(Brightness)`. |
| **Busca** | `setState()` a cada tecla digitada, reconstruindo a lista inteira. | Adicionado `Timer` de debounce (350 ms), cancelado no `dispose()`. |
| **Desktop** | `sqflite` puro, que falha ao abrir o banco no Windows. | Inicialização condicional com `sqflite_common_ffi` quando `Platform.isWindows || Platform.isLinux`. |

---

## 4. Validação

```bash
flutter analyze   # No issues found!
flutter test      # All tests passed!
```

Endpoints validados manualmente com `curl` (deputados, despesas, proposições e partidos) e CRUD do SQLite validado localmente antes da entrega.
