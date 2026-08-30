import 'package:flutter/material.dart';

import '../database/favoritos_dao.dart';
import '../models/deputado.dart';
import '../themes/app_theme.dart';
import '../widgets/deputado_card.dart';
import '../widgets/estado_view.dart';
import 'deputado_detalhe_view.dart';

/// Tela de favoritos — lê exclusivamente do SQLite (consulta offline).
class FavoritosView extends StatefulWidget {
  const FavoritosView({super.key});

  @override
  State<FavoritosView> createState() => _FavoritosViewState();
}

class _FavoritosViewState extends State<FavoritosView> {
  final FavoritosDao _dao = FavoritosDao.instancia;

  List<Deputado> _favoritos = const [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final List<Deputado> lista = await _dao.listar();
    if (!mounted) return;
    setState(() {
      _favoritos = lista;
      _carregando = false;
    });
  }

  Future<void> _remover(Deputado deputado) async {
    await _dao.remover(deputado.id);
    await _carregar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${deputado.nome} removido dos favoritos.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos Offline')),
      body: _carregando
          ? EstadoView.carregando('Lendo banco local...')
          : _favoritos.isEmpty
              ? const EstadoView(
                  icone: Icons.star_border,
                  mensagem:
                      'Nenhum favorito salvo.\nMarque um deputado com a estrela para consultá-lo sem internet.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.espacamentoPadrao),
                  itemCount: _favoritos.length,
                  itemBuilder: (context, index) {
                    final Deputado deputado = _favoritos[index];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTheme.espacamentoPequeno),
                      child: DeputadoCard(
                        deputado: deputado,
                        favorito: true,
                        onFavoritar: () => _remover(deputado),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeputadoDetalheView(deputado: deputado),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
