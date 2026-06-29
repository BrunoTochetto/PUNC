import 'package:flutter/material.dart';

import '../data/modelos/trajetoria.dart';
import '../viewmodel/rotas_view_model.dart';
import '../widgets/estado_pagina.dart';
import 'trajetoria_detalhe_page.dart';

class RotasPage extends StatefulWidget {
  const RotasPage({super.key, required this.idGerente});

  final int idGerente;

  @override
  State<RotasPage> createState() => _RotasPageState();
}

class _RotasPageState extends State<RotasPage> {
  final _viewModel = RotasViewModel();
  late Future<List<TrajetoriaGerente>> _trajetoriasFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _trajetoriasFuture = _viewModel.listar(idGerente: widget.idGerente);
    });
  }

  void _abrirDetalhe(TrajetoriaGerente trajetoria) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrajetoriaDetalhePage(
          idGerente: widget.idGerente,
          trajetoria: trajetoria,
        ),
      ),
    );
  }

  String _formatarData(String? valor) {
    if (valor == null || valor.isEmpty) return '—';
    return valor.replaceFirst('T', ' ').split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Rotas realizadas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Clique em uma rota para ver todas as localizações registradas.',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<TrajetoriaGerente>>(
              future: _trajetoriasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const EstadoCarregando();
                }

                if (snapshot.hasError) {
                  return EstadoErro(
                    mensagem: 'Não foi possível carregar as rotas.',
                    onTentarNovamente: _carregar,
                  );
                }

                final trajetorias = snapshot.data ?? [];
                if (trajetorias.isEmpty) {
                  return const EstadoVazio(
                    mensagem: 'Nenhuma rota registrada.',
                  );
                }

                return ListView.separated(
                  itemCount: trajetorias.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final trajetoria = trajetorias[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          trajetoria.emAndamento
                              ? Icons.route
                              : Icons.check_circle_outline,
                          color: trajetoria.emAndamento
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        title: Text(
                          trajetoria.identificacaoCaminhao?.isNotEmpty == true
                              ? trajetoria.identificacaoCaminhao!
                              : trajetoria.nomeMotorista,
                        ),
                        subtitle: Text(
                          'Início: ${_formatarData(trajetoria.tempoComeco)}'
                          '${trajetoria.tempoFim != null ? ' · Fim: ${_formatarData(trajetoria.tempoFim)}' : ' · Em andamento'}'
                          '\n${trajetoria.quantidadeLocalizacoes ?? 0} localizações',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _abrirDetalhe(trajetoria),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
