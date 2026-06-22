import 'package:flutter/material.dart';

import '../data/modelos/gerente.dart';
import '../viewmodels/gerenciamento_view_model.dart';
import '../widgets/card_veiculo.dart';
import '../widgets/estado_pagina.dart';
import '../widgets/punc_app_shell.dart';

// Importe sua classe de cores
// import 'caminho_para_seu_arquivo_de_cores.dart';

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
    setState(() {
      _motoristasFuture = _viewModel.carregarMotoristas(
        idGerente: _idGerentePadrao,
      );
    });
  }

  Future<void> _excluir(MotoristaGerente motorista) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deseja remover este caminhão?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: colorScheme.outline)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
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
    final colorScheme = Theme.of(context).colorScheme;

    return PuncAppShell(
      selectedRoute: '/gerenciamento',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gerenciamento',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            Text(
              'Motoristas e Caminhões',
              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 20),
            
            // Botão Adicionar (Verde no WF -> Ciano na Paleta)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final resultado = await Navigator.pushNamed(
                    context,
                    '/gerenciamento/novo',
                  );
                  if (resultado == true && mounted) {
                    _carregar();
                  }
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Adicionar motorista/caminhão'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary, // claroSecundaria (Ciano)
                  foregroundColor: colorScheme.onSecondary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Campo de Pesquisa
            TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Pesquisar caminhão',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
              ),
              onChanged: (value) => setState(() => _filtro = value),
            ),
            
            const SizedBox(height: 20),
            
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
                      mensagem: 'Não foi possível carregar os veículos.',
                      onTentarNovamente: () => setState(_carregar),
                    ),
                  );
                }

                final motoristas = _filtrar(snapshot.data ?? []);
                if (motoristas.isEmpty) {
                  return const SizedBox(
                    height: 220,
                    child: EstadoVazio(
                      mensagem: 'Nenhum motorista ou caminhão encontrado.',
                    ),
                  );
                }

                return Column(
                  children: [
                    ...motoristas.map(
                      (motorista) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CardVeiculo(
                          title: motorista.identificacaoCaminhao ??
                              'Caminhão ${motorista.idMotorista}',
                          driver: motorista.nomeDispositivo,
                          plate: motorista.mac,
                          phone: motorista.status ?? 'Status não informado',
                          status: motorista.status ?? 'Disponível',
                          // Mapeamento de cores de status baseado na sua paleta
                          statusColor: _corStatus(motorista.status, colorScheme),
                          onDelete: () => _excluir(motorista),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Botão Ver Todos (Verde Escuro no WF -> Roxo AppBar na Paleta)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.list, size: 20),
                        label: const Text('Ver todos os veículos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4338CA), // claroAppBar
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
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

  Color _corStatus(String? status, ColorScheme colorScheme) {
    final texto = status?.toLowerCase() ?? '';
    if (texto.contains('percurso') || texto.contains('rota')) {
      return colorScheme.secondary; // Ciano para "Em rota" (era verde)
    }
    return colorScheme.primary; // Roxo para "Disponível" (era azul)
  }
}
