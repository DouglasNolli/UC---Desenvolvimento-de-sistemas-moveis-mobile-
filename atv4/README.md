# Exercícios Flutter - Performance e Gerenciamento de Memória

Este é um **projeto Flutter completo e funcional**, com uma tela inicial
(menu) que leva a cada um dos 3 exercícios.

## Por que não rodava antes
Antes eu tinha te enviado só arquivos `.dart` soltos, sem a estrutura de
projeto Flutter (`pubspec.yaml`, pastas `android/`, `ios/`, etc.). Um
projeto Flutter só roda com `flutter run` se existir um `pubspec.yaml` na
raiz e o código dentro de `lib/`. Agora está tudo organizado assim.

## Estrutura

```
exercicios_flutter/
├── pubspec.yaml
└── lib/
    ├── main.dart                          → tela inicial com menu (ATV1, ATV2, ATV3)
    ├── atv1/
    │   └── lista_otimizada_screen.dart    → ListView.builder
    ├── atv2/
    │   └── dashboard_grid_screen.dart     → GridView.builder
    └── atv3/
        └── monitor_termico_screen.dart    → dispose() / Timer
```

## Como rodar (passo a passo)

Este ambiente aqui não tem o Flutter SDK instalado (não consigo baixar/
compilar por aqui), então você vai rodar na sua máquina. Pré-requisito:
Flutter SDK instalado (`flutter --version` deve funcionar no seu terminal).

1. **Extraia o zip** em uma pasta, por exemplo `exercicios_flutter`.

2. Como este pacote já tem `pubspec.yaml` e `lib/`, mas **não tem** as
   pastas nativas (`android/`, `ios/`, `web/`, etc.) — que são geradas
   automaticamente pela ferramenta `flutter create` — você precisa gerar
   isso uma vez. Dentro da pasta extraída, rode:

   ```bash
   flutter create .
   ```

   Isso vai criar `android/`, `ios/`, `web/`, `windows/`, etc., **sem
   sobrescrever** seu `lib/main.dart` e `pubspec.yaml` (o Flutter detecta
   que já existem e preserva o conteúdo do `lib/`).

3. Baixe as dependências:

   ```bash
   flutter pub get
   ```

4. Rode o app (com um emulador aberto, dispositivo conectado, ou Chrome):

   ```bash
   flutter run
   ```

   Ou, para rodar direto no navegador:

   ```bash
   flutter run -d chrome
   ```

5. Vai abrir a **tela inicial** com 3 cards — toque em cada um para abrir
   o exercício correspondente (ATV1, ATV2 ou ATV3).

## O que cada exercício faz

### ATV1 — O Otimizador de Listas
Trocamos `SingleChildScrollView` + `Column` (que carregava os 100 itens
de uma vez) por `ListView.builder`, que renderiza só os itens visíveis no
viewport, economizando memória.

### ATV2 — O Dashboard em Grade
`GridView.builder` + `SliverGridDelegateWithFixedCrossAxisCount` mostrando
6 sensores industriais em cards de 2 colunas, com indicador visual de
status ativo/inativo.

### ATV3 — O Guardião de Memória
Um `Timer.periodic` simula leitura contínua de um sensor. Ele é
cancelado corretamente em `dispose()`, evitando que continue rodando
depois que a tela é fechada (memory leak). Para comprovar: abra o
console, entre na tela, veja os prints aparecendo a cada segundo, saia da
tela e note que os prints param imediatamente.

## Problemas comuns ao rodar

- **"No pubspec.yaml file found"** → você não está com o terminal dentro
  da pasta `exercicios_flutter` (use `cd exercicios_flutter` antes dos
  comandos).
- **Erro pedindo Android SDK / licenças** → se for rodar em emulador
  Android, aceite as licenças com `flutter doctor --android-licenses`,
  ou simplesmente rode com `-d chrome` para testar mais rápido sem
  precisar de emulador.
- **`flutter create .` reclamando de nome de pacote** → certifique-se de
  que o nome da pasta não tem espaços ou caracteres especiais.
