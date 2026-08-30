import 'package:flutter/material.dart';

/// Botão de ação reutilizável, utilizado em diversas telas do sistema
/// (Dashboard, Logs, Filtro), evitando duplicação de código de UI.
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? corFundo;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.corFundo,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: corFundo != null
            ? ElevatedButton.styleFrom(backgroundColor: corFundo)
            : null,
      ),
    );
  }
}
