import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../nucleo/erros/falha_api.dart';
import '../data/modelos/gerente.dart';
import '../viewmodel/areas_atuacao_view_model.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/formulario_desktop.dart';

class AreasAtuacaoPage extends StatefulWidget {
  const AreasAtuacaoPage({super.key, required this.idGerente});

  final int idGerente;

  @override
  State<AreasAtuacaoPage> createState() => _AreasAtuacaoPageState();
}

class _AreasAtuacaoPageState extends State<AreasAtuacaoPage> {
  final _viewModel = AreasAtuacaoViewModel();
  final _cepController = TextEditingController();

  late Future<List<AreaAtuacao>> _areasFuture;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  void _carregar() {
    setState(() {
      _areasFuture = _viewModel.listar(idGerente: widget.idGerente);
    });
  }

  Future<void> _cadastrar() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.isEmpty) {
      _mostrarSnackBar('Informe o CEP.');
      return;
    }

    setState(() => _salvando = true);
    try {
      await _viewModel.cadastrar(idGerente: widget.idGerente, cep: cep);
      _cepController.clear();
      _carregar();
      if (!mounted) return;
      _mostrarSnackBar('Área cadastrada com sucesso.');
    } on FalhaApi catch (e) {
      if (!mounted) return;
      _mostrarSnackBar(e.mensagem);
    } on ArgumentError catch (e) {
      if (!mounted) return;
      _mostrarSnackBar(e.message ?? 'CEP inválido.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir(AreaAtuacao area) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover área?'),
        content: Text('Deseja remover a área com CEP ${area.cep}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    try {
      await _viewModel.remover(
        idGerente: widget.idGerente,
        idAreaAtuacao: area.id,
      );
      _carregar();
      if (!mounted) return;
      _mostrarSnackBar('Área removida.');
    } on FalhaApi catch (e) {
      if (!mounted) return;
      _mostrarSnackBar(e.mensagem);
    }
  }

  void _mostrarSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormularioDesktop(
            titulo: 'Cadastrar área de atuação',
            subtitulo: 'Informe o prefixo numérico da região (1 a 9 dígitos).',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _cepController,
                    enabled: !_salvando,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'CEP / prefixo',
                      hintText: 'Ex.: 897',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      helperText: 'Somente números, de 1 a 9 dígitos.',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _salvando ? null : _cadastrar,
                  icon: _salvando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: const Text('Cadastrar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Áreas cadastradas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<AreaAtuacao>>(
            future: _areasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: EstadoCarregando(),
                );
              }

              if (snapshot.hasError) {
                return SizedBox(
                  height: 200,
                  child: EstadoErro(
                    mensagem: 'Não foi possível carregar as áreas.',
                    onTentarNovamente: _carregar,
                  ),
                );
              }

              final areas = snapshot.data ?? [];
              if (areas.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: EstadoVazio(
                    mensagem: 'Nenhuma área de atuação cadastrada.',
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('CEP')),
                    DataColumn(label: Text('Ações')),
                  ],
                  rows: areas
                      .map(
                        (area) => DataRow(
                          cells: [
                            DataCell(Text(area.cep)),
                            DataCell(
                              IconButton(
                                tooltip: 'Excluir',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _excluir(area),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
