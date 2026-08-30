# Portal Cidadão — Fiscalização Pública

Aplicativo mobile desenvolvido em **Flutter** para consulta e acompanhamento de informações públicas relacionadas à atuação parlamentar, com foco em **transparência, fiscalização de gastos e acompanhamento legislativo**.

> **Atividade 6 — Desenvolvimento de Sistemas Móveis**
> Curso Superior de Tecnologia em Análise e Desenvolvimento de Sistemas

---

## Sobre o projeto

O **Portal Cidadão** tem como objetivo transformar dados públicos disponibilizados pela **Câmara dos Deputados** em uma interface simples, acessível e intuitiva para o cidadão.

A aplicação realiza o consumo de uma **API REST de Dados Abertos**, permitindo consultar deputados em exercício, visualizar despesas parlamentares, acompanhar proposições e salvar parlamentares como favoritos para consulta offline.

O projeto também demonstra a aplicação de conceitos importantes de desenvolvimento mobile, como:

* Consumo de APIs REST
* Modelagem e conversão de dados JSON
* Null Safety
* Persistência local com SQLite
* Gerenciamento de estado
* Navegação entre telas
* Lazy Loading
* Debounce em pesquisas
* Design System
* Tema claro e escuro
* Gerenciamento do ciclo de vida dos componentes
* Tratamento de erros e estados de carregamento

---

## Informações do projeto

| Item               | Informação                                                   |
| ------------------ | ------------------------------------------------------------ |
| **Tema**           | Transparência pública e fiscalização de gastos parlamentares |
| **Plataforma**     | Android                                                      |
| **Framework**      | Flutter 3.44                                                 |
| **Linguagem**      | Dart 3.12                                                    |
| **Banco local**    | SQLite                                                       |
| **Fonte de dados** | API de Dados Abertos da Câmara dos Deputados                 |
| **Arquitetura**    | MVC/MVVM com separação por camadas                           |

---

## Fonte de dados

Os dados utilizados pelo aplicativo são provenientes da **API de Dados Abertos da Câmara dos Deputados**.

Documentação oficial:

https://dadosabertos.camara.leg.br/api/v2

A aplicação utiliza dados públicos para apresentar informações sobre:

* Deputados
* Partidos
* Despesas parlamentares
* Proposições legislativas

---

## Funcionalidades

### 1. Consulta de deputados

Permite visualizar deputados em exercício e pesquisar parlamentares por nome.

A pesquisa utiliza **debounce de 350 ms**, evitando o envio excessivo de requisições enquanto o usuário digita.

Também é possível aplicar filtros por:

* Nome
* Estado (UF)
* Partido

Os filtros de UF e partido são enviados diretamente para a API.

---

### 2. Detalhes do parlamentar

Cada deputado possui uma tela de detalhes contendo informações relevantes sobre sua atuação.

Entre as informações apresentadas estão:

* Nome
* Partido
* Estado
* Informações cadastrais
* Total de despesas
* Despesas detalhadas
* Proposições de autoria

---

### 3. Fiscalização de despesas

O aplicativo permite consultar despesas relacionadas à cota parlamentar.

São apresentados dados como:

* Fornecedor
* Data da despesa
* Valor líquido
* Categoria
* Total do período

As despesas também recebem uma classificação visual de nível:

* **Alto**
* **Médio**
* **Baixo**

Essa classificação facilita a interpretação dos dados pelo usuário.

---

### 4. Favoritos offline

O usuário pode salvar parlamentares como favoritos.

Os favoritos são armazenados localmente utilizando **SQLite**, permitindo que sejam consultados mesmo quando o dispositivo estiver sem conexão com a internet.

Operações implementadas:

* Inserção
* Listagem
* Verificação de favorito
* Listagem de IDs
* Remoção
* Alternância entre favorito/não favorito

---

### 5. Proposições legislativas

A aplicação apresenta proposições relacionadas ao parlamentar, permitindo acompanhar sua atuação legislativa.

São contemplados diferentes tipos de proposições, como:

* Projetos de Lei
* PECs
* Requerimentos
* Outras proposições disponibilizadas pela API

---

### 6. Tema claro e escuro

O aplicativo possui suporte aos modos:

* Light Mode
* Dark Mode

A configuração é centralizada através do `ThemeData`, mantendo a identidade visual consistente entre as telas.

---

## Arquitetura do projeto

O projeto utiliza uma organização baseada em camadas, separando responsabilidades entre modelos, telas, componentes visuais, serviços, temas e persistência de dados.

```text
lib/
│
├── main.dart
│
├── models/
│   ├── conversores.dart
│   ├── deputado.dart
│   ├── despesa.dart
│   ├── proposicao.dart
│   └── filtro_deputados.dart
│
├── views/
│   ├── home_view.dart
│   ├── filtro_view.dart
│   ├── deputado_detalhe_view.dart
│   └── favoritos_view.dart
│
├── widgets/
│   ├── deputado_card.dart
│   ├── despesa_tile.dart
│   ├── status_badge.dart
│   └── estado_view.dart
│
├── themes/
│   └── app_theme.dart
│
├── services/
│   └── camara_service.dart
│
└── database/
    └── favoritos_dao.dart
```

### Organização das responsabilidades

**Models**

Responsáveis pela representação dos dados, conversão de JSON e aplicação de Null Safety.

**Views**

Contêm as telas e a interação com o usuário.

**Widgets**

Componentes reutilizáveis utilizados para evitar duplicação de código e aplicar o princípio **DRY (Don't Repeat Yourself)**.

**Services**

Responsáveis pela comunicação com a API da Câmara dos Deputados e pelo tratamento das requisições.

**Database**

Responsável pela persistência local dos parlamentares favoritos através do SQLite.

**Themes**

Centraliza as configurações visuais do aplicativo nos modos claro e escuro.

---

## Requisitos e implementação

| Requisito                                 | Implementação                                                      | Arquivo                        |
| ----------------------------------------- | ------------------------------------------------------------------ | ------------------------------ |
| Consumo de API com tratamento de exceções | Cliente `http` com timeout de 15 segundos e `ApiException`         | `services/camara_service.dart` |
| Type Safety em JSON inconsistente         | Classe `Conv` para conversão segura de tipos                       | `models/conversores.dart`      |
| Null Safety                               | Campos opcionais e valores padrão nos métodos `fromJson`           | `models/*.dart`                |
| Persistência local                        | CRUD completo utilizando SQLite                                    | `database/favoritos_dao.dart`  |
| Lazy Loading                              | `ListView.builder` nas listagens                                   | `views/*.dart`                 |
| Princípio DRY                             | Widgets reutilizáveis para cards, despesas, badges e estados       | `widgets/*.dart`               |
| Light/Dark Mode                           | Temas centralizados utilizando `ThemeData`                         | `themes/app_theme.dart`        |
| Requisições no ciclo de vida              | Carregamento iniciado no `initState()`                             | `views/*.dart`                 |
| Limpeza de recursos                       | Uso de `dispose()` para controllers, timers e clientes HTTP        | `views/*.dart`                 |
| Estados de carregamento                   | `CircularProgressIndicator` centralizado                           | `widgets/estado_view.dart`     |
| Navegação tipada                          | Passagem de objetos entre telas utilizando `Navigator.push`        | `views/home_view.dart`         |
| Controle de saída de filtros              | `PopScope` com confirmação quando existem alterações não aplicadas | `views/filtro_view.dart`       |

---

## Dependências

| Pacote               | Finalidade                                    |
| -------------------- | --------------------------------------------- |
| `http`               | Comunicação com a API da Câmara dos Deputados |
| `sqflite`            | Persistência de dados utilizando SQLite       |
| `sqflite_common_ffi` | Suporte ao SQLite em plataformas desktop      |
| `path`               | Composição do caminho do banco de dados       |
| `intl`               | Formatação de datas e valores monetários      |

---

## Como executar

### Pré-requisitos

Antes de executar o projeto, é necessário ter instalado:

* Flutter SDK
* Dart SDK
* Android Studio ou Android SDK
* Emulador Android ou dispositivo físico
* Git

Verifique a instalação do Flutter com:

```bash
flutter doctor
```

### Instalação

Clone o repositório:

```bash
git clone <URL_DO_REPOSITORIO>
```

Entre na pasta do projeto:

```bash
cd <PASTA_DO_PROJETO>
```

Instale as dependências:

```bash
flutter pub get
```

Execute o aplicativo:

```bash
flutter run
```

---

## Plataforma

O projeto foi desenvolvido e validado para **Android**, podendo ser executado através de um emulador ou dispositivo físico.

O modo Web não é suportado devido à utilização do pacote `sqflite` para persistência local.

A permissão de acesso à internet já está configurada no projeto Android através do `AndroidManifest.xml`.

---

## Validação

Durante o desenvolvimento foram realizados testes e validações dos principais componentes da aplicação.

| Verificação                  | Resultado                                                            |
| ---------------------------- | -------------------------------------------------------------------- |
| `flutter analyze`            | Nenhum problema encontrado                                           |
| `flutter test`               | Teste de conversão de tipos aprovado                                 |
| Execução em emulador Android | Telas validadas com dados reais                                      |
| API REST                     | Endpoints de deputados, despesas, proposições e partidos verificados |
| SQLite                       | Inserção, leitura, verificação e remoção validadas                   |
| Navegação                    | Fluxos entre telas validados                                         |
| Filtros                      | Aplicação e retorno dos critérios validados                          |
| Dark/Light Mode              | Alternância validada em tempo de execução                            |

---

## Limitações conhecidas

### Votações do parlamentar

A API de Dados Abertos da Câmara dos Deputados não disponibiliza, na implementação utilizada, um endpoint funcional para consulta direta das votações individuais do parlamentar.

O endpoint:

```text
/deputados/{id}/votacoes
```

retorna HTTP 405.

Por esse motivo, o acompanhamento da atuação legislativa foi implementado através das **proposições de autoria do parlamentar**.

### Despesas parlamentares

O endpoint de despesas exige o parâmetro `idLegislatura`.

Sem esse parâmetro, a API pode retornar uma lista vazia mesmo apresentando HTTP 200.

Por esse motivo, o `idLegislatura` foi incorporado ao modelo `Deputado` para permitir a consulta correta das despesas.

---

## Estrutura de navegação

O fluxo principal da aplicação pode ser representado da seguinte forma:

```text
                    ┌─────────────────┐
                    │      Início     │
                    │    HomeView     │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
        ┌───────────┐  ┌────────────┐  ┌────────────┐
        │  Filtros  │  │ Deputado   │  │ Favoritos  │
        │           │  │  Detalhes  │  │            │
        └───────────┘  └─────┬──────┘  └────────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
              ┌───────────┐    ┌─────────────┐
              │ Despesas  │    │ Proposições │
              └───────────┘    └─────────────┘
```

---

## Tecnologias utilizadas

```text
Flutter
Dart
REST API
HTTP
SQLite
SQFlite
JSON
Material Design
Git
GitHub
```

---

## Documentação complementar

O projeto possui documentação adicional sobre o processo de desenvolvimento:

* [`PROMPT_LOG.md`](PROMPT_LOG.md) — Registro de prompts utilizados, debugging, decisões técnicas e refatorações realizadas durante o desenvolvimento.

---

## Considerações finais

O **Portal Cidadão** demonstra a aplicação prática de conceitos de desenvolvimento de sistemas móveis na construção de uma solução voltada à transparência pública.

A integração com uma fonte oficial de dados permite transformar informações governamentais em uma interface mais acessível ao cidadão, enquanto a utilização de persistência local, tratamento de erros, arquitetura organizada e componentes reutilizáveis contribui para uma aplicação mais robusta e sustentável.

O projeto também evidencia a utilização de boas práticas de desenvolvimento Flutter, buscando separar responsabilidades, reduzir duplicação de código e manter o código-fonte organizado para futuras evoluções.
