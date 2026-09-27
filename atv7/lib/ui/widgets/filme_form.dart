// =============================================================================
// WIDGET — FilmeForm (BottomSheet de cadastro/edição)
// -----------------------------------------------------------------------------
// Formulário com validação. Funciona em DOIS modos:
//   • CRIAR  -> `filme` == null  -> campos vazios, título "Cadastrar".
//   • EDITAR -> `filme` != null  -> campos pré-preenchidos, título "Editar",
//               e o objeto devolvido mantém o `id` original (para o UPDATE).
//
// Ao confirmar, devolve um FilmeModel via Navigator.pop(context, model).
// Quem grava no banco (insert/update) é a HomePage — o form só coleta e valida.
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/filme_model.dart';

class FilmeForm extends StatefulWidget {
  /// Filme a editar. Se null, o formulário está em modo de CRIAÇÃO.
  final FilmeModel? filme;

  const FilmeForm({super.key, this.filme});

  /// Abre o formulário como modal e retorna o filme criado/editado (ou null).
  static Future<FilmeModel?> mostrar(
    BuildContext context, {
    FilmeModel? filme,
  }) {
    return showModalBottomSheet<FilmeModel>(
      context: context,
      isScrollControlled: true, // acompanha o teclado
      showDragHandle: true,
      builder: (_) => FilmeForm(filme: filme),
    );
  }

  @override
  State<FilmeForm> createState() => _FilmeFormState();
}

class _FilmeFormState extends State<FilmeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _diretorController;
  late final TextEditingController _generoController;
  late final TextEditingController _anoController;

  bool get _editando => widget.filme != null;

  /// O primeiro filme da história é de 1888 — nada anterior a isso é válido.
  static const int _anoMinimo = 1888;

  @override
  void initState() {
    super.initState();
    // Pré-preenche os campos quando estamos editando.
    _tituloController = TextEditingController(text: widget.filme?.titulo ?? '');
    _diretorController =
        TextEditingController(text: widget.filme?.diretor ?? '');
    _generoController = TextEditingController(text: widget.filme?.genero ?? '');
    _anoController =
        TextEditingController(text: widget.filme?.ano.toString() ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _diretorController.dispose();
    _generoController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  void _salvar() {
    // validate() dispara todos os `validator` dos campos.
    if (!_formKey.currentState!.validate()) return;

    final resultado = FilmeModel(
      // Preserva o id ao editar (necessário para o UPDATE no banco).
      id: widget.filme?.id,
      titulo: _tituloController.text.trim(),
      diretor: _diretorController.text.trim(),
      genero: _generoController.text.trim(),
      // O validator já garantiu que é um número válido.
      ano: int.parse(_anoController.text.trim()),
    );
    Navigator.pop(context, resultado);
  }

  @override
  Widget build(BuildContext context) {
    // Respeita o teclado para o form não ficar oculto.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final anoMaximo = DateTime.now().year + 5; // permite lançamentos futuros

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editando ? 'Editar filme' : 'Cadastrar filme',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tituloController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ex.: Cidade de Deus',
                  prefixIcon: Icon(Icons.movie_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o título.';
                  if (v.trim().length < 2) return 'Título muito curto.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diretorController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Diretor',
                  hintText: 'Ex.: Fernando Meirelles',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o diretor.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _generoController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Gênero',
                  hintText: 'Ex.: Drama, Ficção, Comédia...',
                  prefixIcon: Icon(Icons.theaters_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o gênero.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _anoController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                // Teclado numérico não impede colar texto — o filtro garante.
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  hintText: 'Ex.: 2002',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final texto = (v ?? '').trim();
                  if (texto.isEmpty) return 'Informe o ano.';
                  final ano = int.tryParse(texto);
                  if (ano == null) return 'Ano inválido.';
                  if (ano < _anoMinimo || ano > anoMaximo) {
                    return 'Use um ano entre $_anoMinimo e $anoMaximo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _salvar,
                icon: Icon(_editando ? Icons.check : Icons.save),
                label: Text(
                  _editando ? 'Salvar alterações' : 'Salvar no banco offline',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
