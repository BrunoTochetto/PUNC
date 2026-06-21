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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PuncAppShell(
      selectedRoute: '/cronograma',
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: FutureBuilder<List<HorarioColeta>>(
          future: _cronogramaFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EstadoCarregando();
            }

            if (snapshot.hasError) {
              return EstadoErro(
                mensagem: 'Não foi possível carregar o cronograma.',
                onTentarNovamente: () => setState(_carregar),
              );
            }

            final horarios = snapshot.data ?? [];
            if (horarios.isEmpty) {
              return const EstadoVazio(
                mensagem: 'Nenhum horário de coleta encontrado para sua região...',
              );
              // ! To-do: Adicionar para, se não achar nada a pessoa colocar seu CEP. Dai ele vai mudando de coisa pra coisa
              // ! Também! Quando ele pega os dados, ele deve salvar LOCALMENTE no HIVE.
            }

            return _CronogramaConteudo(
              horarios: horarios,
              corBotao: colorScheme.secondary,
              corTexto: colorScheme.onSurface,
            );
          },
        ),
      ),
    );
  }
}

class _CronogramaConteudo extends StatelessWidget {
  const _CronogramaConteudo({
    required this.horarios,
    required this.corBotao,
    required this.corTexto,
  });

  final List<HorarioColeta> horarios;
  final Color corBotao;
  final Color corTexto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cronograma de coleta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: corTexto,
            ),
          ),
          const SizedBox(height: 20),
          // Lista de Cards de Cronograma
          ...horarios.map(
            (horario) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CardCrono(
                day: horario.diaSemana,
                time: horario.horarioEstimado,
                type: horario.tipoLixo,
                iconColor: _corTipo(horario.tipoLixo),
                // Observação: O widget CardCrono deve suportar a cor branca internamente.
                // Se for um Container, deve ter color: Colors.white e border: Border.all(color: Color(0xFFE0E0E0))
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Botão "Cronograma completo" estilizado
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: corBotao,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cronograma completo',
                // style: TextStyle(
                //   fontSize: 14,
                //   fontWeight: FontWeight.bold,
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _corTipo(String tipo) {
    final normalizado = tipo.toLowerCase();
    if (normalizado.contains('organ') || normalizado.contains('orgân')) return const Color(0xFF8B4513);
    return const Color(0xFF4AA564);
  }
}
