import 'package:flutter/material.dart';

import '../data/modelos/trajetoria.dart';
import '../viewmodel/rotas_view_model.dart';
import '../widgets/estado_pagina.dart';

class TrajetoriaDetalhePage extends StatefulWidget {
  const TrajetoriaDetalhePage({
    super.key,
    required this.idGerente,
    required this.trajetoria,
  });

  final int idGerente;
  final TrajetoriaGerente trajetoria;

  @override
  State<TrajetoriaDetalhePage> createState() => _TrajetoriaDetalhePageState();
}

class _TrajetoriaDetalhePageState extends State<TrajetoriaDetalhePage> {
  final _viewModel = RotasViewModel();
  late Future<List<LocalizacaoTrajetoria>> _localizacoesFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _localizacoesFuture = _viewModel.listarLocalizacoes(
        idGerente: widget.idGerente,
        idTrajetoria: widget.trajetoria.idTrajetoria,
      );
    });
  }

  String _formatarData(String? valor) {
    if (valor == null || valor.isEmpty) return '—';
    return valor.replaceFirst('T', ' ').split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    final trajetoria = widget.trajetoria;

    return Scaffold(
      appBar: AppBar(
        title: Text('Rota #${trajetoria.idTrajetoria}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trajetoria.nomeMotorista,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('MAC: ${trajetoria.mac}'),
                    if (trajetoria.tipoLixo != null)
                      Text('Tipo: ${trajetoria.tipoLixo}'),
                    Text('Início: ${_formatarData(trajetoria.tempoComeco)}'),
                    Text(
                      trajetoria.tempoFim != null
                          ? 'Fim: ${_formatarData(trajetoria.tempoFim)}'
                          : 'Status: Em andamento',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Localizações da trajetória',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<LocalizacaoTrajetoria>>(
                future: _localizacoesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const EstadoCarregando();
                  }

                  if (snapshot.hasError) {
                    return EstadoErro(
                      mensagem: 'Não foi possível carregar as localizações.',
                      onTentarNovamente: _carregar,
                    );
                  }

                  final localizacoes = snapshot.data ?? [];
                  if (localizacoes.isEmpty) {
                    return const EstadoVazio(
                      mensagem: 'Nenhuma localização registrada nesta rota.',
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('Latitude')),
                          DataColumn(label: Text('Longitude')),
                          DataColumn(label: Text('Registrado em')),
                        ],
                        rows: localizacoes
                            .map(
                              (loc) => DataRow(
                                cells: [
                                  DataCell(Text('${loc.ordem ?? '—'}')),
                                  DataCell(
                                    Text(loc.latitude.toStringAsFixed(6)),
                                  ),
                                  DataCell(
                                    Text(loc.longitude.toStringAsFixed(6)),
                                  ),
                                  DataCell(
                                    Text(_formatarData(loc.dataCriacao)),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
