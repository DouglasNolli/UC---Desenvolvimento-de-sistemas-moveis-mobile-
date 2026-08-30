import 'package:flutter/material.dart';

/// Representa um sensor industrial monitorado pelo sistema de supervisão.
///
/// Cada sensor possui um identificador, um nome descritivo, um valor
/// numérico atual, a unidade de medida, um status (Normal, Atenção,
/// Crítico) e um ícone associado para representação visual.
class SensorModel {
  final int id;
  final String nome;
  final double valor;
  final String unidade;
  final String status;
  final IconData icone;

  const SensorModel({
    required this.id,
    required this.nome,
    required this.valor,
    required this.unidade,
    required this.status,
    required this.icone,
  });
}
