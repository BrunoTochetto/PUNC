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
      try {
        await _servicoNotificacoes.inicializar();
        await _servicoNotificacoes.inscreverNoTopico(preferencias.topicoFcm!);
      } catch (_) {
        // O app segue mesmo se a reinscricao no topico falhar.
      }

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

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EstadoCarregando(),
    );
  }
}
