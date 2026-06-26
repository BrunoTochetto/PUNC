import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/modelos/motorista.dart';
import '../viewmodels/mapa_view_model.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/painel_controle_motorista.dart';
import '../widgets/punc_app_shell.dart';
import '../viewmodels/motorista_view_model.dart';

class MapaGruposPage extends StatefulWidget {
  const MapaGruposPage({super.key});

  @override
  State<MapaGruposPage> createState() => _MapaGruposPageState();
}

class _MapaGruposPageState extends State<MapaGruposPage> {
  final MapaViewModel _viewModel = MapaViewModel();
  late Future<List<LocalizacaoMotorista>> _trajetosFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _trajetosFuture = _viewModel.carregarTrajetos();
  }

  @override
  Widget build(BuildContext context) {
    final ehMotorista = context.watch<MotoristaViewModel>().ehMotorista;

    return PuncAppShell(
      selectedRoute: '/mapa',
      body: FutureBuilder<List<LocalizacaoMotorista>>(
        future: _trajetosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _MapaComPainelMotorista(
              ehMotorista: ehMotorista,
              child: const EstadoCarregando(),
            );
          }

          if (snapshot.hasError) {
            return _MapaComPainelMotorista(
              ehMotorista: ehMotorista,
              child: EstadoErro(
                mensagem: 'Não foi possível carregar os caminhões no mapa.',
                onTentarNovamente: () => setState(_carregar),
              ),
            );
          }

          final trajetos = snapshot.data ?? [];
          if (trajetos.isEmpty && !ehMotorista) {
            return const EstadoVazio(
              mensagem: 'Nenhum caminhão em percurso neste momento.',
            );
          }

          return _MapaComPainelMotorista(
            ehMotorista: ehMotorista,
            child: trajetos.isEmpty
                ? _MapaMotoristaVazio()
                : _MapaConteudo(
                    trajetos: trajetos,
                    ocultarRodape: ehMotorista,
                  ),
          );
        },
      ),
    );
  }
}

class _MapaMotoristaVazio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          color: colorScheme.surface,
          child: Center(
            child: Icon(
              Icons.map_outlined,
              size: 220,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Ative a rota abaixo para começar a enviar sua localização.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapaComPainelMotorista extends StatelessWidget {
  const _MapaComPainelMotorista({
    required this.ehMotorista,
    required this.child,
  });

  final bool ehMotorista;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        if (ehMotorista)
          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: PainelControleMotorista(),
          ),
      ],
    );
  }
}

class _MapaConteudo extends StatelessWidget {
  const _MapaConteudo({
    required this.trajetos,
    this.ocultarRodape = false,
  });

  final List<LocalizacaoMotorista> trajetos;
  final bool ocultarRodape;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Stack(
      children: [
        Container(
          color: colorScheme.surface,
          child: const Center(
            child: Icon(Icons.map_outlined, size: 220, color: Colors.white70),
          ),
        ),
        Positioned(
          top: 18,
          left: 32,
          right: 32,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Caminhão a caminho',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text('Caminhões em rota: ${trajetos.length}'),
                ],
              ),
            ),
          ),
        ),
        ...trajetos.asMap().entries.map((entry) {
          final index = entry.key;
          final trajeto = entry.value;
          return Positioned(
            top: 150 + (index * 34) % 180,
            left: 70 + (index * 58) % 220,
            child: Tooltip(
              message: trajeto.identificacaoCaminhao ?? 'Caminhão em rota',
              child: Icon(
                Icons.location_on,
                color: colorScheme.error,
                size: 34,
              ),
            ),
          );
        }),
        if (!ocultarRodape)
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '30 de Outubro, 2026',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text('Acompanhe a coleta em tempo real'),
                    ],
                  ),
                  Text('${trajetos.length} ativo(s)'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
