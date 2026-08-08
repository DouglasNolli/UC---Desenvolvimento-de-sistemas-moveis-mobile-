# Catálogo de Produtos - ATV2

Este projeto foi desenvolvido como parte da disciplina de Desenvolvimento de Sistemas Móveis, com o objetivo de criar um protótipo funcional utilizando Flutter.

A proposta consiste em um catálogo de produtos voltado para o contexto industrial e comercial da região de Jaraguá do Sul, simulando um sistema simples de visualização e interação com itens.

---

## Funcionalidades

- Listagem de produtos na tela inicial
- Navegação para tela de detalhes
- Interação com botão (curtir ou selecionar produto)
- Atualização dinâmica utilizando `setState`
- Interface construída com `Row`, `Column` e `Container`

---

## Estrutura do Projeto

O projeto foi dividido em duas telas principais:

- Home: exibe os produtos disponíveis
- Detalhes: mostra informações do produto selecionado

A navegação entre as telas é feita utilizando:

```dart
Navigator.push()
Navigator.pop()
