import 'package:flutter/material.dart';

import '../../nucleo/erros/falha_api.dart';
import '../data/modelos/gerente.dart';
import '../viewmodel/caminhoes_view_model.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/formulario_desktop.dart';

class CaminhoesPage extends StatefulWidget {
  const CaminhoesPage({super.key, required this.idGerente});

  final int idGerente;

  @override
  State<CaminhoesPage> createState() => _CaminhoesPageState();
}

class _CaminhoesPageState extends State<CaminhoesPage> {
  final _viewModel = CaminhoesViewModel();
  final _macController = TextEditingController();
  final _buscaController = TextEditingController();

  late Future<List<MotoristaGerente>> _motoristasFuture;
  String _filtro = '';
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _macController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  void _carregar() {
    setState(() {
      _motoristasFuture = _viewModel.listar(idGerente: widget.idGerente);
    });
  }

  Future<void> _cadastrar() async {
    final mac = _macController.text.trim();
    if (mac.isEmpty) {
      _mostrarSnackBar('Informe o MAC do dispositivo.');
      return;
    }

    setState(() => _salvando = true);
    try {
      await _viewModel.cadastrar(idGerente: widget.idGerente, mac: mac);
      _macController.clear();
      _carregar();
      if (!mounted) return;
      _mostrarSnackBar('Caminhão cadastrado com sucesso.');
    } on FalhaApi catch (e) {
      if (!mounted) return;
      final mensagem = e.statusCode == 404
          ? 'MAC não encontrado. O dispositivo precisa estar cadastrado no app PUNC.'
          : e.mensagem;
      _mostrarSnackBar(mensagem);
    } on ArgumentError catch (e) {
      if (!mounted) return;
      _mostrarSnackBar(e.message ?? 'Dados inválidos.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir(MotoristaGerente motorista) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover caminhão?'),
        content: Text(
          'Deseja remover ${motorista.nomeDispositivo} (${motorista.mac})?',
        ),
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
        idMotorista: motorista.idMotorista,
      );
      _carregar();
      if (!mounted) return;
      _mostrarSnackBar('Caminhão removido.');
    } on FalhaApi catch (e) {
      if (!mounted) return;
      _mostrarSnackBar(e.mensagem);
    }
  }

  List<MotoristaGerente> _filtrar(List<MotoristaGerente> motoristas) {
    final termo = _filtro.trim().toLowerCase();
    if (termo.isEmpty) return motoristas;

    return motoristas.where((motorista) {
      return motorista.nomeDispositivo.toLowerCase().contains(termo) ||
          motorista.mac.toLowerCase().contains(termo);
    }).toList();
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
            titulo: 'Cadastrar caminhão de lixo',
            subtitulo:
                'Informe o MAC exibido no celular do motorista. '
                'O dispositivo precisa estar cadastrado no app PUNC.',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _macController,
                    enabled: !_salvando,
                    decoration: const InputDecoration(
                      labelText: 'MAC do dispositivo',
                      hintText: 'AA:BB:CC:DD:EE:FF',
                      prefixIcon: Icon(Icons.nfc),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Caminhões cadastrados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _buscaController,
                  decoration: const InputDecoration(
                    hintText: 'Pesquisar...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (valor) => setState(() => _filtro = valor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<MotoristaGerente>>(
            future: _motoristasFuture,
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
                    mensagem: 'Não foi possível carregar os caminhões.',
                    onTentarNovamente: _carregar,
                  ),
                );
              }

              final motoristas = _filtrar(snapshot.data ?? []);
              if (motoristas.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: EstadoVazio(
                    mensagem: 'Nenhum caminhão cadastrado.',
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Dispositivo')),
                    DataColumn(label: Text('MAC')),
                    DataColumn(label: Text('Cadastro')),
                    DataColumn(label: Text('Ações')),
                  ],
                  rows: motoristas
                      .map(
                        (motorista) => DataRow(
                          cells: [
                            DataCell(Text(motorista.nomeDispositivo)),
                            DataCell(Text(motorista.mac)),
                            DataCell(Text(motorista.dataCriacao ?? '—')),
                            DataCell(
                              IconButton(
                                tooltip: 'Excluir',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _excluir(motorista),
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
