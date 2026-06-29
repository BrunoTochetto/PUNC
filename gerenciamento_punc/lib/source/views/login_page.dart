import 'package:flutter/material.dart';

import '../../nucleo/erros/falha_api.dart';
import '../data/modelos/gerente.dart';
import '../data/servicos/servico_sessao_gerente.dart';
import '../domain/casodeuso/login_gerente.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLogin});

  final void Function(SessaoGerente sessao) onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _casoDeUso = LoginGerente();
  final _servicoSessao = servicoSessaoGerente;

  bool _carregando = false;
  bool _obscureSenha = true;
  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      setState(() => _erro = 'Preencha e-mail e senha.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final sessao = await _casoDeUso.executar(email: email, senha: senha);
      await _servicoSessao.salvar(sessao);
      if (!mounted) return;
      widget.onLogin(sessao);
    } on FalhaApi catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível conectar ao servidor.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/imagens/icones/logo.png',
                      height: 72,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.recycling,
                        size: 72,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Gerenciamento PUNC',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Entre com suas credenciais de gerente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _emailController,
                      enabled: !_carregando,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      onSubmitted: (_) => _entrar(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _senhaController,
                      enabled: !_carregando,
                      obscureText: _obscureSenha,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureSenha
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: _carregando
                              ? null
                              : () => setState(
                                    () => _obscureSenha = !_obscureSenha,
                                  ),
                        ),
                      ),
                      onSubmitted: (_) => _entrar(),
                    ),
                    if (_erro != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _erro!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _carregando ? null : _entrar,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _carregando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Entrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
