import 'dart:async';

import 'package:flutter/material.dart';

import '../data/servicos/servico_notificacoes.dart';
import '../data/servicos/servico_preferencias_usuario.dart';
import '../widgets/estado_pagina.dart';
import 'localizacao_atual_page.dart';

class PaginaEntrada extends StatefulWidget {
  const PaginaEntrada({super.key});

  @override
  State<PaginaEntrada> createState() => _PaginaEntradaState();
}

class _PaginaEntradaState extends State<PaginaEntrada> {
  final ServicoPreferenciasUsuario _preferencias = ServicoPreferenciasUsuario();
  final ServicoNotificacoes _servicoNotificacoes = ServicoNotificacoes();

  @override
  void initState() {
    super.initState();
    _decidirRota();
  }

  Future<void> _decidirRota() async {
    final preferencias = await _preferencias.carregar();

    if (!mounted) {
      return;
    }

    if (preferencias.configurado && preferencias.topicoFcm != null) {
      _inicializarNotificacoesEmBackground(preferencias.topicoFcm!);

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(context, '/mapa');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const LocalizacaoAtualPage(),
      ),
    );
  }

  void _inicializarNotificacoesEmBackground(String topico) {
    unawaited(() async {
      try {
        await _servicoNotificacoes
            .inicializar()
            .timeout(const Duration(seconds: 8));
        await _servicoNotificacoes
            .inscreverNoTopico(topico)
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        // Notificacoes sao opcionais para abrir o app offline.
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EstadoCarregando(),
    );
  }
}
