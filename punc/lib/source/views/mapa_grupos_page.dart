import 'package:flutter/material.dart';

import '../data/modelos/motorista.dart';
import '../viewmodels/mapa_view_model.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/punc_app_shell.dart';

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
    return PuncAppShell(
      selectedRoute: '/mapa',
      body: FutureBuilder<List<LocalizacaoMotorista>>(
        future: _trajetosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EstadoCarregando();
          }

          if (snapshot.hasError) {
            return EstadoErro(
              mensagem: 'Nao foi possivel carregar os caminhoes no mapa.',
              onTentarNovamente: () => setState(_carregar),
            );
          }

          final trajetos = snapshot.data ?? [];
          if (trajetos.isEmpty) {
            return const EstadoVazio(
              mensagem: 'Nenhum caminhao em percurso neste momento.',
            );
          }

          return _MapaConteudo(trajetos: trajetos);
        },
      ),
    );
  }
}

class _MapaConteudo extends StatelessWidget {
  const _MapaConteudo({required this.trajetos});

  final List<LocalizacaoMotorista> trajetos;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFD9F7E8),
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
                    'Caminhao a caminho',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text('Caminhoes em rota: ${trajetos.length}'),
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
              message: trajeto.identificacaoCaminhao ?? 'Caminhao em rota',
              child: const Icon(
                Icons.location_on,
                color: Color(0xFFE03B3B),
                size: 34,
              ),
            ),
          );
        }),
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
