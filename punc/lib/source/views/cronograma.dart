import 'package:flutter/material.dart';

import '../data/modelos/horario_coleta.dart';
import '../viewmodels/cronograma_view_model.dart';
import '../widgets/card_crono.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/punc_app_shell.dart';

class CronogramaPage extends StatefulWidget {
  const CronogramaPage({super.key});

  @override
  State<CronogramaPage> createState() => _CronogramaPageState();
}

class _CronogramaPageState extends State<CronogramaPage> {
  final CronogramaViewModel _viewModel = CronogramaViewModel();
  late Future<List<HorarioColeta>> _cronogramaFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _cronogramaFuture = _viewModel.carregar();
  }

  @override
  Widget build(BuildContext context) {
    return PuncAppShell(
      selectedRoute: '/cronograma',
      body: FutureBuilder<List<HorarioColeta>>(
        future: _cronogramaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EstadoCarregando();
          }

          if (snapshot.hasError) {
            return EstadoErro(
              mensagem: 'Nao foi possivel carregar o cronograma.',
              onTentarNovamente: () => setState(_carregar),
            );
          }

          final horarios = snapshot.data ?? [];
          if (horarios.isEmpty) {
            return const EstadoVazio(
              mensagem: 'Nenhum horario de coleta encontrado para sua regiao.',
            );
          }

          return _CronogramaConteudo(horarios: horarios);
        },
      ),
    );
  }
}

class _CronogramaConteudo extends StatelessWidget {
  const _CronogramaConteudo({required this.horarios});

  final List<HorarioColeta> horarios;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cronograma de coleta',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...horarios.map(
            (horario) => CardCrono(
              day: horario.diaSemana,
              time: horario.horarioEstimado,
              type: horario.tipoLixo,
              iconColor: _corTipo(horario.tipoLixo),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Cronograma completo'),
            ),
          ),
        ],
      ),
    );
  }

  Color _corTipo(String tipo) {
    final normalizado = tipo.toLowerCase();
    if (normalizado.contains('organ')) return const Color(0xFF7E3E3E);
    return const Color(0xFF4AA564);
  }
}
