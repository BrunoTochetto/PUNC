import 'package:flutter/material.dart';

import 'nucleo/temas/appTheme.dart';
import 'source/data/modelos/gerente.dart';
import 'source/data/servicos/servico_sessao_gerente.dart';
import 'source/views/login_page.dart';
import 'source/widgets/gerenciamento_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GerenciamentoPuncApp());
}

class GerenciamentoPuncApp extends StatelessWidget {
  const GerenciamentoPuncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerenciamento PUNC',
      theme: PUNCAppTheme.theme,
      darkTheme: PUNCAppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const AuthGate(forcarLogin: true),
        '/areas': (context) => const AuthGate(destino: '/areas'),
        '/caminhoes': (context) => const AuthGate(destino: '/caminhoes'),
        '/horarios': (context) => const AuthGate(destino: '/horarios'),
        '/rotas': (context) => const AuthGate(destino: '/rotas'),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    this.forcarLogin = false,
    this.destino,
  });

  final bool forcarLogin;
  final String? destino;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _servicoSessao = servicoSessaoGerente;

  bool _carregando = true;
  SessaoGerente? _sessao;

  @override
  void initState() {
    super.initState();
    _restaurarSessao();
  }

  Future<void> _restaurarSessao() async {
    if (widget.forcarLogin) {
      setState(() {
        _sessao = null;
        _carregando = false;
      });
      return;
    }

    final sessao = await _servicoSessao.carregar();
    if (!mounted) return;
    setState(() {
      _sessao = sessao;
      _carregando = false;
    });
  }

  Future<void> _logout() async {
    await _servicoSessao.encerrar();
    if (!mounted) return;
    setState(() => _sessao = null);
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  void _onLogin(SessaoGerente sessao) {
    setState(() => _sessao = sessao);
    final rota = widget.destino ?? '/areas';
    if (widget.destino != null) {
      Navigator.of(context).pushReplacementNamed(rota);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_sessao == null) {
      return LoginPage(onLogin: _onLogin);
    }

    return GerenciamentoShell(
      sessao: _sessao!,
      onLogout: _logout,
      destinoInicial: destinoFromRoute(widget.destino),
    );
  }
}
