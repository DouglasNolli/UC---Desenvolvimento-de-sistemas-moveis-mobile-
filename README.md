# 🏛️ Portal Cidadão: Políticos Favoritos (Offline)

Aplicativo Flutter didático que demonstra, na prática, **Persistência de Dados Local** combinando duas tecnologias:

| Tecnologia | Para quê usamos | Pacote |
|---|---|---|
| **SQLite** | Dados estruturados: o CRUD de políticos (tabela relacional) | [`sqflite`](https://pub.dev/packages/sqflite) + [`path`](https://pub.dev/packages/path) |
| **SharedPreferences** | Configuração chave-valor: o tema (claro/escuro) | [`shared_preferences`](https://pub.dev/packages/shared_preferences) |

O usuário pode **cadastrar, listar, pesquisar e remover** políticos monitorados — tudo salvo **offline** no dispositivo.

---

## 📱 O que o app faz

1. **Lista** os políticos salvos no banco local (nome, partido, UF).
2. **Cadastra** um novo político por um formulário (BottomSheet) com validação.
3. **Pesquisa** por nome, partido ou UF (filtro em tempo real).
4. **Edita** um político (toque no lápis ou no card) — mesmo formulário, pré-preenchido.
5. **Remove** um político (com diálogo de confirmação).
6. **Alterna o tema** claro/escuro pela AppBar — e **lembra a escolha** na próxima abertura (SharedPreferences).
7. Mostra um **indicador "SQLite ativo"** na AppBar e **SnackBars** de feedback ao salvar/editar/remover.

> O app cobre o **CRUD completo**: Create (cadastrar), Read (listar/pesquisar), Update (editar) e Delete (remover).

### Estados da tela (via `FutureBuilder`)

| Estado | O que aparece |
|---|---|
| ⏳ Carregando | `CircularProgressIndicator()` |
| 🤖 Vazio | Ícone amigável + "Nenhum político salvo offline" |
| 📋 Com dados | `ListView` de `Card`s com avatar da sigla do partido e botão de lixeira |
| ⚠️ Erro | Mensagem de erro amigável |

---

## 🧱 Arquitetura (em camadas)

O código **não** fica todo em um arquivo. Cada responsabilidade tem seu lugar — como em um projeto profissional:

```
lib/
├── main.dart                       # Bootstrap: carrega o tema salvo e sobe o app
├── app.dart                        # MaterialApp + gestão do tema (claro/escuro)
│
├── models/
│   └── politico_model.dart         # Entidade IMUTÁVEL. toMap() / fromMap()
│
├── data/                           # Camada de dados (persistência)
│   ├── database_helper.dart        # Singleton do SQLite (abre banco + cria schema)
│   ├── i_politico_repository.dart  # Contrato (interface) do repositório
│   ├── politico_repository.dart    # CRUD (isola o SQL da UI)
│   └── theme_preferences.dart      # Wrapper do SharedPreferences (tema)
│
└── ui/                             # Camada de apresentação
    ├── home_page.dart              # Tela principal (FutureBuilder + busca)
    └── widgets/
        ├── politico_card.dart      # Card/ListTile de um político
        ├── politico_form.dart      # Formulário (BottomSheet) com validação
        └── empty_state.dart        # Estado vazio amigável
```

### Por que separar assim?

- **`DatabaseHelper` (Singleton):** garante **uma única conexão** com o arquivo do banco. Abrir o mesmo banco várias vezes em paralelo pode **corromper** o arquivo — o Singleton evita isso.
- **`Repository`:** a tela **não sabe** que existe SQL. Ela pede "insere", "lista", "remove". Isso permite **testar a UI** com um repositório fake e trocar a fonte de dados sem mexer na interface.
- **`Model` imutável:** `toMap()` grava no banco; `fromMap()` reconstrói o objeto ao ler. É a ponte objeto ⇄ linha da tabela.

### Esquema da tabela `politicos`

```sql
CREATE TABLE politicos (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  nome    TEXT NOT NULL,
  partido TEXT NOT NULL,
  uf      TEXT NOT NULL
);
```

---

## ▶️ Como rodar

### Pré-requisitos
- [Flutter 3.10+](https://docs.flutter.dev/get-started/install) instalado (`flutter doctor` sem erros).
- Um emulador Android, simulador iOS **ou** dispositivo físico conectado.

### Passos

```bash
# 1. Instale as dependências
flutter pub get

# 2. Veja os dispositivos disponíveis
flutter devices

# 3. Rode o app (Android/iOS é o alvo recomendado — o SQLite é nativo lá)
flutter run
```

Para escolher um dispositivo específico:

```bash
flutter run -d <id-do-dispositivo>   # ex.: flutter run -d emulator-5554
```

> **Observação sobre plataformas:** o `sqflite` roda nativamente em **Android** e **iOS**. Em desktop/web ele precisa do pacote auxiliar `sqflite_common_ffi` (usado apenas nos testes deste projeto). Para a demonstração em sala, use **Android ou iOS**.

---

## ✅ Como testar (sem precisar de celular)

O projeto acompanha testes automatizados que provam o funcionamento **sem device físico** (o SQLite roda em memória via `sqflite_common_ffi`):

```bash
flutter test
```

Saída esperada:

```
00:02 +8: All tests passed!
```

Os testes cobrem:
1. **CRUD real no SQLite** (insere → lista → atualiza → remove).
2. **Mapeamento do modelo** (`toMap`/`fromMap` simétricos).
3. **UI**: estado vazio, lista com dados, filtro de busca, cadastro e edição (com repositório fake).

Para checar o código estático (lint):

```bash
flutter analyze     # deve retornar: No issues found!
```

---

## 🧭 Roteiro de leitura sugerido (para estudo)

1. `models/politico_model.dart` — como mapeamos objeto ⇄ linha da tabela.
2. `data/database_helper.dart` — Singleton + abertura do banco + criação do schema.
3. `data/politico_repository.dart` — as operações CRUD isoladas da UI.
4. `data/theme_preferences.dart` — leitura/escrita de configuração no SharedPreferences.
5. `main.dart` + `app.dart` — carregamento do tema salvo e montagem do app.
6. `ui/home_page.dart` — o `FutureBuilder` desenhando a lista e reagindo aos estados.

---

## 📦 Dependências principais

```yaml
dependencies:
  sqflite: ^2.3.3+1          # Banco relacional embarcado (SQLite)
  path: ^1.9.0               # Monta o caminho do arquivo do banco por SO
  shared_preferences: ^2.2.3 # Armazenamento chave-valor (tema)

dev_dependencies:
  sqflite_common_ffi: ^2.3.3 # SQLite em memória para os testes (desktop/CI)
```

---

Projeto acadêmico — SENAI, Desenvolvimento Mobile.
