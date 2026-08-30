# Portal Cidadão — Fiscalização Pública

Aplicativo Flutter que consome a **API de Dados Abertos da Câmara dos Deputados** e traduz os dados públicos em uma interface simples de consulta: listagem de parlamentares com filtros, detalhamento de gastos da cota parlamentar, proposições de autoria e favoritos salvos localmente para consulta **offline**.

- API utilizada: <https://dadosabertos.camara.leg.br/api/v2>

## Funcionalidades

- **Listagem de políticos** — deputados em exercício, com busca por nome (com *debounce*) e filtros por **estado (UF)** e **partido** aplicados no servidor.
- **Detalhes de gastos** — despesas da cota parlamentar com fornecedor, data, valor líquido e *badge* de nível (Alto / Médio / Baixo), além do total gasto no período.
- **Favoritos offline** — deputados salvos em banco **SQLite** local, consultáveis sem internet.
- **Gestão de proposições** — projetos e requerimentos de autoria do parlamentar, em aba própria.
- **Tema Claro/Escuro** — alternado pelo botão da AppBar, com `ThemeData` centralizado.

## Estrutura de pastas (arquitetura MVC/MVVM)

```text
lib/
├── main.dart                      # Widget raiz + controle de ThemeMode
│
├── models/                        # Classes de dados, Null Safety e mapeamento JSON
│   ├── conversores.dart           # Conversores seguros de tipo (Type Safety)
│   ├── deputado.dart
│   ├── despesa.dart
│   ├── proposicao.dart
│   └── filtro_deputados.dart      # Objeto tipado de filtro (navegação)
│
├── views/                         # Telas
│   ├── home_view.dart             # Listagem de deputados + busca + filtros
│   ├── filtro_view.dart           # Filtros por UF e partido (PopScope)
│   ├── deputado_detalhe_view.dart # Abas de despesas e proposições
│   └── favoritos_view.dart        # Favoritos lidos do SQLite
│
├── widgets/                       # Componentes reutilizáveis (DRY)
│   ├── deputado_card.dart         # Card de político
│   ├── despesa_tile.dart          # Item de despesa
│   ├── status_badge.dart          # Badge de status/nível
│   └── estado_view.dart           # Loader, erro e lista vazia
│
├── themes/
│   └── app_theme.dart             # Design System (Light e Dark Mode)
│
├── services/
│   └── camara_service.dart        # Consumo da API (pacote http) + ApiException
│
└── database/
    └── favoritos_dao.dart         # CRUD SQLite dos favoritos
```

## Como executar

```bash
flutter pub get
flutter run
```

O app foi validado em **Android** e **Windows desktop**. No desktop o `sqflite` é inicializado via `sqflite_common_ffi` automaticamente (ver `favoritos_dao.dart`). O modo web não é suportado, pois o `sqflite` não roda no navegador.

> A permissão `android.permission.INTERNET` já está declarada no `AndroidManifest.xml`.

## Decisões técnicas

### Consumo de API e Type Safety
`CamaraService` centraliza as requisições (`http`), com `timeout` de 15s e `ApiException` para erros tratados na UI. Como a API retorna tipos inconsistentes (números como `String`, campos ausentes em registros históricos), todo o mapeamento passa pela classe `Conv` (`models/conversores.dart`), que converte com segurança para `int`, `double`, `String` e `DateTime?` sem lançar exceções.

### Persistência SQLite
`FavoritosDao` implementa o CRUD completo (`inserir`, `listar`, `ehFavorito`, `listarIds`, `remover`, `alternar`) sobre a tabela `favoritos`, usando `ConflictAlgorithm.replace` para evitar duplicidade de `id`. Os dados salvos são os mesmos do modelo `Deputado`, garantindo integridade entre API e banco local.

### Performance
Todas as listas usam `ListView.builder`, que constrói apenas os itens visíveis e recicla os widgets ao rolar — necessário porque a API devolve até 100 registros por página de despesas e centenas de deputados.

### Ciclo de vida
As requisições são disparadas no `initState()`. O `dispose()` libera `TextEditingController`, `TabController`, o `Timer` do debounce da busca e o `http.Client`. Antes de cada `setState()` assíncrono há a verificação `if (!mounted) return`.

### Navegação e PopScope
A passagem de dados entre telas usa **objetos tipados**: `DeputadoDetalheView` recebe um `Deputado` e `FiltroView` devolve um `FiltroDeputados` via `Navigator.pop`. A tela de filtros usa `PopScope` para bloquear a saída quando há critérios selecionados e ainda não aplicados, exibindo um diálogo de confirmação.

## Documentação complementar

- [`PROMPT_LOG.md`](PROMPT_LOG.md) — Prompt Log & Code Review (governança de IA).
