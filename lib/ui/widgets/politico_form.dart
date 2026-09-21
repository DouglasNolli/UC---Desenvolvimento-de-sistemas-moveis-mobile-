// =============================================================================
// WIDGET — PoliticoForm (BottomSheet de cadastro/edição)
// -----------------------------------------------------------------------------
// Formulário com validação. Funciona em DOIS modos:
//   • CRIAR  -> `politico` == null  -> campos vazios, título "Cadastrar".
//   • EDITAR -> `politico` != null  -> campos pré-preenchidos, título "Editar",
//               e o objeto devolvido mantém o `id` original (para o UPDATE).
//
// Ao confirmar, devolve um PoliticoModel via Navigator.pop(context, model).
// Quem grava no banco (insert/update) é a HomePage — o form só coleta e valida.
// =============================================================================
import 'package:flutter/material.dart';
import '../../models/politico_model.dart';

class PoliticoForm extends StatefulWidget {
  /// Político a editar. Se null, o formulário está em modo de CRIAÇÃO.
  final PoliticoModel? politico;

  const PoliticoForm({super.key, this.politico});

  /// Abre o formulário como modal e retorna o político criado/editado (ou null).
  static Future<PoliticoModel?> mostrar(
    BuildContext context, {
    PoliticoModel? politico,
  }) {
    return showModalBottomSheet<PoliticoModel>(
      context: context,
      isScrollControlled: true, // acompanha o teclado
      showDragHandle: true,
      builder: (_) => PoliticoForm(politico: politico),
    );
  }

  @override
  State<PoliticoForm> createState() => _PoliticoFormState();
}

class _PoliticoFormState extends State<PoliticoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _partidoController;
  late final TextEditingController _ufController;

  bool get _editando => widget.politico != null;

  @override
  void initState() {
    super.initState();
    // Pré-preenche os campos quando estamos editando.
    _nomeController = TextEditingController(text: widget.politico?.nome ?? '');
    _partidoController =
        TextEditingController(text: widget.politico?.partido ?? '');
    _ufController = TextEditingController(text: widget.politico?.uf ?? '');
  }

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

    final resultado = PoliticoModel(
      // Preserva o id ao editar (necessário para o UPDATE no banco).
      id: widget.politico?.id,
      nome: _nomeController.text.trim(),
      partido: _partidoController.text.trim(),
      uf: _ufController.text.trim().toUpperCase(),
    );
    Navigator.pop(context, resultado);
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
              _editando ? 'Editar político' : 'Cadastrar político',
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
              icon: Icon(_editando ? Icons.check : Icons.save),
              label: Text(_editando
                  ? 'Salvar alterações'
                  : 'Salvar no banco offline'),
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
