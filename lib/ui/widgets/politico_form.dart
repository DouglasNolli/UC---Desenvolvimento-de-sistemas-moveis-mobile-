// =============================================================================
// WIDGET — PoliticoForm (BottomSheet de cadastro)
// -----------------------------------------------------------------------------
// Formulário com validação. Ao confirmar, devolve um PoliticoModel via
// Navigator.pop(context, model). Quem grava no banco é a camada de dados
// (chamada pela HomePage) — o form só coleta e valida.
// =============================================================================
import 'package:flutter/material.dart';
import '../../models/politico_model.dart';

class PoliticoForm extends StatefulWidget {
  const PoliticoForm({super.key});

  /// Abre o formulário como modal e retorna o político criado (ou null).
  static Future<PoliticoModel?> mostrar(BuildContext context) {
    return showModalBottomSheet<PoliticoModel>(
      context: context,
      isScrollControlled: true, // acompanha o teclado
      showDragHandle: true,
      builder: (_) => const PoliticoForm(),
    );
  }

  @override
  State<PoliticoForm> createState() => _PoliticoFormState();
}

class _PoliticoFormState extends State<PoliticoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _partidoController = TextEditingController();
  final _ufController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _partidoController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  void _salvar() {
    // validate() dispara todos os `validator` dos campos.
    if (!_formKey.currentState!.validate()) return;

    final novo = PoliticoModel(
      nome: _nomeController.text.trim(),
      partido: _partidoController.text.trim(),
      uf: _ufController.text.trim().toUpperCase(),
    );
    Navigator.pop(context, novo);
  }

  @override
  Widget build(BuildContext context) {
    // Respeita o teclado para o form não ficar oculto.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cadastrar político',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o nome.';
                if (v.trim().length < 2) return 'Nome muito curto.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _partidoController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Partido',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o partido.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ufController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 2,
              decoration: const InputDecoration(
                labelText: 'UF',
                hintText: 'Ex.: SP',
                prefixIcon: Icon(Icons.map),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe a UF.';
                if (v.trim().length != 2) return 'UF deve ter 2 letras.';
                return null;
              },
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save),
              label: const Text('Salvar no banco offline'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
