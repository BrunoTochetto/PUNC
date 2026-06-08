import 'package:flutter/material.dart';

import '../data/modelos/localizacao_usuario.dart';
import '../viewmodels/localizacao_view_model.dart';
import '../widgets/estado_pagina.dart';

class LocalizacaoAtualPage extends StatefulWidget {
  const LocalizacaoAtualPage({super.key});

  @override
  State<LocalizacaoAtualPage> createState() => _LocalizacaoAtualPageState();
}

class _LocalizacaoAtualPageState extends State<LocalizacaoAtualPage> {
  final LocalizacaoViewModel _viewModel = LocalizacaoViewModel();
  late Future<LocalizacaoUsuario> _localizacaoFuture;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _localizacaoFuture = _viewModel.obterAtual();
  }

  Future<void> _confirmar(LocalizacaoUsuario localizacao) async {
    setState(() => _salvando = true);
    try {
      await _viewModel.configurarNotificacoes(localizacao: localizacao);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/mapa');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel configurar as notificacoes.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<LocalizacaoUsuario>(
        future: _localizacaoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EstadoCarregando();
          }

          if (snapshot.hasError) {
            return EstadoErro(
              mensagem: 'Nao foi possivel obter sua localizacao atual.',
              onTentarNovamente: () => setState(_carregar),
            );
          }

          final localizacao = snapshot.data;
          if (localizacao == null) {
            return const EstadoVazio(
              mensagem: 'Nenhuma localizacao encontrada.',
            );
          }

          return Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/imagens/icones/logo.png',
                  height: 132,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 28),
                Text(
                  'Confirmar localizacao',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  localizacao.descricao,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '${localizacao.latitude}, ${localizacao.longitude}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _salvando ? null : () => _confirmar(localizacao),
                  child: _salvando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Usar esta localizacao'),
                ),
                TextButton(
                  onPressed: _salvando
                      ? null
                      : () => Navigator.pushReplacementNamed(context, '/mapa'),
                  child: const Text('Configurar depois'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
