import 'package:flutter/material.dart';

import '../data/modelos/gerente.dart';
import '../viewmodels/gerenciamento_view_model.dart';
import '../widgets/card_veiculo.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/punc_app_shell.dart';

class GerenciamentoPage extends StatefulWidget {
  const GerenciamentoPage({super.key});

  @override
  State<GerenciamentoPage> createState() => _GerenciamentoPageState();
}

class _GerenciamentoPageState extends State<GerenciamentoPage> {
  static const int _idGerentePadrao = 1;

  final GerenciamentoViewModel _viewModel = GerenciamentoViewModel();
  final TextEditingController _buscaController = TextEditingController();
  late Future<List<MotoristaGerente>> _motoristasFuture;
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _carregar() {
    _motoristasFuture = _viewModel.carregarMotoristas(
      idGerente: _idGerentePadrao,
    );
  }

  Future<void> _excluir(MotoristaGerente motorista) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deseja remover este caminhao?'),
        content: const Text('Essa acao nao pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    await _viewModel.excluirMotorista(
      idGerente: _idGerentePadrao,
      idMotorista: motorista.idMotorista,
    );

    if (!mounted) return;
    setState(_carregar);
  }

  @override
  Widget build(BuildContext context) {
    return PuncAppShell(
      selectedRoute: '/gerenciamento',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gerenciamento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Text('Motoristas e Caminhoes'),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/gerenciamento/novo'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar motorista/caminhao'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                hintText: 'Pesquisar caminhao',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _filtro = value),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<MotoristaGerente>>(
              future: _motoristasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 220, child: EstadoCarregando());
                }

                if (snapshot.hasError) {
                  return SizedBox(
                    height: 260,
                    child: EstadoErro(
                      mensagem: 'Nao foi possivel carregar os veiculos.',
                      onTentarNovamente: () => setState(_carregar),
                    ),
                  );
                }

                final motoristas = _filtrar(snapshot.data ?? []);
                if (motoristas.isEmpty) {
                  return const SizedBox(
                    height: 220,
                    child: EstadoVazio(
                      mensagem: 'Nenhum motorista ou caminhao encontrado.',
                    ),
                  );
                }

                return Column(
                  children: [
                    ...motoristas.map(
                      (motorista) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CardVeiculo(
                          title: motorista.identificacaoCaminhao ??
                              'Caminhao ${motorista.idMotorista}',
                          driver: motorista.nomeDispositivo,
                          plate: motorista.mac,
                          phone: motorista.status ?? 'Status nao informado',
                          status: motorista.status ?? 'Disponivel',
                          statusColor: _corStatus(motorista.status),
                          onDelete: () => _excluir(motorista),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.list, size: 18),
                        label: const Text('Ver todos os veiculos'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<MotoristaGerente> _filtrar(List<MotoristaGerente> motoristas) {
    final termo = _filtro.trim().toLowerCase();
    if (termo.isEmpty) return motoristas;

    return motoristas.where((motorista) {
      return motorista.nomeDispositivo.toLowerCase().contains(termo) ||
          motorista.mac.toLowerCase().contains(termo) ||
          (motorista.identificacaoCaminhao ?? '').toLowerCase().contains(termo);
    }).toList();
  }

  Color _corStatus(String? status) {
    final texto = status?.toLowerCase() ?? '';
    if (texto.contains('percurso') || texto.contains('rota')) {
      return const Color(0xFF4AA564);
    }
    return const Color(0xFF2F80ED);
  }
}
