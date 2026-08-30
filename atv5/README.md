# Supervisão de Máquinas — Protótipo Flutter

Protótipo funcional de um sistema de **supervisão de máquinas industriais**, desenvolvido em **Flutter/Dart** como projeto acadêmico. O aplicativo simula sensores de uma máquina e um histórico de ocorrências (alarmes/eventos), permitindo reconhecer alarmes individualmente e filtrar o histórico por gravidade.

## Objetivo

Aplicar, na prática, os conteúdos estudados nas aulas 1 a 5 de Flutter:

- Navegação entre telas (`Navigator.push` / `Navigator.pop`)
- Componentização de widgets
- Design System centralizado (`ThemeData`)
- Listagens performáticas (`GridView.builder` e `ListView.builder`)
- Ciclo de vida do `StatefulWidget` (`initState`, `dispose`, `mounted`)
- Operações assíncronas (`Future.delayed`, `await`)
- Gerenciamento de estado local com `setState`
- Feedback visual com `SnackBar` e `CircularProgressIndicator`

## Tecnologias utilizadas

- **Flutter** / **Dart** (SDK puro, sem pacotes de estado externo)
- Sem banco de dados — todos os dados são simulados em memória
- Sem chamadas a APIs externas

## Estrutura de pastas

```text
lib/
├── main.dart
│
├── models/
│   ├── sensor_model.dart        # Modelo de dados de um sensor
│   └── ocorrencia_model.dart    # Modelo de dados de uma ocorrência
│
├── themes/
│   └── app_theme.dart           # Design System centralizado (ThemeData)
│
├── widgets/
│   ├── sensor_card.dart         # Card reutilizável de sensor
│   └── action_button.dart       # Botão de ação reutilizável
│
└── screens/
    ├── login_screen.dart        # Tela 1 — Portal de Acesso
    ├── dashboard_screen.dart    # Tela 2 — Dashboard de Sensores
    ├── logs_screen.dart         # Tela 3 — Histórico de Ocorrências
    └── filtro_screen.dart       # Tela 4 — Filtro por Gravidade
```

## Funcionalidades

- Login simples (aceita qualquer usuário/senha preenchidos) com liberação de `TextEditingController` no `dispose()`.
- Dashboard com 8 sensores simulados (temperatura, pressão, vibração, velocidade, corrente, tensão, nível de óleo e umidade), renderizados dinamicamente em um `GridView.builder` responsivo.
- Histórico com 50 ocorrências simuladas, carregadas com um loading de ~2 segundos (`CircularProgressIndicator` + `Future.delayed`), exibidas em um `ListView.builder`.
- Reconhecimento individual de ocorrências diretamente na lista, com `setState` atualizando apenas o item selecionado.
- Filtro avançado por gravidade (Crítico, Alerta, Info, Todos), retornando o valor selecionado com `Navigator.pop(context, filtro)` e aplicado de forma assíncrona com `await` na tela de Logs.
- `SnackBar` informando qual filtro foi aplicado após o retorno da tela de filtro.

## Como executar o projeto

1. Certifique-se de ter o [Flutter SDK](https://flutter.dev) instalado e configurado.
2. Extraia o projeto e, no terminal, dentro da pasta do projeto, execute:

   ```bash
   flutter pub get
   flutter run
   ```

3. Escolha um dispositivo/emulador (ou o navegador, com `flutter run -d chrome`).

## Explicação resumida de cada tela

- **Login (`login_screen.dart`)**: tela inicial com campos de usuário e senha (`obscureText: true`), controlados por `TextEditingController`. Ao clicar em "Acessar Painel", navega para o Dashboard com `Navigator.push`.
- **Dashboard (`dashboard_screen.dart`)**: tela principal, exibe os sensores em um `GridView.builder` e possui um botão para acessar o histórico de ocorrências.
- **Logs (`logs_screen.dart`)**: exibe um loading inicial de 2 segundos e, em seguida, a lista de 50 ocorrências em um `ListView.builder`. Permite reconhecer cada ocorrência individualmente e abrir a tela de filtro.
- **Filtro (`filtro_screen.dart`)**: apresenta as opções Crítico, Alerta, Info e Todos. Ao selecionar uma opção, retorna o valor escolhido para a tela de Logs com `Navigator.pop`.

## Explicação dos principais conceitos técnicos

### `GridView.builder`
Constrói os cards de sensores do Dashboard sob demanda, a partir de uma lista de `SensorModel`, evitando criar manualmente cada widget e permitindo boa performance mesmo com muitos itens.

### `ListView.builder`
Utilizado no histórico de ocorrências para renderizar as 50 ocorrências de forma performática, construindo apenas os itens visíveis na tela (ao invés de uma `Column` com todos os 50 elementos de uma vez).

### `initState`
Chamado uma única vez, quando o `LogsScreen` é criado. É utilizado para disparar o carregamento simulado das ocorrências assim que a tela é aberta.

### `dispose`
Utilizado na `LoginScreen` para liberar os `TextEditingController` de usuário e senha, evitando vazamento de memória quando a tela é destruída.

### `Future.delayed`
Simula uma operação assíncrona (como uma consulta a um servidor) que leva aproximadamente 2 segundos, exibindo um `CircularProgressIndicator` enquanto os dados são "carregados".

### Filtro assíncrono com `Navigator.pop` + `await`
A tela de Logs abre a tela de Filtro com `Navigator.push` e aguarda (`await`) o retorno do valor selecionado. A `FiltroScreen`, por sua vez, devolve a gravidade escolhida usando `Navigator.pop(context, filtroSelecionado)`. Ao receber o valor, a tela de Logs reconstrói a lista exibida a partir da lista original de ocorrências e exibe um `SnackBar` confirmando o filtro aplicado.

### `setState`
Utilizado em dois pontos principais: (1) ao concluir o carregamento simulado, atualizando a tela para exibir a lista de ocorrências; e (2) ao reconhecer uma ocorrência individualmente na lista, atualizando apenas aquele item visualmente.

### Widgets reutilizáveis
- **`SensorCard`**: recebe um `SensorModel` e exibe ícone, nome, valor, unidade e status do sensor, sendo utilizado pelo `GridView.builder` do Dashboard.
- **`ActionButton`**: botão padronizado que recebe rótulo, ícone e callback `onPressed`, reutilizado nas telas de Login, Dashboard e Logs para manter consistência visual e evitar duplicação de código.
