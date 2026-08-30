import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import '../widgets/action_button.dart';
import 'dashboard_screen.dart';

/// Tela 1 — Portal de Acesso.
///
/// Demonstra o uso de [TextEditingController], [dispose] para liberar
/// recursos e [Navigator.push] para avançar ao Dashboard.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  @override
  void dispose() {
    // Libera os recursos dos controllers ao destruir o widget.
    usuarioController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void _entrar() {
    final usuario = usuarioController.text.trim();
    final senha = senhaController.text.trim();

    if (usuario.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha usuário e senha para continuar.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.espacamentoPadrao * 1.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.corPrimaria.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing,
                    size: 64,
                    color: AppTheme.corPrimaria,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Supervisão de Máquinas',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Painel de monitoramento industrial',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: AppTheme.espacamentoPadrao),
                TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 32),
                ActionButton(
                  label: 'Acessar Painel',
                  icon: Icons.login,
                  onPressed: _entrar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
