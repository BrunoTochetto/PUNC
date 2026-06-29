import 'package:flutter/material.dart';

import '../data/modelos/gerente.dart';
import '../views/areas_atuacao_page.dart';
import '../views/caminhoes_page.dart';
import '../views/horarios_coleta_page.dart';
import '../views/rotas_page.dart';

enum DestinoGerenciamento { areas, caminhoes, horarios, rotas }

class GerenciamentoShell extends StatefulWidget {
  const GerenciamentoShell({
    super.key,
    required this.sessao,
    required this.onLogout,
    this.destinoInicial = DestinoGerenciamento.areas,
  });

  final SessaoGerente sessao;
  final Future<void> Function() onLogout;
  final DestinoGerenciamento destinoInicial;

  @override
  State<GerenciamentoShell> createState() => _GerenciamentoShellState();
}

class _GerenciamentoShellState extends State<GerenciamentoShell> {
  late DestinoGerenciamento _destino;

  @override
  void initState() {
    super.initState();
    _destino = widget.destinoInicial;
  }

  Future<void> _confirmarLogout() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Deseja encerrar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.sizeOf(context).width;
    final compacto = largura < 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento PUNC'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                widget.sessao.nome,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _destino.index,
            extended: !compacto,
            labelType: compacto
                ? NavigationRailLabelType.selected
                : NavigationRailLabelType.none,
            onDestinationSelected: (index) {
              if (index == 4) {
                _confirmarLogout();
                return;
              }
              setState(() => _destino = DestinoGerenciamento.values[index]);
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: Text('Áreas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping),
                label: Text('Caminhões'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.schedule_outlined),
                selectedIcon: Icon(Icons.schedule),
                label: Text('Horários'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.route_outlined),
                selectedIcon: Icon(Icons.route),
                label: Text('Rotas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.logout),
                label: Text('Sair'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _conteudo()),
        ],
      ),
    );
  }

  Widget _conteudo() {
    return IndexedStack(
      index: _destino.index,
      children: [
        AreasAtuacaoPage(idGerente: widget.sessao.id),
        CaminhoesPage(idGerente: widget.sessao.id),
        HorariosColetaPage(idGerente: widget.sessao.id),
        RotasPage(idGerente: widget.sessao.id),
      ],
    );
  }
}

DestinoGerenciamento destinoFromRoute(String? route) {
  return switch (route) {
    '/caminhoes' => DestinoGerenciamento.caminhoes,
    '/horarios' => DestinoGerenciamento.horarios,
    '/rotas' => DestinoGerenciamento.rotas,
    _ => DestinoGerenciamento.areas,
  };
}
